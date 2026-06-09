part of 'pwf_content_pages.dart';

class PwfPrivacyPolicyWebScreen extends ConsumerWidget {
  const PwfPrivacyPolicyWebScreen({super.key, required this.unitSlug});
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    return _PwfCmsOrFallbackPage(
      unitSlug: unitSlug,
      pageSlug: 'privacy',
      title: isAr ? 'سياسة الخصوصية' : 'Privacy Policy',
      subtitle: isAr
          ? 'مبادئ التعامل مع البيانات عبر البوابة العامة'
          : 'Data handling principles across the public portal',
      sections: [
        _PwfContentSection(
          heading: isAr ? 'النطاق' : 'Scope',
          body: isAr
              ? 'توضح هذه الصفحة كيفية التعامل مع البيانات العامة ورسائل النماذج والاستعلامات المقدمة عبر البوابة العامة.'
              : 'This page explains how public data, form messages, and inquiries submitted through the portal are handled.',
        ),
        _PwfContentSection(
          heading: isAr ? 'الالتزام' : 'Commitment',
          bullets: isAr
              ? const [
                  'حماية البيانات ضمن الحدود القانونية والتنظيمية.',
                  'عدم مشاركة البيانات مع جهات غير مخولة.',
                  'استخدام البيانات لتحسين الخدمة العامة والمتابعة الإدارية فقط.',
                ]
              : const [
                  'Protect data within legal and administrative boundaries.',
                  'Do not share data with unauthorized parties.',
                  'Use data only for service improvement and administrative follow-up.',
                ],
        ),
      ],
      primaryActionLabel: isAr ? 'اتصل بنا' : 'Contact us',
      primaryActionPath: AppRoutes.contact,
    );
  }
}

class PwfTermsOfUseWebScreen extends ConsumerWidget {
  const PwfTermsOfUseWebScreen({super.key, required this.unitSlug});
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    return _PwfCmsOrFallbackPage(
      unitSlug: unitSlug,
      pageSlug: 'terms',
      title: isAr ? 'شروط الاستخدام' : 'Terms of Use',
      subtitle: isAr
          ? 'القواعد العامة للاستفادة من بوابة الوزارة وخدماتها العامة'
          : 'General rules for using the ministry public portal and services',
      sections: [
        _PwfContentSection(
          heading: isAr ? 'الاستخدام المقبول' : 'Acceptable use',
          bullets: isAr
              ? const [
                  'استخدام البوابة للأغراض المشروعة فقط.',
                  'عدم إساءة استخدام النماذج أو الخدمات العامة.',
                  'الالتزام بصحة البيانات المرسلة عبر النماذج العامة.',
                ]
              : const [
                  'Use the portal for lawful purposes only.',
                  'Do not misuse public forms or services.',
                  'Ensure accuracy of information submitted through public forms.',
                ],
        ),
      ],
      primaryActionLabel: isAr ? 'الخدمات' : 'Services',
      primaryActionPath: AppRoutes.services,
    );
  }
}

class PwfSiteMapWebScreen extends ConsumerWidget {
  const PwfSiteMapWebScreen({super.key, required this.unitSlug});
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final page = ref
        .watch(
          pwfSitePageProvider(
            PwfSitePageParam(unitSlug: unitSlug, slug: 'sitemap'),
          ),
        )
        .valueOrNull;
    final title = _cmsPreferredValue(
      isAr: isAr,
      ar: page?.titleAr,
      en: page?.titleEn,
      fallbackAr: 'خريطة الموقع',
      fallbackEn: 'Site Map',
    );
    final subtitle = _cmsPreferredValue(
      isAr: isAr,
      ar: page?.subtitleAr,
      en: page?.subtitleEn,
      fallbackAr: 'دليل سريع للمسارات العامة والخدمات الأساسية داخل المنصة.',
      fallbackEn:
          'A quick guide to public routes and essential platform services.',
    );
    final introBody = _cmsPreferredBody(
      isAr: isAr,
      ar: page?.bodyAr,
      en: page?.bodyEn,
      fallbackAr:
          'تجمع هذه الصفحة أهم الروابط العامة والخدمات الأساسية حتى يصل المستخدم إلى المسار الصحيح بسرعة.',
      fallbackEn:
          'This page gathers the most important public links and essential services so users can reach the correct route quickly.',
    );

    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: title,
      showTitleSection: true,
      child: PwfSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PwfSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.7),
                  ),
                  if (introBody.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      introBody,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.8),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            const _PwfQuickRouteChips(),
          ],
        ),
      ),
    );
  }
}

String _cmsPreferredValue({
  required bool isAr,
  required String? ar,
  required String? en,
  required String fallbackAr,
  required String fallbackEn,
}) {
  final value = (isAr ? ar : en)?.trim() ?? '';
  if (value.isNotEmpty) return value;
  return isAr ? fallbackAr : fallbackEn;
}

String _cmsPreferredBody({
  required bool isAr,
  required String? ar,
  required String? en,
  required String fallbackAr,
  required String fallbackEn,
}) {
  final value = (isAr ? ar : en)?.trim() ?? '';
  if (value.isNotEmpty) return value;
  return isAr ? fallbackAr : fallbackEn;
}

/// Wraps a content page with CMS (DB) override.
///
/// If a CMS page exists in `public.site_pages`, it will be rendered.
/// Otherwise, the fallback (hard-coded) content is shown.
