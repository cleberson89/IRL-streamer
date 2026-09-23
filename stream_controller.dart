import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtmp_streaming/rtmp_streaming.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/reconnect_manager.dart';
import '../../models/stream_profile.dart';

enum StreamState {
  idle,
  connecting,
  live,
  reconnecting,
  error,
  stopping,
}

class StreamStats {
  final int currentBitrateKbps;
  final int targetBitrateKbps;
  final double packetLoss;
  final Duration uptime;
  final int droppedFrames;
  final String connectionQuality;

  const StreamStats({
    this.currentBitrateKbps = 0,
    this.targetBitrateKbps = 2500,
    this.packetLoss = 0.0,
    this.uptime = Duration.zero,
    this.droppedFrames = 0,
    this.connectionQuality = 'desconhecido',
  });

  StreamStats copyWith({
    int? currentBitrateKbps,
    int? targetBitrateKbps,
    double? packetLoss,
    Duration? uptime,
    int? droppedFrames,
    String? connectionQuality,
  }) {
    return StreamStats(
      currentBitrateKbps: currentBitrateKbps ?? this.currentBitrateKbps,
      targetBitrateKbps: targetBitrateKbps ?? this.targetBitrateKbps,
      packetLoss: packetLoss ?? this.packetLoss,
      uptime: uptime ?? this.uptime,
      droppedFrames: droppedFrames ?? this.droppedFrames,
      connectionQuality: connectionQuality ?? this.connectionQuality,
    );
  }
}

class StreamControllerState {
  final StreamState state;
  final StreamProfile? profile;
  final StreamStats stats;
  final String? errorMessage;
  final int reconnectAttempt;
  final CameraController? cameraController;

  const StreamControllerState({
    this.state = StreamState.idle,
    this.profile,
    this.stats = const StreamStats(),
    this.errorMessage,
    this.reconnectAttempt = 0,
    this.cameraController,
  });

  StreamControllerState copyWith({
    StreamState? state,
    StreamProfile? profile,
    StreamStats? stats,
    String? errorMessage,
    int? reconnectAttempt,
    CameraController? cameraController,
  }) {
    return StreamControllerState(
      state: state ?? this.state,
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      errorMessage: errorMessage,
      reconnectAttempt: reconnectAttempt ?? this.reconnectAttempt,
      cameraController: cameraController ?? this.cameraController,
    );
  }

  bool get isStreaming =>
      state == StreamState.live ||
      state == StreamState.connecting ||
      state == StreamState.reconnecting;
}

class StreamControllerNotifier extends StateNotifier<StreamControllerState> {
  StreamControllerNotifier() : super(const StreamControllerState());

  ReconnectManager? _reconnectManager;
  Timer? _statsTimer;
  DateTime? _liveStartedAt;
  int _currentTargetBitrate = 2500;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  Future<void> initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        state = state.copyWith(errorMessage: 'Nenhuma câmera encontrada');
        return;
      }

      final backIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      _currentCameraIndex = backIndex >= 0 ? backIndex : 0;

      final controller = CameraController(
        _cameras[_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: true,
      );

      await controller.initialize();
      await controller.prepareForVideoStreaming();

      state = state.copyWith(
        cameraController: controller,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao abrir câmera: $e');
    }
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2 || state.cameraController == null) return;

    final wasStreaming = state.isStreaming;
    final profile = state.profile;

    if (wasStreaming) {
      await stop();
    }

    await state.cameraController!.dispose();

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;

    final controller = CameraController(
      _cameras[_currentCameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
    );
    await controller.initialize();
    await controller.prepareForVideoStreaming();

    state = state.copyWith(cameraController: controller);

    if (wasStreaming && profile != null) {
      await start(profile);
    }
  }

  Future<void> start(StreamProfile profile) async {
    final controller = state.cameraController;
    if (controller == null || !controller.value.isInitialized) {
      state = state.copyWith(errorMessage: 'Câmera não inicializada');
      return;
    }
    if (state.isStreaming) return;

    state = state.copyWith(
      state: StreamState.connecting,
      profile: profile,
      errorMessage: null,
      stats: StreamStats(targetBitrateKbps: profile.targetBitrate),
    );

    _currentTargetBitrate = profile.targetBitrate;

    try {
      await controller.setVideoSettings(bitrate: profile.targetBitrate * 1000);
      await controller.setFrameRate(profile.fps);
      await controller.setAudioSettings(128 * 1000);

      // Detecta protocolo automaticamente pela URL
      final url = profile.fullUrl.toLowerCase();
      final protocol = url.startsWith('srt')
          ? StreamingProtocol.srt
          : StreamingProtocol.rtmp;

      await controller.startVideoStreaming(
        profile.fullUrl,
        protocol: protocol,
      );

      await WakelockPlus.enable();
      _onConnected();
    } catch (e) {
      debugPrint('Erro ao iniciar stream: $e');
      state = state.copyWith(
        state: StreamState.error,
        errorMessage: e.toString(),
      );
      _startReconnect(profile);
    }
  }

  Future<void> stop() async {
    state = state.copyWith(state: StreamState.stopping);
    _reconnectManager?.stop();
    _statsTimer?.cancel();

    try {
      final controller = state.cameraController;
      if (controller != null && controller.value.isStreaming) {
        await controller.stopStreaming();
      }
    } catch (e) {
      debugPrint('Erro ao parar stream: $e');
    }

    await WakelockPlus.disable();
    _liveStartedAt = null;

    state = state.copyWith(
      state: StreamState.idle,
      errorMessage: null,
      reconnectAttempt: 0,
    );
  }

  void _onConnected() {
    _reconnectManager?.success();
    _liveStartedAt ??= DateTime.now();

    state = state.copyWith(
      state: StreamState.live,
      errorMessage: null,
      reconnectAttempt: 0,
    );

    _startStatsPolling();
  }

  void _startReconnect(StreamProfile profile) {
    _reconnectManager?.stop();
    _reconnectManager = ReconnectManager(
      onReconnectAttempt: () async {
        state = state.copyWith(
          state: StreamState.reconnecting,
          reconnectAttempt: (_reconnectManager?.currentAttempt ?? 0) + 1,
        );

        try {
          final controller = state.cameraController;
          if (controller == null) return;

          try {
            if (controller.value.isStreaming) {
              await controller.stopStreaming();
            }
          } catch (_) {}

          final url = profile.fullUrl.toLowerCase();
          final protocol = url.startsWith('srt')
              ? StreamingProtocol.srt
              : StreamingProtocol.rtmp;
          await controller.startVideoStreaming(
            profile.fullUrl,
            protocol: protocol,
          );
          _onConnected();
        } catch (e) {
          debugPrint('Reconnect falhou: $e');
        }
      },
      onGiveUp: () {
        state = state.copyWith(
          state: StreamState.error,
          errorMessage: 'Não foi possível restabelecer a conexão.',
        );
      },
      maxAttempts: -1,
    );
    _reconnectManager!.start();
  }

  void _startStatsPolling() {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (state.state != StreamState.live) return;

      final uptime = _liveStartedAt != null
          ? DateTime.now().difference(_liveStartedAt!)
          : Duration.zero;

      state = state.copyWith(
        stats: state.stats.copyWith(
          currentBitrateKbps: _currentTargetBitrate,
          targetBitrateKbps: _currentTargetBitrate,
          uptime: uptime,
          connectionQuality: 'boa',
        ),
      );
    });
  }

  @override
  void dispose() {
    _reconnectManager?.stop();
    _statsTimer?.cancel();
    state.cameraController?.dispose();
    super.dispose();
  }
}

final streamControllerProvider =
    StateNotifierProvider<StreamControllerNotifier, StreamControllerState>(
  (ref) => StreamControllerNotifier(),
);
