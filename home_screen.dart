import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtmp_streaming/rtmp_streaming.dart';

import '../stream/stream_controller.dart';
import '../overlays/overlay_provider.dart';
import '../../models/stream_profile.dart';
import 'widgets/overlay_layer.dart';
import 'widgets/stream_controls.dart';
import 'widgets/stats_bar.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  StreamProfile _profile = StreamProfile(
    id: 'default',
    name: 'Meu Stream',
    rtmpUrl: 'rtmp://',
    streamKey: '',
    targetBitrate: 2500,
    width: 1280,
    height: 720,
    fps: 30,
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(streamControllerProvider.notifier).initCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stream = ref.watch(streamControllerProvider);
    final overlays = ref.watch(overlayProvider);
    final controller = stream.cameraController;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (controller != null && controller.value.isInitialized)
              CameraPreview(controller)
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (stream.errorMessage != null) ...[
                      const Icon(Icons.error_outline, color: Colors.orange, size: 48),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          stream.errorMessage!,
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ] else ...[
                      const CircularProgressIndicator(color: Colors.white54),
                      const SizedBox(height: 12),
                      const Text('Abrindo câmera...', style: TextStyle(color: Colors.white54)),
                    ],
                  ],
                ),
              ),

            OverlayLayer(items: overlays.active),

            if (stream.isStreaming)
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: StatsBar(stats: stream.stats, state: stream.state),
              ),

            Positioned(
              bottom: 16,
              left: 12,
              right: 12,
              child: StreamControls(
                streamState: stream.state,
                onToggleLive: () async {
                  if (stream.isStreaming) {
                    await ref.read(streamControllerProvider.notifier).stop();
                  } else {
                    if (_profile.rtmpUrl.length < 10 || _profile.streamKey.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Configure a URL RTMP e a chave primeiro'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(
                            initialProfile: _profile,
                            onSave: (p) => setState(() => _profile = p),
                          ),
                        ),
                      );
                      return;
                    }
                    await ref.read(streamControllerProvider.notifier).start(_profile);
                  }
                },
                onSwitchCamera: () {
                  ref.read(streamControllerProvider.notifier).switchCamera();
                },
                onOpenSettings: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                        initialProfile: _profile,
                        onSave: (p) => setState(() => _profile = p),
                      ),
                    ),
                  );
                },
                onAddWebOverlay: () => _showAddUrlDialog(context),
              ),
            ),

            if (stream.errorMessage != null && stream.state == StreamState.error)
              Positioned(
                top: 60,
                left: 16,
                right: 16,
                child: Material(
                  color: Colors.red.shade900.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      stream.errorMessage!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddUrlDialog(BuildContext context) {
    final controller = TextEditingController(text: 'https://');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Adicionar URL interativa', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'https://seu-widget.com',
            hintStyle: TextStyle(color: Colors.white38),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.startsWith('http')) {
                ref.read(overlayProvider.notifier).addWebOverlay(url, interactive: true);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}
