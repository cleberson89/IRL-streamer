import 'package:flutter/material.dart';
import '../../stream/stream_controller.dart';

class StatsBar extends StatelessWidget {
  final StreamStats stats;
  final StreamState state;

  const StatsBar({super.key, required this.stats, required this.state});

  @override
  Widget build(BuildContext context) {
    final isReconnecting = state == StreamState.reconnecting;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Indicador de estado
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isReconnecting ? Colors.orange : Colors.redAccent,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isReconnecting ? 'RECONECTANDO...' : 'AO VIVO',
            style: TextStyle(
              color: isReconnecting ? Colors.orange : Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          _stat('${stats.currentBitrateKbps}', 'kbps'),
          const SizedBox(width: 12),
          _stat(_formatDuration(stats.uptime), ''),
          const SizedBox(width: 12),
          _qualityChip(stats.connectionQuality),
        ],
      ),
    );
  }

  Widget _stat(String value, String unit) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
          ),
          if (unit.isNotEmpty)
            TextSpan(
              text: ' $unit',
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _qualityChip(String quality) {
    Color color;
    switch (quality) {
      case 'excelente':
        color = Colors.greenAccent;
        break;
      case 'boa':
        color = Colors.lightGreen;
        break;
      case 'ruim':
        color = Colors.orange;
        break;
      case 'crítica':
        color = Colors.redAccent;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        quality.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) return '$h:$m:$s';
    return '$m:$s';
  }
}
