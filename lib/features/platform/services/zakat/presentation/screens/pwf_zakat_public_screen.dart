import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:waqf/features/platform/home/presentation/screens/pwf_web_page_scaffold.dart';
import 'package:waqf/features/platform/public_runtime/presentation/widgets/pwf_public_interactive_tool_shell.dart';

import 'package:waqf/features/platform/services/zakat/domain/pwf_zakat_official_config_contract.dart';

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
              'أداة عامة لحساب الزكاة وفق wrapper رسمي لإعدادات الزكاة مع fallback معلن للتطوير، ضمن نفس عائلة PWF-SIS لباقي صفحات الجمهور.',
          icon: Icons.volunteer_activism_outlined,
          note: PwfZakatOfficialConfigContract.certificationGate,
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
