import 'package:flutter/material.dart';

import '../../../core/theme/palwakf_sis_contrast.dart';

class PwfVisualIdentityContrastGate {
  const PwfVisualIdentityContrastGate();

  PwfVisualIdentityContrastResult evaluate({
    required Color foreground,
    required Color background,
  }) {
    final passed = PalWakfSisContrast.hasReadableContrast(
      foreground,
      background,
    );
    return PwfVisualIdentityContrastResult(
      passed: passed,
      message: passed
          ? 'التباين مقبول للنشر.'
          : 'التباين غير كافٍ. لا يجوز نشر هذا override.',
    );
  }
}

class PwfVisualIdentityContrastResult {
  const PwfVisualIdentityContrastResult({
    required this.passed,
    required this.message,
  });

  final bool passed;
  final String message;
}
