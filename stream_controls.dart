import 'package:flutter/material.dart';
import '../../stream/stream_controller.dart';

class StreamControls extends StatelessWidget {
  final StreamState streamState;
  final VoidCallback onToggleLive;
  final VoidCallback onSwitchCamera;
  final VoidCallback onOpenSettings;
  final VoidCallback onAddWebOverlay;

  const StreamControls({
    super.key,
    required this.streamState,
    required this.onToggleLive,
    required this.onSwitchCamera,
    required this.onOpenSettings,
    required this.onAddWebOverlay,
  });

  bool get isLive =>
      streamState == StreamState.live ||
      streamState == StreamState.connecting ||
      streamState == StreamState.reconnecting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _roundButton(
            icon: Icons.cameraswitch_rounded,
            onTap: onSwitchCamera,
            tooltip: 'Trocar câmera',
          ),
          _roundButton(
            icon: Icons.add_link_rounded,
            onTap: onAddWebOverlay,
            tooltip: 'Adicionar URL',
          ),
          // Botão principal LIVE
          GestureDetector(
            onTap: onToggleLive,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLive ? Colors.red.shade700 : Colors.red.shade600,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(
                isLive ? Icons.stop_rounded : Icons.fiber_manual_record,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          _roundButton(
            icon: Icons.settings_rounded,
            onTap: onOpenSettings,
            tooltip: 'Configurações',
          ),
          _roundButton(
            icon: Icons.layers_rounded,
            onTap: () {
              // TODO: abrir painel de overlays
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Painel de overlays em breve')),
              );
            },
            tooltip: 'Overlays',
          ),
        ],
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.white12,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}
