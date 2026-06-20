import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pwf_web_page_scaffold.dart';
import '../../widgets/pwf_section_container.dart';
import 'package:waqf/features/platform/home/presentation/widgets/shared/pwf_home_visual_contract.dart';
import 'pwf_public_content_shared.dart';

/// Generic HTML-identity page used for public static pages until full CMS binding is ready.
/// Web-only: use inside GoRouter when kIsWeb == true.
class PwfStaticPageWebScreen extends ConsumerWidget {
  const PwfStaticPageWebScreen({
    super.key,
    required this.unitSlug,
    required this.titleAr,
    required this.titleEn,
    this.subtitleAr,
    this.subtitleEn,
    this.icon,
  });

  final String unitSlug;
  final String titleAr;
  final String titleEn;
  final String? subtitleAr;
  final String? subtitleEn;
  final IconData? icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final title = isAr ? titleAr : titleEn;
    final subtitle = isAr ? subtitleAr : subtitleEn;

    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: title,
      child: PwfSectionContainer(
        sectionKey: 'PwfStaticPageWebScreen',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PwfPublicIntroCard(
              title: title,
              subtitle: subtitle?.trim().isNotEmpty == true
                  ? subtitle!
                  : 'صفحة عامة ضمن الهوية البصرية الموحدة للمنصة.',
              icon: icon ?? Icons.article_outlined,
              unitSlug: unitSlug,
              note: null,
            ),
            const SizedBox(height: 22),
            const PwfVisualEmptyState(
              title: 'قيد الربط بالمحتوى الرسمي',
              message:
                  'سيتم نشر محتوى هذه الصفحة عند اكتمال إعدادها واعتمادها للعرض العام.',
              icon: Icons.pending_actions_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
