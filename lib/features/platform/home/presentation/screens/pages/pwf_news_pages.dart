import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:waqf/app/routing/unit_routes.dart';
import 'package:waqf/core/utils/text_normalize.dart';
import 'package:waqf/data/models/news_article.dart';
import 'package:waqf/features/platform/home/presentation/screens/pages/pwf_public_content_shared.dart';
import 'package:waqf/features/platform/home/presentation/screens/pwf_web_page_scaffold.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_section_container.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_internal_public_page_contract_widgets.dart';
import 'package:waqf/features/platform/home/presentation/widgets/shared/pwf_home_visual_contract.dart';
import 'package:waqf/features/platform/home/presentation/theme/pwf_home_palette.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';
import 'package:waqf/presentation/providers/unit_news_provider.dart';
import 'package:waqf/presentation/providers/news_provider.dart';
import 'package:waqf/presentation/providers/unit_dashboard_preview_providers.dart';
import 'package:waqf/presentation/providers/org_units_provider.dart';

class PwfNewsListWebScreen extends ConsumerStatefulWidget {
  const PwfNewsListWebScreen({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  ConsumerState<PwfNewsListWebScreen> createState() =>
      _PwfNewsListWebScreenState();
}

class _PwfNewsListWebScreenState extends ConsumerState<PwfNewsListWebScreen> {
  String _query = '';
  NewsCategory? _category;
  bool _featuredOnly = false;
  String? _complementaryUnitId;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(unitNewsProvider(widget.unitSlug));
    final complementaryAsync = ref.watch(
      complementaryLatestNewsPreviewProvider(
        UnitPreviewParams(unitSlug: widget.unitSlug, limit: 9),
      ),
    );
    final unit = ref.watch(orgUnitBySlugProvider(widget.unitSlug)).valueOrNull;
    final allUnits =
        ref.watch(orgUnitsListProvider).valueOrNull ??
        const <Map<String, dynamic>>[];
    final unitNamesById = <String, String>{
      for (final row in allUnits)
        if ((row['id'] ?? '').toString().trim().isNotEmpty)
          (row['id'] ?? '')
              .toString()
              .trim(): ((row['name_ar'] ?? row['name'] ?? row['slug']) ?? '')
              .toString()
              .trim(),
    };
    final scopeLabel = pwfResolveScopeLabel(
      unitSlug: widget.unitSlug,
      unit: unit,
    );
    final isHomeScope = widget.unitSlug.trim().toLowerCase() == 'home';

    return PwfWebPageScaffold(
      unitSlug: widget.unitSlug,
      title: 'الأخبار',
      showTitleSection: false,
      child: PwfSectionContainer(
        sectionKey: 'PwfNewsListWebScreen',
        child: async.when(
          data: (items) {
            final filtered = _applyFilters(items);
            final complementarySource =
                complementaryAsync.valueOrNull ?? const <NewsArticle>[];
            final complementaryUnitOptions = isHomeScope
                ? complementarySource
                      .map((item) => item.unitId)
                      .whereType<String>()
                      .where((id) => id.trim().isNotEmpty)
                      .toSet()
                      .map((id) => MapEntry(id, unitNamesById[id] ?? 'وحدة'))
                      .toList(growable: false)
                : const <MapEntry<String, String>>[];
            final complementaryFiltered = _applyFilters(complementarySource)
                .where((item) {
                  if (!isHomeScope ||
                      _complementaryUnitId == null ||
                      _complementaryUnitId!.trim().isEmpty) {
                    return true;
                  }
                  return item.unitId == _complementaryUnitId;
                })
                .toList(growable: false);
            final featuredCount = items
                .where((e) => e.isFeatured || e.isPinned)
                .length;
            final categoriesCount = items.map((e) => e.category).toSet().length;
            final hero = filtered.isNotEmpty
                ? filtered.first
                : (items.isNotEmpty ? items.first : null);

            return LayoutBuilder(
              builder: (context, constraints) {
                final mobile = constraints.maxWidth < 640;
                final gap = mobile ? 12.0 : 18.0;
                final stats = [
                  PwfStatItem(
                    label: 'إجمالي الأخبار',
                    value: items.length,
                    icon: Icons.article_outlined,
                  ),
                  PwfStatItem(
                    label: 'المميز والمثبت',
                    value: featuredCount,
                    icon: Icons.push_pin_outlined,
                    color: PwfHomePalette.royalRed,
                  ),
                  PwfStatItem(
                    label: 'الأخبار المطابقة',
                    value: filtered.length,
                    icon: Icons.filter_alt_outlined,
                    color: PwfHomePalette.secondary,
                  ),
                  PwfStatItem(
                    label: 'عدد التصنيفات',
                    value: categoriesCount,
                    icon: Icons.category_outlined,
                  ),
                ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PwfInternalPublicPageIntro(
                      specKey: 'news',
                      wrapInSectionContainer: false,
                      unitSlug: widget.unitSlug,
                      title: 'أخبار $scopeLabel',
                      subtitle: isHomeScope
                          ? 'صفحة أخبار متكاملة لأخبار الوزارة الرسمية، مع نافذة مختصرة لأخبار المحافظات والوحدات.'
                          : 'صفحة أخبار متكاملة لأخبار $scopeLabel دون خلط مع أخبار الوزارة المركزية.',
                    ),
                    SizedBox(height: gap),
                    mobile ? _MobileNewsSummaryBar(items: stats) : PwfStatsWrap(items: stats),
                    SizedBox(height: gap),
                    _NewsFiltersCard(
                      query: _query,
                      selectedCategory: _category,
                      featuredOnly: _featuredOnly,
                      onQueryChanged: (value) => setState(() => _query = value),
                      onCategoryChanged: (value) =>
                          setState(() => _category = value),
                      onFeaturedOnlyChanged: (value) =>
                          setState(() => _featuredOnly = value),
                    ),
                    SizedBox(height: gap),
                    if (hero != null) ...[
                      _NewsHeroCard(
                        article: hero,
                        unitSlug: widget.unitSlug,
                        mobileDense: mobile,
                      ),
                      SizedBox(height: gap),
                    ],
                    if (filtered.isEmpty)
                      const PwfEmptyBlock(
                        title: 'لا توجد أخبار مطابقة',
                        message:
                            'جرّب تغيير كلمات البحث أو إزالة بعض عوامل التصفية لعرض مزيد من الأخبار.',
                        icon: Icons.newspaper_outlined,
                      )
                    else
                      _NewsGrid(
                        items: filtered,
                        unitSlug: widget.unitSlug,
                        unitNamesById: unitNamesById,
                        defaultSourceLabel: scopeLabel,
                      ),
                    SizedBox(height: gap),
                    complementaryAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (_) {
                        if (complementaryFiltered.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return _InlineComplementaryNewsCard(
                          unitSlug: widget.unitSlug,
                          isHomeScope: isHomeScope,
                          items: complementaryFiltered,
                          totalCount: complementaryFiltered.length,
                          unitNamesById: unitNamesById,
                          complementaryUnitOptions: complementaryUnitOptions,
                          selectedUnitId: _complementaryUnitId,
                          onSelectUnitId: isHomeScope
                              ? (value) =>
                                    setState(() => _complementaryUnitId = value)
                              : null,
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
          loading: () =>
              const PwfLoadingBlock(message: 'جاري تحميل الأخبار...'),
          error: (e, _) => PwfErrorBlock(
            onRetry: () => ref.invalidate(unitNewsProvider(widget.unitSlug)),
            message: e.toString(),
          ),
        ),
      ),
    );
  }

  List<NewsArticle> _applyFilters(List<NewsArticle> source) {
    final q = normalizeRichText(_query).trim().toLowerCase();
    final list = source.where((item) {
      if (_category != null && item.category != _category) return false;
      if (_featuredOnly && !(item.isFeatured || item.isPinned)) return false;
      if (q.isEmpty) return true;
      final haystack = [
        item.title,
        item.excerpt,
        item.content,
        item.author,
        ...item.tags,
      ].map((e) => normalizeRichText(e).toLowerCase()).join(' ');
      return haystack.contains(q);
    }).toList();

    list.sort((a, b) {
      final aWeight = (a.isPinned ? 2 : 0) + (a.isFeatured ? 1 : 0);
      final bWeight = (b.isPinned ? 2 : 0) + (b.isFeatured ? 1 : 0);
      if (aWeight != bWeight) return bWeight.compareTo(aWeight);
      final ad = a.publishedAt ?? a.createdAt;
      final bd = b.publishedAt ?? b.createdAt;
      return bd.compareTo(ad);
    });
    return list;
  }
}

class PwfNewsDetailWebScreen extends ConsumerWidget {
  const PwfNewsDetailWebScreen({
    super.key,
    required this.unitSlug,
    required this.contentId,
  });

  final String unitSlug;
  final String contentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      unitNewsContentDetailProvider(
        UnitNewsContentIdParam(unitSlug, contentId),
      ),
    );

    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: 'تفاصيل الخبر',
      showTitleSection: false,
      child: PwfSectionContainer(
        sectionKey: 'PwfNewsDetailWebScreen',
        child: async.when(
          data: (article) {
            if (article == null) {
              return const PwfEmptyBlock(
                title: 'الخبر غير موجود',
                message:
                    'العنصر غير منشور أو لا يطابق نطاق الوحدة أو فئة المحتوى المطلوبة.',
                icon: Icons.article_outlined,
              );
            }
            return _NewsDetailBody(article: article, unitSlug: unitSlug);
          },
          loading: () =>
              const PwfLoadingBlock(message: 'جاري تحميل تفاصيل الخبر...'),
          error: (e, _) => PwfErrorBlock(
            onRetry: () => ref.invalidate(
              unitNewsContentDetailProvider(
                UnitNewsContentIdParam(unitSlug, contentId),
              ),
            ),
            message: e.toString(),
          ),
        ),
      ),
    );
  }
}

class _InlineComplementaryNewsCard extends StatelessWidget {
  const _InlineComplementaryNewsCard({
    required this.unitSlug,
    required this.isHomeScope,
    required this.items,
    required this.totalCount,
    required this.unitNamesById,
    required this.complementaryUnitOptions,
    required this.selectedUnitId,
    required this.onSelectUnitId,
  });

  final String unitSlug;
  final bool isHomeScope;
  final List<NewsArticle> items;
  final int totalCount;
  final Map<String, String> unitNamesById;
  final List<MapEntry<String, String>> complementaryUnitOptions;
  final String? selectedUnitId;
  final ValueChanged<String?>? onSelectUnitId;

  @override
  Widget build(BuildContext context) {
    final title = isHomeScope ? 'أخبار الوحدات والمحافظات' : 'أخبار مرتبطة';
    final subtitle = isHomeScope
        ? 'مساحة تعريفية مرافقة تعرض أخبار الوحدات بعد تطبيق نفس الفلاتر المستخدمة في الصفحة الحالية.'
        : 'لا يتم عرض أخبار الوزارة داخل صفحة الوحدة؛ تظهر هنا الأخبار المرتبطة فقط عند توفرها.';

    return PwfSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isHomeScope
                    ? [const Color(0xFF7A5B12), const Color(0xFFD4AF37)]
                    : [
                        PwfHomePalette.primary,
                        PwfHomePalette.primary.withValues(alpha: 0.92),
                      ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const PwfMetaBadge(
                      label: 'قسم تكميلي',
                      icon: Icons.layers_outlined,
                      color: Colors.white,
                      backgroundColor: Color(0x2AFFFFFF),
                    ),
                    PwfMetaBadge(
                      label: 'عدد الأخبار: $totalCount',
                      icon: Icons.filter_alt_outlined,
                      color: Colors.white,
                      backgroundColor: const Color(0x2AFFFFFF),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isHomeScope && complementaryUnitOptions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'فلترة أخبار الوحدات',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: PwfHomePalette.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                PwfFilterChipButton(
                  label: 'كل الوحدات',
                  selected: selectedUnitId == null,
                  onTap: () => onSelectUnitId?.call(null),
                ),
                ...complementaryUnitOptions.map(
                  (entry) => PwfFilterChipButton(
                    label: entry.value,
                    selected: selectedUnitId == entry.key,
                    onTap: () => onSelectUnitId?.call(entry.key),
                    selectedColor: PwfHomePalette.secondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _NewsGrid(
            items: items,
            unitSlug: unitSlug,
            unitNamesById: unitNamesById,
            defaultSourceLabel: isHomeScope ? 'الوحدات' : 'الوزارة',
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _MobileNewsSummaryBar extends StatelessWidget {
  const _MobileNewsSummaryBar({required this.items});

  final List<PwfStatItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 172,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PwfHomePalette.border),
              boxShadow: const [PwfHomeVisualContract.cardShadow],
            ),
            child: Row(
              children: [
                PwfVisualIconTile(icon: item.icon, color: item.color, size: 38),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.value}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: PwfHomePalette.primary,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: PwfHomePalette.textSecondary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NewsFiltersCard extends StatelessWidget {
  const _NewsFiltersCard({
    required this.query,
    required this.selectedCategory,
    required this.featuredOnly,
    required this.onQueryChanged,
    required this.onCategoryChanged,
    required this.onFeaturedOnlyChanged,
  });

  final String query;
  final NewsCategory? selectedCategory;
  final bool featuredOnly;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<NewsCategory?> onCategoryChanged;
  final ValueChanged<bool> onFeaturedOnlyChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 640;
        final categoryChips = <Widget>[
          PwfFilterChipButton(
            label: 'كل التصنيفات',
            selected: selectedCategory == null,
            onTap: () => onCategoryChanged(null),
          ),
          ...NewsCategory.values.map(
            (category) => PwfFilterChipButton(
              label: category.displayName,
              selected: selectedCategory == category,
              onTap: () => onCategoryChanged(category),
            ),
          ),
          PwfFilterChipButton(
            label: 'المميز والمثبت فقط',
            selected: featuredOnly,
            selectedColor: PwfHomePalette.royalRed,
            onTap: () => onFeaturedOnlyChanged(!featuredOnly),
          ),
        ];

        return PwfSurfaceCard(
          padding: EdgeInsets.all(mobile ? 14 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    color: PwfHomePalette.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'البحث والفلترة',
                    style: GoogleFonts.cairo(
                      fontSize: mobile ? 15 : 17,
                      fontWeight: FontWeight.w800,
                      color: PwfHomePalette.primary,
                    ),
                  ),
                  const Spacer(),
                  if (mobile)
                    PwfVisualChip(
                      label: selectedCategory?.displayName ?? 'الكل',
                      icon: Icons.category_outlined,
                      color: PwfHomePalette.secondary,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              PwfSearchBox(
                hint: mobile
                    ? 'ابحث في الأخبار...'
                    : 'ابحث في الأخبار بالعنوان أو الوصف أو الكاتب أو الوسوم...',
                initialValue: query,
                onChanged: onQueryChanged,
              ),
              const SizedBox(height: 14),
              if (mobile)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    children: [
                      for (final chip in categoryChips) ...[
                        chip,
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                )
              else
                Wrap(spacing: 10, runSpacing: 10, children: categoryChips),
            ],
          ),
        );
      },
    );
  }
}

class _NewsHeroCard extends StatelessWidget {
  const _NewsHeroCard({
    required this.article,
    required this.unitSlug,
    this.mobileDense = false,
  });

  final NewsArticle article;
  final String unitSlug;
  final bool mobileDense;

  @override
  Widget build(BuildContext context) {
    final published = article.publishedAt ?? article.createdAt;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: PwfHomeRadii.br20,
        boxShadow: const [
          BoxShadow(
            color: PwfHomePalette.shadow,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 900;
          final mobile = mobileDense || c.maxWidth < 640;
          final image = article.imageUrl;
          Widget imagePane() {
            return SizedBox(
              height: mobile ? 188 : (narrow ? 240 : 360),
              width: narrow ? double.infinity : null,
              child: image?.trim().isNotEmpty == true
                  ? Image.network(
                      image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _NewsHeroPlaceholder(category: article.category),
                    )
                  : _NewsHeroPlaceholder(category: article.category),
            );
          }

          Widget contentPane() {
            return Padding(
              padding: EdgeInsets.all(mobile ? 16 : 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      PwfMetaBadge(
                        label: article.category.displayName,
                        icon: Icons.category_outlined,
                      ),
                      if (article.isPinned)
                        const PwfMetaBadge(
                          label: 'مثبت',
                          icon: Icons.push_pin,
                          color: PwfHomePalette.royalRed,
                        ),
                      if (article.isFeatured)
                        const PwfMetaBadge(
                          label: 'مميز',
                          icon: Icons.star_rounded,
                          color: PwfHomePalette.secondary,
                        ),
                      PwfMetaBadge(
                        label: pwfFormatArabicDate(published),
                        icon: Icons.calendar_today_outlined,
                        color: PwfHomePalette.textSecondary,
                      ),
                    ],
                  ),
                  SizedBox(height: mobile ? 12 : 16),
                  Text(
                    article.title,
                    maxLines: mobile ? 3 : null,
                    overflow: mobile ? TextOverflow.ellipsis : TextOverflow.visible,
                    style: GoogleFonts.cairo(
                      fontSize: mobile ? 21 : 27,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                      color: PwfHomePalette.primary,
                    ),
                  ),
                  SizedBox(height: mobile ? 8 : 12),
                  Text(
                    article.excerpt.trim().isNotEmpty
                        ? article.excerpt
                        : article.content,
                    maxLines: mobile ? 3 : 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: mobile ? 13.5 : 14.5,
                      height: 1.8,
                      color: PwfHomePalette.textSecondary,
                    ),
                  ),
                  SizedBox(height: mobile ? 12 : 16),
                  Wrap(
                    spacing: 18,
                    runSpacing: 10,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 18,
                            color: PwfHomePalette.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Text(
                              article.author,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                color: PwfHomePalette.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility_outlined,
                            size: 18,
                            color: PwfHomePalette.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${article.viewCount} مشاهدة',
                            style: GoogleFonts.cairo(
                              color: PwfHomePalette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: mobile ? 14 : 20),
                  SizedBox(
                    width: mobile ? double.infinity : null,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go(
                        UnitRoutes.newsDetail(unitSlug, article.publicDetailId),
                        extra: article,
                      ),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('قراءة الخبر كاملاً'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PwfHomePalette.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (narrow) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                imagePane(),
                contentPane(),
              ],
            );
          }

          return SizedBox(
            height: 360,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: imagePane(),
                ),
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: contentPane(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NewsHeroPlaceholder extends StatelessWidget {
  const _NewsHeroPlaceholder({required this.category});

  final NewsCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PwfHomePalette.primary.withValues(alpha: 0.08),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 46,
              color: PwfHomePalette.primary,
            ),
            const SizedBox(height: 10),
            Text(
              category.displayName,
              style: GoogleFonts.cairo(
                color: PwfHomePalette.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsGrid extends StatelessWidget {
  const _NewsGrid({
    required this.items,
    required this.unitSlug,
    required this.unitNamesById,
    required this.defaultSourceLabel,
    this.compact = false,
  });

  final List<NewsArticle> items;
  final String unitSlug;
  final Map<String, String> unitNamesById;
  final String defaultSourceLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        if (w < 640) {
          return Column(
            children: [
              for (int index = 0; index < items.length; index++) ...[
                _MobileNewsCard(
                  article: items[index],
                  unitSlug: unitSlug,
                  sourceLabel:
                      unitNamesById[items[index].unitId] ?? defaultSourceLabel,
                ),
                if (index != items.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        final cols = w >= 1180 ? 3 : (w >= 760 ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            mainAxisExtent: compact ? 500 : 540,
          ),
          itemBuilder: (context, index) {
            final article = items[index];
            return _NewsCard(
              article: article,
              unitSlug: unitSlug,
              sourceLabel: unitNamesById[article.unitId] ?? defaultSourceLabel,
              compact: compact,
            );
          },
        );
      },
    );
  }
}

class _MobileNewsCard extends StatelessWidget {
  const _MobileNewsCard({
    required this.article,
    required this.unitSlug,
    required this.sourceLabel,
  });

  final NewsArticle article;
  final String unitSlug;
  final String sourceLabel;

  @override
  Widget build(BuildContext context) {
    final published = article.publishedAt ?? article.createdAt;
    final imageUrl = article.imageUrl?.trim();

    return InkWell(
      onTap: () => context.go(
        UnitRoutes.newsDetail(unitSlug, article.publicDetailId),
        extra: article,
      ),
      borderRadius: BorderRadius.circular(18),
      child: PwfSurfaceCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 104,
                height: 104,
                child: imageUrl?.isNotEmpty == true
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _CardImageFallback(
                          icon: Icons.article_outlined,
                        ),
                      )
                    : const _CardImageFallback(icon: Icons.article_outlined),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      PwfMetaBadge(
                        label: article.category.displayName,
                        icon: Icons.category_outlined,
                      ),
                      if (article.isPinned)
                        const PwfMetaBadge(
                          label: 'مثبت',
                          icon: Icons.push_pin,
                          color: PwfHomePalette.royalRed,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: PwfHomePalette.primary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.excerpt.trim().isNotEmpty
                        ? article.excerpt
                        : article.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 12.25,
                      height: 1.55,
                      color: PwfHomePalette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      _MobileNewsMetaText(
                        icon: Icons.calendar_today_outlined,
                        label: pwfFormatArabicDate(published),
                      ),
                      _MobileNewsMetaText(
                        icon: Icons.account_tree_outlined,
                        label: sourceLabel,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileNewsMetaText extends StatelessWidget {
  const _MobileNewsMetaText({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: PwfHomePalette.textSecondary),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 118),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 11.25,
              fontWeight: FontWeight.w700,
              color: PwfHomePalette.textSecondary,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.article,
    required this.unitSlug,
    required this.sourceLabel,
    this.compact = false,
  });

  final NewsArticle article;
  final String unitSlug;
  final String sourceLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final published = article.publishedAt ?? article.createdAt;
    return InkWell(
      onTap: () => context.go(
        UnitRoutes.newsDetail(unitSlug, article.publicDetailId),
        extra: article,
      ),
      borderRadius: PwfHomeRadii.br16,
      child: PwfSurfaceCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(PwfHomeRadii.r16),
              ),
              child: SizedBox(
                height: compact ? 160 : 190,
                width: double.infinity,
                child: article.imageUrl?.trim().isNotEmpty == true
                    ? Image.network(
                        article.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _CardImageFallback(
                          icon: Icons.article_outlined,
                        ),
                      )
                    : const _CardImageFallback(icon: Icons.article_outlined),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        PwfMetaBadge(
                          label: article.category.displayName,
                          icon: Icons.category_outlined,
                        ),
                        PwfMetaBadge(
                          label: sourceLabel,
                          icon: Icons.account_tree_outlined,
                          backgroundColor: const Color(0xFFF8F3E3),
                          color: PwfHomePalette.secondary,
                        ),
                        if (article.isPinned)
                          const PwfMetaBadge(
                            label: 'مثبت',
                            icon: Icons.push_pin,
                            color: PwfHomePalette.royalRed,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: PwfHomePalette.primary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      article.excerpt.trim().isNotEmpty
                          ? article.excerpt
                          : article.content,
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        height: 1.7,
                        color: PwfHomePalette.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Wrap(
                      spacing: 14,
                      runSpacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: PwfHomePalette.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              pwfFormatArabicDate(published),
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                color: PwfHomePalette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: PwfHomePalette.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                article.author,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 12.5,
                                  color: PwfHomePalette.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          'عرض التفاصيل',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: PwfHomePalette.royalRed,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_back,
                          size: 18,
                          color: PwfHomePalette.royalRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsDetailBody extends ConsumerWidget {
  const _NewsDetailBody({required this.article, required this.unitSlug});

  final NewsArticle article;
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final published = article.publishedAt ?? article.createdAt;
    final unit = ref.watch(orgUnitBySlugProvider(unitSlug)).valueOrNull;
    final scopeLabel = pwfResolveScopeLabel(unitSlug: unitSlug, unit: unit);
    final relatedItems =
        (ref.watch(unitNewsProvider(unitSlug)).valueOrNull ??
                const <NewsArticle>[])
            .where((item) => item.id != article.id)
            .take(3)
            .toList(growable: false);
    final detailPath = UnitRoutes.newsDetail(unitSlug, article.publicDetailId);
    final mobile = MediaQuery.sizeOf(context).width < 640;
    final gap = mobile ? 12.0 : 18.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PwfPublicIntroCard(
          title: article.title,
          subtitle: article.excerpt.trim().isNotEmpty
              ? article.excerpt
              : 'تفاصيل الخبر الكامل ضمن واجهة متوافقة مع الصفحة الرئيسية.',
          icon: Icons.article_outlined,
          unitSlug: unitSlug,
          note:
              'يعرض هذا الخبر ضمن نطاق $scopeLabel، مع معلومات النشر والتصنيف والوسوم والمحتوى الكامل وروابط متابعة إضافية.',
        ),
        SizedBox(height: gap),
        PwfDetailActionsBar(
          subtitle:
              'يمكنك العودة إلى قائمة الأخبار أو نسخ رابط هذا الخبر لمشاركته داخليًا.',
          actions: [
            FilledButton.icon(
              onPressed: () => context.go(UnitRoutes.news(unitSlug)),
              icon: const Icon(Icons.view_list_rounded),
              label: const Text('كل الأخبار'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(UnitRoutes.news(unitSlug));
                }
              },
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('رجوع'),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: detailPath));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ رابط الخبر')),
                  );
                }
              },
              icon: const Icon(Icons.link_rounded),
              label: const Text('نسخ الرابط'),
            ),
          ],
        ),
        SizedBox(height: gap),
        if (article.imageUrl?.trim().isNotEmpty == true)
          ClipRRect(
            borderRadius: PwfHomeRadii.br20,
            child: SizedBox(
              width: double.infinity,
              height: mobile ? 220 : 360,
              child: Image.network(
                article.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const _CardImageFallback(icon: Icons.article_outlined),
              ),
            ),
          ),
        if (article.imageUrl?.trim().isNotEmpty == true)
          SizedBox(height: gap),
        PwfSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PwfDetailSectionTitle(
                title: 'بيانات الخبر',
                subtitle: 'وصف مختصر ومعلومات النشر والعناصر المرافقة.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  PwfMetaBadge(
                    label: article.category.displayName,
                    icon: Icons.category_outlined,
                  ),
                  PwfMetaBadge(
                    label: article.status.displayName,
                    icon: Icons.flag_outlined,
                    color: article.status == PublishStatus.published
                        ? const Color(0xFF1D7A46)
                        : PwfHomePalette.textSecondary,
                  ),
                  PwfMetaBadge(
                    label: pwfFormatArabicDate(published),
                    icon: Icons.calendar_today_outlined,
                    color: PwfHomePalette.textSecondary,
                  ),
                  PwfMetaBadge(
                    label: article.author,
                    icon: Icons.person_outline,
                    color: PwfHomePalette.textSecondary,
                  ),
                  PwfMetaBadge(
                    label: '${article.viewCount} مشاهدة',
                    icon: Icons.visibility_outlined,
                    color: PwfHomePalette.textSecondary,
                  ),
                  if (article.isPinned)
                    const PwfMetaBadge(
                      label: 'مثبت',
                      icon: Icons.push_pin,
                      color: PwfHomePalette.royalRed,
                    ),
                  if (article.isFeatured)
                    const PwfMetaBadge(
                      label: 'مميز',
                      icon: Icons.star_rounded,
                      color: PwfHomePalette.secondary,
                    ),
                ],
              ),
              SizedBox(height: gap),
              PwfDetailInfoGrid(
                items: [
                  PwfDetailInfoItem(
                    label: 'النطاق',
                    value: scopeLabel,
                    icon: Icons.account_tree_outlined,
                  ),
                  PwfDetailInfoItem(
                    label: 'تاريخ الإنشاء',
                    value: pwfFormatArabicDate(article.createdAt),
                    icon: Icons.edit_calendar_outlined,
                  ),
                  PwfDetailInfoItem(
                    label: 'آخر تحديث',
                    value: pwfFormatArabicDate(article.updatedAt),
                    icon: Icons.update_outlined,
                  ),
                  if ((article.attachmentUrl ?? '').trim().isNotEmpty)
                    const PwfDetailInfoItem(
                      label: 'مرفق',
                      value: 'يوجد مرفق مرتبط بهذا الخبر',
                      icon: Icons.attach_file_outlined,
                    ),
                ],
              ),
              if (article.excerpt.trim().isNotEmpty) ...[
                SizedBox(height: gap),
                const PwfDetailSectionTitle(title: 'الملخص'),
                const SizedBox(height: 10),
                SelectableText(
                  article.excerpt,
                  style: GoogleFonts.cairo(
                    fontSize: mobile ? 14.5 : 16,
                    height: mobile ? 1.75 : 1.9,
                    fontWeight: FontWeight.w700,
                    color: PwfHomePalette.primary,
                  ),
                ),
              ],
              SizedBox(height: gap),
              const PwfDetailSectionTitle(title: 'المحتوى الكامل'),
              const SizedBox(height: 10),
              SelectableText(
                article.content.trim().isNotEmpty
                    ? article.content
                    : article.excerpt,
                style: GoogleFonts.cairo(
                  fontSize: mobile ? 14.25 : 15.5,
                  height: mobile ? 1.85 : 2.0,
                  color: const Color(0xFF1E293B),
                ),
              ),
              if ((article.attachmentUrl ?? '').trim().isNotEmpty) ...[
                SizedBox(height: gap),
                PwfSurfaceCard(
                  padding: const EdgeInsets.all(14),
                  child: mobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.attach_file_outlined,
                                  color: PwfHomePalette.primary,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'يوجد مرفق مرتبط بهذا الخبر ويمكن نسخه أو استخدامه داخل المنصة.',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: article.attachmentUrl!),
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تم نسخ رابط المرفق'),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.copy_all_outlined),
                                label: const Text('نسخ رابط المرفق'),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Icon(
                              Icons.attach_file_outlined,
                              color: PwfHomePalette.primary,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'يوجد مرفق مرتبط بهذا الخبر ويمكن نسخه أو استخدامه داخل المنصة.',
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: article.attachmentUrl!),
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم نسخ رابط المرفق'),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.copy_all_outlined),
                              label: const Text('نسخ رابط المرفق'),
                            ),
                          ],
                        ),
                ),
              ],
              if (article.tags.isNotEmpty) ...[
                SizedBox(height: gap),
                const PwfDetailSectionTitle(title: 'الوسوم المرتبطة'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: article.tags
                      .map(
                        (tag) => PwfMetaBadge(
                          label: tag,
                          icon: Icons.sell_outlined,
                          color: PwfHomePalette.secondary,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        if (relatedItems.isNotEmpty) ...[
          SizedBox(height: gap),
          PwfRelatedLinksCard(
            title: 'اقرأ أيضًا',
            subtitle: 'عناصر أخرى من نفس النطاق قد تكون مرتبطة بهذا الخبر.',
            children: [
              for (final item in relatedItems)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => context.go(
                      UnitRoutes.newsDetail(unitSlug, item.publicDetailId),
                      extra: item,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.article_outlined,
                            color: PwfHomePalette.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    fontSize: mobile ? 13.5 : 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: PwfHomePalette.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.excerpt.trim().isNotEmpty
                                      ? item.excerpt
                                      : item.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.5,
                                    height: 1.6,
                                    color: PwfHomePalette.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: PwfHomePalette.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CardImageFallback extends StatelessWidget {
  const _CardImageFallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PwfHomePalette.primary.withValues(alpha: 0.08),
      child: Center(child: Icon(icon, size: 38, color: PwfHomePalette.primary)),
    );
  }
}
