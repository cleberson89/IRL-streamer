import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../models/overlay_item.dart';

class OverlayLayer extends StatelessWidget {
  final List<OverlayItem> items;

  const OverlayLayer({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: items.map((item) {
            final w = constraints.maxWidth * item.widthFactor;
            final h = constraints.maxHeight * item.heightFactor;

            return Align(
              alignment: item.alignment,
              child: Opacity(
                opacity: item.opacity,
                child: SizedBox(
                  width: w,
                  height: h,
                  child: _buildContent(item),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildContent(OverlayItem item) {
    switch (item.type) {
      case OverlayType.text:
        final color = Color(item.style?['color'] as int? ?? 0xFFFFFFFF);
        final fontSize = (item.style?['fontSize'] as num?)?.toDouble() ?? 16;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            item.text ?? '',
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
            ),
          ),
        );

      case OverlayType.image:
        if (item.imagePath == null) return const SizedBox.shrink();
        return Image.asset(
          item.imagePath!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.white54),
        );

      case OverlayType.web:
        if (item.url == null) return const SizedBox.shrink();
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(Uri.parse(item.url!)),
          ),
        );

      case OverlayType.statusBar:
        // Renderizado pela StatsBar real, este é só placeholder
        return const SizedBox.shrink();
    }
  }
}
