import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../data/models/pwf_public_service_catalog_item.dart';
import '../../../data/providers/pwf_public_services_catalog_providers.dart';
import '../../screens/pages/pwf_public_content_shared.dart';
import '../pwf_section_container.dart';
import '../shared/pwf_section_title.dart';

class PwfPublicServicesCatalogSection extends ConsumerWidget {
  const PwfPublicServicesCatalogSection({
    super.key,
    required this.unitSlug,
    this.sectionSettings = const <String, dynamic>{},
    this.showEmptyState = false,
  });

  final String unitSlug;
  final Map<String, dynamic> sectionSettings;

  /// Homepage/unit dynamic sections should fail closed visually when the DB
  /// catalog is unavailable. The direct `/services` page may opt in to a clear
  /// operational empty state so UAT can distinguish "no rows" from a crash.
  final bool showEmptyState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Visibility is intentionally NOT gated by `unitSlug` here.
    // The dynamic homepage renderer receives rows already filtered/merged from
    // `public.homepage_sections` for the active scope. Therefore, if an admin
    // enables `pwf_public_services_catalog` for a unit scope, the same dynamic
    // page engine may render it for that unit. This widget only renders the
    // catalog data source (`public.v_services_catalog_compat_v1`); scope visibility belongs to DB.
    final catalogAsync = ref.watch(pwfPublicServicesCatalogProvider);

    return catalogAsync.when(
      loading: () => const PwfSectionContainer(
        sectionKey: 'PwfPublicServicesCatalogSection.loading',
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (_, __) => showEmptyState
          ? _PwfPublicServicesCatalogEmptyState(
              title: _stringSetting('title', 'كتالوج خدمات الجمهور المعتمد'),
            )
          : const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) {
          return showEmptyState
              ? _PwfPublicServicesCatalogEmptyState(
                  title: _stringSetting(
                    'title',
                    'كتالوج خدمات الجمهور المعتمد',
                  ),
                )
              : const SizedBox.shrink();
        }

        return PwfSectionContainer(
          sectionKey: 'PwfPublicServicesCatalogSection',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PwfSectionTitle(
                title: _stringSetting('title', 'كتالوج خدمات الجمهور المعتمد'),
                subtitle: _stringSetting(
                  'subtitle',
                  'هذه البطاقات تُقرأ عبر واجهة التوافق public.v_services_catalog_compat_v1 بعد تفعيل B-1A.0، ولا تشمل خدمات العقارات الوقفية أو خدمات الوحدات scoped.',
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: _PwfServicesCatalogMetaChip(
                  count: items.length,
                  unitSlug: unitSlug,
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width >= 1120
                      ? 3
                      : width >= 760
                      ? 2
                      : 1;
                  const spacing = 16.0;
                  final itemWidth = columns == 1
                      ? width
                      : (width - ((columns - 1) * spacing)) / columns;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (final item in items)
                        SizedBox(
                          width: itemWidth,
                          child: _PwfPublicServiceCatalogCard(item: item),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _stringSetting(String key, String fallback) {
    final value = sectionSettings[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }
}

class _PwfPublicServicesCatalogEmptyState extends StatelessWidget {
  const _PwfPublicServicesCatalogEmptyState({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return PwfSectionContainer(
      sectionKey: 'PwfPublicServicesCatalogSection.empty',
      child: PwfSurfaceCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFB22222).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFB22222),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'لم تُرجع واجهة التوافق public.v_services_catalog_compat_v1 خدمات عامة صالحة للعرض الآن. لا يوجد انهيار في الواجهة؛ تحقق من نتائج B-1A.0 وعدد الخدمات المفعّلة.',
                      style: TextStyle(color: Color(0xFF64748B), height: 1.55),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PwfServicesCatalogMetaChip extends StatelessWidget {
  const _PwfServicesCatalogMetaChip({
    required this.count,
    required this.unitSlug,
  });

  final int count;
  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFB22222).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFB22222).withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        unitSlug == 'home'
            ? '$count خدمات عامة مفعّلة عبر واجهة التوافق'
            : '$count خدمات عامة مفعّلة — العرض scoped عبر homepage_sections',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF8F1D1D),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PwfPublicServiceCatalogCard extends StatelessWidget {
  const _PwfPublicServiceCatalogCard({required this.item});

  final PwfPublicServiceCatalogItem item;

  @override
  Widget build(BuildContext context) {
    return PwfSurfaceCard(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 218),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _open(context, item),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _iconForKey(item.iconKey, item.link),
                        color: const Color(0xFF0B3A70),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _descriptionFor(item),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => _open(context, item),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('فتح الخدمة'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _open(
    BuildContext context,
    PwfPublicServiceCatalogItem item,
  ) async {
    final target = item.link.trim();
    if (target.isEmpty) return;
    if (item.isExternalLink) {
      await launchUrlString(target);
      return;
    }
    context.go(item.routeForGoRouter);
  }

  static String _descriptionFor(PwfPublicServiceCatalogItem item) {
    final link = item.link.toLowerCase();
    if (link == '/services') {
      return 'مدخل موحد لاستعراض دليل الخدمات العامة المنشورة على المنصة.';
    }
    if (link.contains('complaint')) {
      return 'قناة مخصصة للشكاوى والملاحظات، وتبقى منفصلة عن طلبات الخدمات العامة.';
    }
    if (link.contains('legal')) {
      return 'مرجع رسمي للأنظمة والقوانين والتعليمات المرتبطة بعمل المؤسسة.';
    }
    if (link.contains('track')) {
      return 'مسار متابعة الطلبات أو الاستعلام عن حالة خدمة مقدمة عبر المنصة.';
    }
    if (link.contains('request')) {
      return 'مدخل موحد لتقديم طلب خدمة عامة أو نموذج مرتبط بخدمات الجمهور.';
    }
    if (link.contains('eservice')) {
      return 'بوابة خدمات إلكترونية عامة مرتبطة بمسارات المنصة المتاحة حاليًا.';
    }
    if (link.contains('zakat')) {
      return 'مدخل خدمات الزكاة والتبرعات العامة دون خلطها بخدمات العقارات الوقفية.';
    }
    if (link.contains('prayer')) {
      return 'خدمة عرض مواقيت الصلاة ضمن خدمات الجمهور العامة.';
    }
    if (link.contains('quran')) {
      return 'خدمة الوصول إلى القرآن الكريم ضمن واجهات الجمهور العامة.';
    }
    return 'خدمة عامة منشورة ضمن كتالوج خدمات الجمهور المعتمد في المنصة.';
  }

  static IconData _iconForKey(String key, String route) {
    final iconKey = key.trim().toLowerCase();
    switch (iconKey) {
      case 'list_alt':
        return Icons.list_alt_outlined;
      case 'language':
        return Icons.language_outlined;
      case 'assignment':
        return Icons.assignment_outlined;
      case 'manage_search':
        return Icons.manage_search_outlined;
      case 'feedback':
        return Icons.feedback_outlined;
      case 'gavel':
        return Icons.gavel_outlined;
      case 'volunteer_activism':
        return Icons.volunteer_activism_outlined;
      case 'schedule':
        return Icons.schedule_outlined;
      case 'menu_book':
        return Icons.menu_book_outlined;
    }

    final normalized = '$iconKey ${route.trim().toLowerCase()}';
    if (normalized.contains('complaint') || normalized.contains('feedback')) {
      return Icons.support_agent_outlined;
    }
    if (normalized.contains('legal') || normalized.contains('law')) {
      return Icons.gavel_outlined;
    }
    if (normalized.contains('track') || normalized.contains('search')) {
      return Icons.manage_search_outlined;
    }
    if (normalized.contains('request') || normalized.contains('form')) {
      return Icons.assignment_outlined;
    }
    if (normalized.contains('payment') || normalized.contains('billing')) {
      return Icons.receipt_long_outlined;
    }
    if (normalized.contains('zakat') || normalized.contains('donation')) {
      return Icons.volunteer_activism_outlined;
    }
    if (normalized.contains('prayer') || normalized.contains('schedule')) {
      return Icons.schedule_outlined;
    }
    if (normalized.contains('quran') || normalized.contains('book')) {
      return Icons.menu_book_outlined;
    }
    if (normalized.contains('electronic') || normalized.contains('eservice')) {
      return Icons.computer_outlined;
    }
    if (normalized.contains('mosque')) return Icons.mosque_outlined;
    if (normalized.contains('link')) return Icons.link_outlined;
    return Icons.miscellaneous_services_outlined;
  }
}
