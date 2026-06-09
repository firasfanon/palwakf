import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pwf_web_page_scaffold.dart';
import '../widgets/pwf_section_container.dart';
import 'package:waqf/app/routing/app_routes.dart';

class PwfUnderConstructionWebScreen extends StatelessWidget {
  const PwfUnderConstructionWebScreen({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: 'قيد الإنشاء',
      showTitleSection: true,
      child: PwfSectionContainer(
        sectionKey: 'PwfUnderConstructionWebScreen',
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 10),
                    color: Color(0x14000000),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.construction_rounded,
                        color: Color(0xFFC19A50),
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'هذه الصفحة قيد الإنشاء',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F2C55),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'نعمل حاليًا على تجهيز هذه الخدمة ضمن منصة PalWakf بنفس الهوية الموحدة.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.black.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.home),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('العودة إلى الرئيسية'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
