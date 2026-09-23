import 'package:flutter/services.dart';

/// Bridge para o encoding/streaming nativo.
/// 
/// Android: recomendado RootEncoder (com.github.pedroSG94.RootEncoder)
/// iOS: recomendado HaishinKit.swift
/// 
/// Este arquivo define a interface. A implementação real fica nos
/// platform channels (android/ e ios/).

class NativeStreamer {
  static const _channel = MethodChannel('com.irlstreamer/native');

  /// Inicia o streaming RTMP
  static Future<bool> start({
    required String url,
    required int width,
    required int height,
    required int fps,
    required int bitrateKbps,
    required String cameraId, // "0" = back, "1" = front (simplificado)
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('start', {
        'url': url,
        'width': width,
        'height': height,
        'fps': fps,
        'bitrate': bitrateKbps * 1000, // bits
        'cameraId': cameraId,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Falha nativa: ${e.message}');
    }
  }

  static Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }

  static Future<void> setBitrate(int bitrateKbps) async {
    await _channel.invokeMethod('setBitrate', {'bitrate': bitrateKbps * 1000});
  }

  static Future<void> switchCamera() async {
    await _channel.invokeMethod('switchCamera');
  }

  static Future<void> setMute(bool mute) async {
    await _channel.invokeMethod('setMute', {'mute': mute});
  }

  /// Eventos que o nativo deve enviar de volta (via EventChannel)
  /// - onConnected
  /// - onDisconnected
  /// - onStats {bitrate, packetLoss, droppedFrames}
  /// - onError {message}
}
