import 'package:flutter/material.dart';

import 'pwf_prayer_times_widget.dart';

/// Section wrapper for Prayer Times.
///
/// The existing implementation is [PwfPrayerTimesWidget]. This wrapper keeps
/// the dynamic renderer independent from the widget naming.
class PwfPrayerTimesSection extends StatelessWidget {
  const PwfPrayerTimesSection({super.key, this.unitSlug});

  /// Optional unit slug. When null, falls back to 'home'.
  final String? unitSlug;

  @override
  Widget build(BuildContext context) {
    return PwfPrayerTimesWidget(unitSlug: unitSlug ?? 'home');
  }
}
