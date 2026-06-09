import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:waqf/features/platform/home/presentation/screens/pwf_web_page_scaffold.dart';

import '../pages/pwf_prayer_times_page.dart';

class PwfPrayerTimesPublicScreen extends StatelessWidget {
  const PwfPrayerTimesPublicScreen({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return PwfWebPageScaffold(
        unitSlug: unitSlug,
        child: PwfPrayerTimesPage(embedInPublicShell: true, unitSlug: unitSlug),
      );
    }

    return const PwfPrayerTimesPage();
  }
}
