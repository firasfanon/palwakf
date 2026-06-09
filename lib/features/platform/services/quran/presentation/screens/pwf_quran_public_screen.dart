import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:waqf/features/platform/home/presentation/screens/pwf_web_page_scaffold.dart';
import '../pages/pwf_quran_page.dart';

class PwfQuranPublicScreen extends StatelessWidget {
  const PwfQuranPublicScreen({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return PwfWebPageScaffold(
        unitSlug: unitSlug,
        child: PwfQuranPage(embedInPublicShell: true, unitSlug: unitSlug),
      );
    }
    return const PwfQuranPage();
  }
}
