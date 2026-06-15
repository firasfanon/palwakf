// ignore_for_file: unused_element_parameter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/core/layout/pwf_global_layout_contract.dart';
import 'package:waqf/features/platform/media_center/data/models/pwf_platform_center_content_item.dart';
import 'package:waqf/features/platform/media_center/presentation/providers/pwf_platform_center_content_providers.dart';

import '../../theme/pwf_home_palette.dart';
import '../pwf_section_container.dart';
import '../shared/pwf_section_title.dart';

class PwfMediaCenterHighlightsSection extends StatelessWidget {
  const PwfMediaCenterHighlightsSection({
    super.key,
    required this.unitSlug,
    this.sectionSettings = const {},
  });

  final String unitSlug;
  final Map<String, dynamic> sectionSettings;

  @override
  Widget build(BuildContext context) => _PwfPlatformCenterSection(
    unitSlug: unitSlug,
    sectionSettings: sectionSettings,
    spec: _Specs.mediaCenter,
  );
}

class PwfServicesCenterHighlightsSection extends StatelessWidget {
  const PwfServicesCenterHighlightsSection({
    super.key,
    required this.unitSlug,
    this.sectionSettings = const {},
  });

  final String unitSlug;
  final Map<String, dynamic> sectionSettings;

  @override
  Widget build(BuildContext context) => _PwfPlatformCenterSection(
    unitSlug: unitSlug,
    sectionSettings: sectionSettings,
    spec: _Specs.servicesCenter,
  );
}

class PwfSocialPostsHomeSection extends StatelessWidget {
  const PwfSocialPostsHomeSection({
    super.key,
    required this.unitSlug,
    this.sectionSettings = const {},
  });

  final String unitSlug;
  final Map<String, dynamic> sectionSettings;

  @override
  Widget build(BuildContext context) => _PwfPlatformCenterSection(
    unitSlug: unitSlug,
    sectionSettings: sectionSettings,
    spec: _Specs.socialPosts,
  );
}

class PwfPressReleasesHomeSection extends StatelessWidget {
  const PwfPressReleasesHomeSection({
    super.key,
    required this.unitSlug,
    this.sectionSettings = const {},
  });

  final String unitSlug;
  final Map<String, dynamic> sectionSettings;

  @override
  Widget build(BuildContext context) => _PwfPlatformCenterSection(
    unitSlug: unitSlug,
    sectionSettings: sectionSettings,
    spec: _Specs.pressReleases,
  );
}

class PwfOfficialStatementsHomeSection extends StatelessWidget {
  const PwfOfficialStatementsHomeSection({
    super.key,
    required this.unitSlug,
    this.sectionSettings = const {},
  });

  final String unitSlug;
  final Map<String, dynamic> sectionSettings;

  @override
  Widget build(BuildContext context) => _PwfPlatformCenterSection(
    unitSlug: unitSlug,
    sectionSettings: sectionSettings,
    spec: _Specs.officialStatements,
  );
}

class PwfAwarenessCampaignsHomeSection extends StatelessWidget {
  const PwfAwarenessCampaignsHomeSection({
    super.key,
    required this.unitSlug,
    this.sectionSettings = const {},
  });

  final String unitSlug;
  final Map<String, dynamic> sectionSettings;

  @override
  Widget build(BuildContext context) => _PwfPlatformCenterSection(
    unitSlug: unitSlug,
    sectionSettings: sectionSettings,
    spec: _Specs.awarenessCampaigns,
  );
}

class PwfSanctitiesObservatoryHomeSection extends StatelessWidget {
  const PwfSanctitiesObservatoryHomeSection({
    super.key,
    required this.unitSlug,
    this.sectionSettings = const {},
  });

  final String unitSlug;
  final Map<String, dynamic> sectionSettings;

  @override
  Widget build(BuildContext context) => _PwfPlatformCenterSection(
    unitSlug: unitSlug,
    sectionSettings: sectionSettings,
    spec: _Specs.sanctitiesObservatory,
  );
}

class PwfLegalReferencesHomeSection extends StatelessWidget {
  const PwfLegalReferencesHomeSection({
    super.key,
    required this.unitSlug,
    this.sectionSettings = const {},
  });

  final String unitSlug;
  final Map<String, dynamic> sectionSettings;

  @override
  Widget build(BuildContext context) => _PwfPlatformCenterSection(
    unitSlug: unitSlug,
    sectionSettings: sectionSettings,
    spec: _Specs.legalReferences,
  );
}

class PwfEventsHomeSection extends StatelessWidget {
  const PwfEventsHomeSection({
    super.key,
    required this.unitSlug,
    this.sectionSettings = const {},
  });

  final String unitSlug;
  final Map<String, dynamic> sectionSettings;

  @override
  Widget build(BuildContext context) => _PwfPlatformCenterSection(
    unitSlug: unitSlug,
    sectionSettings: sectionSettings,
    spec: _Specs.events,
  );
}

class _PwfPlatformCenterSection extends ConsumerWidget {
  const _PwfPlatformCenterSection({
    required this.unitSlug,
    required this.sectionSettings,
    required this.spec,
  });

  final String unitSlug;
  final Map<String, dynamic> sectionSettings;
  final _CenterSectionSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnit =
        unitSlug.trim().isNotEmpty && unitSlug.trim().toLowerCase() != 'home';
    final title = isUnit ? '${spec.title} — صفحة الوحدة' : spec.title;
    final subtitle = isUnit
        ? spec.unitSubtitle
        : spec.subtitle;

    return PwfSectionContainer(
      sectionKey: spec.sectionKey,
      verticalPadding: 42,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PwfSectionTitle(title: title, subtitle: subtitle),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1050 ? 3 : (width >= 720 ? 2 : 1);
              final cardWidth = (width - (columns - 1) * 18) / columns;
              return Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  for (final card in spec.cards)
                    SizedBox(
                      width: cardWidth,
                      child: _CenterCard(card: card, unitSlug: unitSlug),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          _HomepagePublishedItemsStrip(
            query: PwfPlatformCenterContentQuery(
              familyKey: spec.familyKey,
              unitSlug: unitSlug,
              publishedOnly: true,
              limit: _sectionLimit(sectionSettings),
            ),
          ),
          const SizedBox(height: 18),
          _SectionGovernanceStrip(spec: spec, unitSlug: unitSlug),
        ],
      ),
    );
  }
}

class _CenterCard extends StatelessWidget {
  const _CenterCard({required this.card, required this.unitSlug});

  final _CenterCardSpec card;
  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    final target = _scopedRoute(card.route, unitSlug);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => context.go(target),
      child: Container(
        constraints: const BoxConstraints(minHeight: 168),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: PwfHomePalette.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: PwfHomePalette.border),
          boxShadow: PwfHomeShadows.card,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: card.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(card.icon, color: card.accent),
            ),
            const SizedBox(height: 14),
            Text(
              card.title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: PwfHomePalette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              card.description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: PwfHomePalette.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    card.actionLabel,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: card.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_back_rounded, size: 18, color: card.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomepagePublishedItemsStrip extends ConsumerWidget {
  const _HomepagePublishedItemsStrip({required this.query});

  final PwfPlatformCenterContentQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(pwfPlatformCenterContentListProvider(query));
    return asyncItems.when(
      loading: () => const LinearProgressIndicator(minHeight: 3),
      error: (error, stackTrace) => _HomepageDataBindingNote(
        title: 'تعذر تحميل العناصر المنشورة',
        body: error.toString(),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const _HomepageDataBindingNote(
            title: 'لا توجد عناصر منشورة لهذا القسم',
            body:
                'يبقى ظهور القسم محكومًا بـ homepage_sections، لكن عناصر المحتوى تحتاج مصدر بيانات منشور.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'أحدث العناصر المنشورة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: PwfHomePalette.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1050
                    ? 3
                    : (constraints.maxWidth >= 720 ? 2 : 1);
                const spacing = 12.0;
                final width = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - (columns - 1) * spacing) /
                          columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final item in items)
                      SizedBox(
                        width: width,
                        child: _HomepagePublishedItemCard(item: item),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _HomepagePublishedItemCard extends StatelessWidget {
  const _HomepagePublishedItemCard({required this.item});

  final PwfPlatformCenterContentItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: item.route.trim().isEmpty ? null : () => context.go(item.route),
      child: Container(
        constraints: const BoxConstraints(minHeight: 132),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: PwfHomePalette.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pill(icon: Icons.apartment_outlined, label: item.ownerName),
                const _Pill(
                  icon: Icons.verified_outlined,
                  label: 'منشور',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: PwfHomePalette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: PwfHomePalette.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomepageDataBindingNote extends StatelessWidget {
  const _HomepageDataBindingNote({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF78350F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(color: Color(0xFF92400E), height: 1.5),
          ),
        ],
      ),
    );
  }
}

int _sectionLimit(Map<String, dynamic> settings) {
  final value =
      settings['limit'] ?? settings['show_count'] ?? settings['max_items'];
  if (value is int && value > 0) return value;
  if (value is num && value > 0) return value.toInt();
  final parsed = int.tryParse(value?.toString() ?? '');
  if (parsed != null && parsed > 0) return parsed;
  return 3;
}

class _SectionGovernanceStrip extends StatelessWidget {
  const _SectionGovernanceStrip({required this.spec, required this.unitSlug});

  final _CenterSectionSpec spec;
  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    // Governance metadata remains available in admin/docs. Public pages should
    // not expose source keys, data contracts, or homepage_sections internals.
    return const SizedBox.shrink();
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return PwfSafePill(
      icon: icon,
      label: label,
      maxWidth: 220,
      foreground: PwfHomePalette.primary,
      borderColor: PwfHomePalette.border,
    );
  }
}

String _scopedRoute(String route, String unitSlug) {
  final normalized = unitSlug.trim().toLowerCase();
  if (normalized.isEmpty || normalized == 'home') return route;
  if (!route.startsWith('/')) return '/$normalized/$route';
  return '/$normalized${route == '/home' ? '' : route}';
}

class _CenterSectionSpec {
  const _CenterSectionSpec({
    required this.sectionKey,
    required this.familyKey,
    required this.title,
    required this.subtitle,
    required this.unitSubtitle,
    required this.dataContract,
    required this.cards,
  });

  final String sectionKey;
  final String familyKey;
  final String title;
  final String subtitle;
  final String unitSubtitle;
  final String dataContract;
  final List<_CenterCardSpec> cards;
}

class _CenterCardSpec {
  const _CenterCardSpec({
    required this.title,
    required this.description,
    required this.route,
    required this.icon,
    this.actionLabel = 'عرض التفاصيل',
    this.accent = PwfHomePalette.primary,
  });

  final String title;
  final String description;
  final String route;
  final IconData icon;
  final String actionLabel;
  final Color accent;
}

class _Specs {
  static const mediaCenter = _CenterSectionSpec(
    sectionKey: 'pwf_media_center_highlights',
    familyKey: 'media_center',
    title: 'مختارات المركز الإعلامي',
    subtitle:
        'أبرز العائلات الإعلامية التي تُدار من المركز الإعلامي وتظهر حسب النطاق والترتيب المعتمد.',
    unitSubtitle:
        'مختارات إعلامية خاصة بالوحدة مع إبراز ما تسمح به إدارة الصفحة.',
    dataContract: 'public.homepage_sections + media center families',
    cards: [
      _CenterCardSpec(
        title: 'الاجتماعيات',
        description: 'تهاني وتعازي ومناسبات اجتماعية بصياغة إعلامية رسمية.',
        route: AppRoutes.socialPosts,
        icon: Icons.groups_2_outlined,
      ),
      _CenterCardSpec(
        title: 'البيانات الصحفية',
        description:
            'بيانات رسمية قابلة للأرشفة والاستشهاد حسب الموضوع والجهة.',
        route: AppRoutes.pressReleases,
        icon: Icons.article_outlined,
      ),
      _CenterCardSpec(
        title: 'مرصد حماية المقدسات',
        description: 'رصد موثق للوقائع والانتهاكات مع مؤشرات وتقارير رسمية.',
        route: AppRoutes.sanctitiesObservatory,
        icon: Icons.shield_outlined,
        accent: PwfHomePalette.royalRed,
      ),
    ],
  );

  static const servicesCenter = _CenterSectionSpec(
    sectionKey: 'pwf_services_center_highlights',
    familyKey: 'services_center',
    title: 'مختارات مركز الخدمات',
    subtitle:
        'مدخل موحد لخدمات الجمهور والخدمات الإلكترونية والمراجع الرسمية دون خلطها مع المحتوى الإعلامي.',
    unitSubtitle: 'خدمات وروابط مخصصة للوحدة ضمن نفس البنية الديناميكية.',
    dataContract: 'public.v_services_catalog_compat_v1 + homepage_sections',
    cards: [
      _CenterCardSpec(
        title: 'دليل الخدمات',
        description: 'كتالوج خدمات الجمهور المعتمد ومداخل تقديم الطلبات.',
        route: AppRoutes.services,
        icon: Icons.support_agent_outlined,
      ),
      _CenterCardSpec(
        title: 'الخدمات الإلكترونية',
        description: 'بوابة الخدمات الرقمية والنماذج والتتبع.',
        route: AppRoutes.eservices,
        icon: Icons.language_outlined,
      ),
      _CenterCardSpec(
        title: 'المراجع الرسمية',
        description: 'القوانين والأنظمة والتعليمات والنماذج ذات العلاقة.',
        route: AppRoutes.legalReferences,
        icon: Icons.gavel_outlined,
      ),
    ],
  );

  static const socialPosts = _CenterSectionSpec(
    sectionKey: 'pwf_social_posts_section',
    familyKey: 'social_posts',
    title: 'الاجتماعيات',
    subtitle:
        'محتوى اجتماعي إعلامي رسمي مثل التهاني والتعازي والمناسبات، وليس خدمات اجتماعية.',
    unitSubtitle: 'اجتماعيات الوحدة تظهر ضمن نفس renderer وبنطاق واضح.',
    dataContract: 'media family: social_posts',
    cards: [
      _CenterCardSpec(
        title: 'تهاني رسمية',
        description: 'تهاني مرتبطة بالمناسبات العامة والمؤسسية.',
        route: AppRoutes.socialPosts,
        icon: Icons.celebration_outlined,
      ),
      _CenterCardSpec(
        title: 'تعازي ومواساة',
        description: 'تعازي بصياغة حكومية منضبطة ومراجعة.',
        route: AppRoutes.socialPosts,
        icon: Icons.volunteer_activism_outlined,
      ),
      _CenterCardSpec(
        title: 'مناسبات اجتماعية',
        description: 'محتوى اجتماعي يخص الوزارة أو الوحدة المالكة.',
        route: AppRoutes.socialPosts,
        icon: Icons.event_note_outlined,
      ),
    ],
  );

  static const pressReleases = _CenterSectionSpec(
    sectionKey: 'pwf_press_releases_section',
    familyKey: 'press_releases',
    title: 'البيانات الصحفية',
    subtitle: 'بيانات رسمية معتمدة توضح موقف المؤسسة وتخضع للمراجعة الإعلامية.',
    unitSubtitle: 'بيانات الوحدة تظهر حسب الصلاحية والنطاق.',
    dataContract: 'media family: press_releases',
    cards: [
      _CenterCardSpec(
        title: 'بيانات الوزارة',
        description: 'بيانات مركزية صادرة عن الوزارة أو الناطق الرسمي.',
        route: AppRoutes.pressReleases,
        icon: Icons.account_balance_outlined,
      ),
      _CenterCardSpec(
        title: 'بيانات الوحدات',
        description: 'بيانات نطاقية بعد الاعتماد المركزي عند الحاجة.',
        route: AppRoutes.pressReleases,
        icon: Icons.business_outlined,
      ),
      _CenterCardSpec(
        title: 'الأرشيف الصحفي',
        description: 'أرشفة وبحث حسب التاريخ والموضوع والحالة.',
        route: AppRoutes.pressReleases,
        icon: Icons.folder_copy_outlined,
      ),
    ],
  );

  static const officialStatements = _CenterSectionSpec(
    sectionKey: 'pwf_official_statements_section',
    familyKey: 'official_statements',
    title: 'التصريحات الرسمية',
    subtitle: 'تصريحات من جهات مخولة مع ضبط المتحدث والصفة والموضوع.',
    unitSubtitle: 'تصريحات مرتبطة بالوحدة ضمن صلاحيات النشر.',
    dataContract: 'media family: official_statements',
    cards: [
      _CenterCardSpec(
        title: 'تصريحات عامة',
        description: 'تصريحات قصيرة أو موسعة قابلة للنشر العام.',
        route: AppRoutes.officialStatements,
        icon: Icons.campaign_outlined,
      ),
      _CenterCardSpec(
        title: 'تصريحات حسب الموضوع',
        description: 'تصنيف التصريحات حسب الملف أو المناسبة أو القضية.',
        route: AppRoutes.officialStatements,
        icon: Icons.topic_outlined,
      ),
      _CenterCardSpec(
        title: 'تصريحات الوحدات',
        description: 'تصريحات محددة النطاق تظهر ضمن صفحات الوحدات.',
        route: AppRoutes.officialStatements,
        icon: Icons.account_tree_outlined,
      ),
    ],
  );

  static const awarenessCampaigns = _CenterSectionSpec(
    sectionKey: 'pwf_awareness_campaigns_section',
    familyKey: 'awareness_campaigns',
    title: 'الحملات التوعوية',
    subtitle: 'حملات ذات هدف ورسائل وجمهور وفترة نشر ومواد إعلامية مرتبطة.',
    unitSubtitle: 'حملات توعوية مخصصة للوحدة أو مشتركة مع المركز.',
    dataContract: 'media family: awareness_campaigns',
    cards: [
      _CenterCardSpec(
        title: 'حملات إرشادية',
        description: 'رسائل توعوية مرتبطة برسالة المؤسسة وخدماتها.',
        route: AppRoutes.awarenessCampaigns,
        icon: Icons.menu_book_outlined,
      ),
      _CenterCardSpec(
        title: 'حماية المقدسات',
        description: 'مواد توعوية مرتبطة بمرصد حماية المقدسات.',
        route: AppRoutes.sanctitiesObservatory,
        icon: Icons.shield_outlined,
        accent: PwfHomePalette.royalRed,
      ),
      _CenterCardSpec(
        title: 'مكتبة المواد',
        description: 'مواد صور وفيديو ونشرات مرتبطة بالحملة.',
        route: AppRoutes.mediaCenter,
        icon: Icons.photo_library_outlined,
      ),
    ],
  );

  static const sanctitiesObservatory = _CenterSectionSpec(
    sectionKey: 'pwf_sanctities_observatory_section',
    familyKey: 'sanctities_observatory',
    title: 'مرصد حماية المقدسات',
    subtitle:
        'مرصد موثق للوقائع والانتهاكات على المقدسات والأماكن الوقفية مع مراجعة وأدلة.',
    unitSubtitle: 'وقائع أو مؤشرات مرتبطة بنطاق الوحدة ومرتبطة بملفاتها العامة.',
    dataContract: 'public.sanctities_observatory + document_intelligence links',
    cards: [
      _CenterCardSpec(
        title: 'سجل الوقائع',
        description: 'وقائع مصنفة حسب المكان والنوع والتاريخ ودرجة التحقق.',
        route: AppRoutes.sanctitiesObservatory,
        icon: Icons.article_outlined,
        accent: PwfHomePalette.royalRed,
      ),
      _CenterCardSpec(
        title: 'المواقع المشمولة',
        description:
            'الأقصى، الحرم الإبراهيمي، المساجد، المقامات، والمقابر الوقفية.',
        route: AppRoutes.sanctitiesObservatory,
        icon: Icons.location_on_outlined,
        accent: PwfHomePalette.royalRed,
      ),
      _CenterCardSpec(
        title: 'التقارير الرسمية',
        description: 'تقارير شهرية أو خاصة قابلة للنشر والاستشهاد المؤسسي.',
        route: AppRoutes.sanctitiesObservatory,
        icon: Icons.summarize_outlined,
        accent: PwfHomePalette.royalRed,
      ),
    ],
  );

  static const legalReferences = _CenterSectionSpec(
    sectionKey: 'pwf_legal_references_section',
    familyKey: 'legal_references',
    title: 'الأنظمة والقوانين والتعليمات',
    subtitle:
        'مرجع حكومي رسمي للقوانين والأنظمة والتعليمات والتعاميم والنماذج، وليس محتوى إعلاميًا.',
    unitSubtitle: 'مراجع رسمية مرتبطة بنطاق الوحدة أو بعملها.',
    dataContract: 'legal references + document intelligence links',
    cards: [
      _CenterCardSpec(
        title: 'القوانين والأنظمة',
        description: 'فهرسة القوانين واللوائح ذات العلاقة بالمؤسسة.',
        route: AppRoutes.legalReferences,
        icon: Icons.balance_outlined,
      ),
      _CenterCardSpec(
        title: 'التعليمات والتعاميم',
        description: 'تعليمات عامة أو داخلية حسب النطاق والصلاحية.',
        route: AppRoutes.legalReferences,
        icon: Icons.rule_folder_outlined,
      ),
      _CenterCardSpec(
        title: 'النماذج الرسمية',
        description: 'نماذج وأدلة إجرائية مرتبطة بالخدمات ومركز الوثائق.',
        route: AppRoutes.legalReferences,
        icon: Icons.description_outlined,
      ),
    ],
  );

  static const events = _CenterSectionSpec(
    sectionKey: 'pwf_events_section',
    familyKey: 'events',
    title: 'الفعاليات',
    subtitle:
        'أحداث لها تاريخ ومكان وحضور وحالة، منفصلة وظيفيًا عن الأنشطة المؤسسية.',
    unitSubtitle: 'فعاليات الوحدة تعرض حسب نطاقها وحالتها.',
    dataContract: 'public.activities(type=event)',
    cards: [
      _CenterCardSpec(
        title: 'فعاليات قادمة',
        description: 'عرض الفعاليات ذات الموعد والمكان والحالة القادمة.',
        route: AppRoutes.events,
        icon: Icons.event_available_outlined,
      ),
      _CenterCardSpec(
        title: 'فعاليات منتهية',
        description: 'أرشفة الفعاليات المنتهية مع التغطيات والنتائج.',
        route: AppRoutes.events,
        icon: Icons.event_busy_outlined,
      ),
      _CenterCardSpec(
        title: 'التسجيل والحضور',
        description: 'حالة التسجيل أو الحضور عند الحاجة وحسب طبيعة الفعالية.',
        route: AppRoutes.events,
        icon: Icons.how_to_reg_outlined,
      ),
    ],
  );
}
