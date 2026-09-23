import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/overlay_item.dart';

class OverlayState {
  final List<OverlayItem> active;
  final List<OverlayItem> presets;

  const OverlayState({
    this.active = const [],
    this.presets = const [],
  });

  OverlayState copyWith({
    List<OverlayItem>? active,
    List<OverlayItem>? presets,
  }) {
    return OverlayState(
      active: active ?? this.active,
      presets: presets ?? this.presets,
    );
  }
}

class OverlayNotifier extends StateNotifier<OverlayState> {
  OverlayNotifier() : super(OverlayState(presets: OverlayPresets.defaultPresets)) {
    // Carrega alguns presets por padrão
    state = state.copyWith(active: [
      OverlayPresets.defaultPresets[0], // LIVE badge
      OverlayPresets.defaultPresets[1], // status bar
    ]);
  }

  void addOverlay(OverlayItem item) {
    if (state.active.any((o) => o.id == item.id)) return;
    state = state.copyWith(active: [...state.active, item]);
  }

  void removeOverlay(String id) {
    state = state.copyWith(
      active: state.active.where((o) => o.id != id).toList(),
    );
  }

  void updateOverlay(OverlayItem updated) {
    state = state.copyWith(
      active: state.active.map((o) => o.id == updated.id ? updated : o).toList(),
    );
  }

  void clearAll() {
    state = state.copyWith(active: []);
  }

  void applyPreset(String presetId) {
    final preset = state.presets.firstWhere(
      (p) => p.id == presetId,
      orElse: () => state.presets.first,
    );
    addOverlay(preset);
  }

  void addWebOverlay(String url, {bool interactive = true}) {
    final id = 'web_${DateTime.now().millisecondsSinceEpoch}';
    addOverlay(OverlayItem(
      id: id,
      type: OverlayType.web,
      url: url,
      alignment: Alignment.bottomLeft,
      widthFactor: 0.4,
      heightFactor: 0.3,
      interactive: interactive,
    ));
  }
}

final overlayProvider = StateNotifierProvider<OverlayNotifier, OverlayState>(
  (ref) => OverlayNotifier(),
);
