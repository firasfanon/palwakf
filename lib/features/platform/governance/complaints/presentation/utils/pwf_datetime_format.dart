import 'package:flutter/material.dart';

class PwfDateTimeFormat {
  /// Default formatter used across the complaints feature.
  ///
  /// Keeps a consistent UI without forcing every caller to stitch date + time.
  /// Uses the device/localized formatting from [MaterialLocalizations].
  static String format(BuildContext context, DateTime dt) {
    final d = formatShortDate(context, dt);
    final t = formatTime(context, dt);
    return '$d $t';
  }

  static String formatShortDate(BuildContext context, DateTime dt) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatShortDate(dt.toLocal());
  }

  static String formatFullDate(BuildContext context, DateTime dt) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatFullDate(dt.toLocal());
  }

  static String formatTime(BuildContext context, DateTime dt) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(dt.toLocal()),
      alwaysUse24HourFormat: true,
    );
  }
}
