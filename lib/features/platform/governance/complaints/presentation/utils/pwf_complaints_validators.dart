import 'package:flutter/widgets.dart';

import '../l10n/pwf_complaints_strings.dart';

class PwfComplaintsValidators {
  static FormFieldValidator<String> requiredField(BuildContext context) {
    final s = PwfComplaintsStrings.of(context);
    return (v) {
      if (v == null) return s.t('complaints.validation.required');
      if (v.trim().isEmpty) return s.t('complaints.validation.required');
      return null;
    };
  }

  static FormFieldValidator<String> email(BuildContext context) {
    final s = PwfComplaintsStrings.of(context);
    return (v) {
      final value = (v ?? '').trim();
      if (value.isEmpty) return s.t('complaints.validation.required');
      if (!isValidEmail(value)) return s.t('complaints.validation.email');
      return null;
    };
  }

  static bool isValidEmail(String v) {
    final s = v.trim();
    if (s.isEmpty) return false;
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(s);
  }

  static bool isValidReference(String v) {
    final s = v.trim().toUpperCase();
    final re = RegExp(r'^REF\d{8}$');
    return re.hasMatch(s);
  }
}
