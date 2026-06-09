import 'package:flutter/material.dart';

class PalWakfSisContrast {
  const PalWakfSisContrast._();

  static Color onSurface(Color background) {
    return background.computeLuminance() > 0.55
        ? const Color(0xFF172033)
        : const Color(0xFFFBF8EF);
  }

  static bool hasReadableContrast(Color foreground, Color background) {
    final l1 = foreground.computeLuminance() + 0.05;
    final l2 = background.computeLuminance() + 0.05;
    final ratio = l1 > l2 ? l1 / l2 : l2 / l1;
    return ratio >= 4.5;
  }
}
