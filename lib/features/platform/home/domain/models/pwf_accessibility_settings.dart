import 'package:flutter/material.dart';

enum PwfAccessibilityPreset { none, senior, kids, recitation }

@immutable
class PwfAccessibilitySettings {
  const PwfAccessibilitySettings({
    required this.fontPx,
    required this.highContrast,
    required this.readingMode,
    required this.preset,
  });

  final int fontPx; // 14..22 step 2 (default 16)
  final bool highContrast;
  final bool readingMode;
  final PwfAccessibilityPreset preset;

  PwfAccessibilitySettings copyWith({
    int? fontPx,
    bool? highContrast,
    bool? readingMode,
    PwfAccessibilityPreset? preset,
  }) {
    return PwfAccessibilitySettings(
      fontPx: fontPx ?? this.fontPx,
      highContrast: highContrast ?? this.highContrast,
      readingMode: readingMode ?? this.readingMode,
      preset: preset ?? this.preset,
    );
  }

  static const PwfAccessibilitySettings initial = PwfAccessibilitySettings(
    fontPx: 16,
    highContrast: false,
    readingMode: false,
    preset: PwfAccessibilityPreset.none,
  );
}
