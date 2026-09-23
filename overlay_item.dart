import 'package:flutter/material.dart';

enum OverlayType { text, image, web, statusBar }

class OverlayItem {
  final String id;
  final OverlayType type;
  final String? text;
  final String? imagePath; // asset ou file
  final String? url; // para web
  final Alignment alignment;
  final double widthFactor; // 0.0 - 1.0 relativo à tela
  final double heightFactor;
  final double opacity;
  final bool interactive; // se o streamer pode tocar (só faz sentido para web)
  final Map<String, dynamic>? style; // cor, tamanho de fonte etc.

  const OverlayItem({
    required this.id,
    required this.type,
    this.text,
    this.imagePath,
    this.url,
    this.alignment = Alignment.topLeft,
    this.widthFactor = 0.3,
    this.heightFactor = 0.15,
    this.opacity = 1.0,
    this.interactive = false,
    this.style,
  });

  OverlayItem copyWith({
    Alignment? alignment,
    double? widthFactor,
    double? heightFactor,
    double? opacity,
    bool? interactive,
  }) {
    return OverlayItem(
      id: id,
      type: type,
      text: text,
      imagePath: imagePath,
      url: url,
      alignment: alignment ?? this.alignment,
      widthFactor: widthFactor ?? this.widthFactor,
      heightFactor: heightFactor ?? this.heightFactor,
      opacity: opacity ?? this.opacity,
      interactive: interactive ?? this.interactive,
      style: style,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'text': text,
        'imagePath': imagePath,
        'url': url,
        'alignment': alignment.toString(),
        'widthFactor': widthFactor,
        'heightFactor': heightFactor,
        'opacity': opacity,
        'interactive': interactive,
        'style': style,
      };

  factory OverlayItem.fromJson(Map<String, dynamic> json) {
    return OverlayItem(
      id: json['id'] as String,
      type: OverlayType.values.firstWhere((e) => e.name == json['type']),
      text: json['text'] as String?,
      imagePath: json['imagePath'] as String?,
      url: json['url'] as String?,
      alignment: _parseAlignment(json['alignment'] as String?),
      widthFactor: (json['widthFactor'] as num?)?.toDouble() ?? 0.3,
      heightFactor: (json['heightFactor'] as num?)?.toDouble() ?? 0.15,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      interactive: json['interactive'] as bool? ?? false,
      style: json['style'] as Map<String, dynamic>?,
    );
  }

  static Alignment _parseAlignment(String? value) {
    switch (value) {
      case 'Alignment.topLeft':
        return Alignment.topLeft;
      case 'Alignment.topRight':
        return Alignment.topRight;
      case 'Alignment.bottomLeft':
        return Alignment.bottomLeft;
      case 'Alignment.bottomRight':
        return Alignment.bottomRight;
      case 'Alignment.center':
        return Alignment.center;
      default:
        return Alignment.topLeft;
    }
  }
}

/// Presets prontos para IRL
class OverlayPresets {
  static List<OverlayItem> get defaultPresets => [
        const OverlayItem(
          id: 'live_badge',
          type: OverlayType.text,
          text: '● LIVE',
          alignment: Alignment.topLeft,
          widthFactor: 0.25,
          heightFactor: 0.08,
          style: {'color': 0xFFE53935, 'fontSize': 18, 'fontWeight': 'bold'},
        ),
        const OverlayItem(
          id: 'status_bar',
          type: OverlayType.statusBar,
          alignment: Alignment.topRight,
          widthFactor: 0.4,
          heightFactor: 0.1,
        ),
        const OverlayItem(
          id: 'logo',
          type: OverlayType.image,
          imagePath: 'assets/overlays/logo_placeholder.png',
          alignment: Alignment.bottomRight,
          widthFactor: 0.2,
          heightFactor: 0.12,
          opacity: 0.85,
        ),
        // Exemplo de URL interativa (o streamer pode tocar)
        const OverlayItem(
          id: 'web_widget',
          type: OverlayType.web,
          url: 'https://example.com',
          alignment: Alignment.bottomLeft,
          widthFactor: 0.45,
          heightFactor: 0.35,
          interactive: true,
          opacity: 0.95,
        ),
      ];
}
