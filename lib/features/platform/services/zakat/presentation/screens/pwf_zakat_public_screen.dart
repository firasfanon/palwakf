import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:waqf/features/platform/home/presentation/screens/pwf_web_page_scaffold.dart';
import 'package:waqf/features/platform/public_runtime/presentation/widgets/pwf_public_interactive_tool_shell.dart';

import 'pwf_zakat_calculator_screen.dart';

class PwfZakatPublicScreen extends StatelessWidget {
  const PwfZakatPublicScreen({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return PwfWebPageScaffold(
        unitSlug: unitSlug,
        child: PwfPublicInteractiveToolShell(
          unitSlug: unitSlug,
          canonicalRoute: '/home/zakat',
          title: 'الزكاة',
          subtitle:
              'أداة عامة لحساب الزكاة التقديرية، مع شرح مبسط للأنواع الأساسية ومعلومات إرشادية تساعد الجمهور على الفهم والمتابعة.',
          icon: Icons.volunteer_activism_outlined,
          note: null,
          child: PwfZakatCalculatorScreen(
            embedInPublicShell: true,
            showEmbeddedIntro: false,
            unitSlug: unitSlug,
          ),
        ),
      );
    }

    return const PwfZakatCalculatorScreen();
  }
}
