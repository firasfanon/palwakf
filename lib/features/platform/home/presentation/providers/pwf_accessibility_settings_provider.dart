import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/pwf_accessibility_settings.dart';

class PwfAccessibilitySettingsNotifier
    extends StateNotifier<PwfAccessibilitySettings> {
  PwfAccessibilitySettingsNotifier() : super(PwfAccessibilitySettings.initial);

  static const int _minPx = 14;
  static const int _maxPx = 22;
  static const int _step = 2;

  void increaseFont() {
    final next = (state.fontPx + _step).clamp(_minPx, _maxPx);
    state = state.copyWith(fontPx: next, preset: PwfAccessibilityPreset.none);
  }

  void decreaseFont() {
    final next = (state.fontPx - _step).clamp(_minPx, _maxPx);
    state = state.copyWith(fontPx: next, preset: PwfAccessibilityPreset.none);
  }

  void toggleHighContrast() {
    state = state.copyWith(
      highContrast: !state.highContrast,
      preset: PwfAccessibilityPreset.none,
    );
  }

  void toggleReadingMode() {
    state = state.copyWith(
      readingMode: !state.readingMode,
      preset: PwfAccessibilityPreset.none,
    );
  }

  void setPreset(PwfAccessibilityPreset preset) {
    switch (preset) {
      case PwfAccessibilityPreset.senior:
        // senior => font 18 + high contrast + primary purple
        state = state.copyWith(
          preset: preset,
          fontPx: 18,
          highContrast: true,
          readingMode: false,
        );
        return;

      case PwfAccessibilityPreset.kids:
        state = state.copyWith(
          preset: preset,
          fontPx: 16,
          highContrast: false,
          readingMode: false,
        );
        return;

      case PwfAccessibilityPreset.recitation:
        // reading-mode + font 18 (بدون high contrast)
        state = state.copyWith(
          preset: preset,
          fontPx: 18,
          highContrast: false,
          readingMode: true,
        );
        return;

      case PwfAccessibilityPreset.none:
        reset();
        return;
    }
  }

  void reset() {
    state = PwfAccessibilitySettings.initial;
  }
}

final pwfAccessibilitySettingsProvider =
    StateNotifierProvider<
      PwfAccessibilitySettingsNotifier,
      PwfAccessibilitySettings
    >((ref) => PwfAccessibilitySettingsNotifier());
