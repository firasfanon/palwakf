// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:waqf/app/routing/unit_routes.dart';
import 'package:waqf/core/utils/text_normalize.dart';
import 'package:waqf/data/models/activity.dart';
import 'package:waqf/features/platform/home/presentation/screens/pages/pwf_public_content_shared.dart';
import 'package:waqf/features/platform/home/presentation/screens/pwf_web_page_scaffold.dart';
import 'package:waqf/features/platform/home/presentation/theme/pwf_home_palette.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_section_container.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_internal_public_page_contract_widgets.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';
import 'package:waqf/presentation/providers/unit_activities_provider.dart';
import 'package:waqf/presentation/providers/org_units_provider.dart';
import 'package:waqf/presentation/providers/unit_dashboard_preview_providers.dart';

class PwfActivitiesListWebScreen extends ConsumerStatefulWidget {
  const PwfActivitiesListWebScreen({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  ConsumerState<PwfActivitiesListWebScreen> createState() =>
      _PwfActivitiesListWebScreenState();
}

class _PwfActivitiesListWebScreenState
    extends ConsumerState<PwfActivitiesListWebScreen> {
  String _query = '';
  ActivityCategory? _category;
  ActivityStatus? _status;
  bool _upcomingOnly = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(activitiesForUnitProvider(widget.unitSlug));
    final complementaryAsync = ref.watch(
      complementaryUpcomingActivitiesPreviewProvider(
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
      title: 'الأنشطة والفعاليات',
      showTitleSection: false,
      child: PwfSectionContainer(
        sectionKey: 'PwfActivitiesListWebScreen',
        child: async.when(
          data: (items) {
            final filtered = _applyFilters(items);
            final complementaryFiltered = complementaryAsync.valueOrNull == null
                ? const <Activity>[]
                : _applyFilters(complementaryAsync.valueOrNull!);
            final upcomingCount = items.where(_isUpcoming).length;
            final completedCount = items
                .where((e) => e.status == ActivityStatus.completed)
                .length;
            final categoryCount = items.map((e) => e.category).toSet().length;
            final hero = filtered.isNotEmpty
                ? filtered.first
                : (items.isNotEmpty ? items.first : null);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PwfInternalPublicPageIntro(
                  specKey: 'activities',
                  wrapInSectionContainer: false,
                  unitSlug: widget.unitSlug,
                  title: 'أنشطة وفعاليات $scopeLabel',
                  subtitle: widget.unitSlug.trim().toLowerCase() == 'home'
                      ? 'صفحة أنشطة الوزارة الرسمية، مع فلاتر متقدمة وبطاقات متناسقة مع بقية الصفحات الإعلامية.'
                      : 'صفحة أنشطة وفعاليات $scopeLabel، بعرض متناسق مع الأخبار والإعلانات من حيث الفلاتر والبطاقات والتفاصيل.',
                ),
                const SizedBox(height: 18),
                PwfStatsWrap(
                  items: [
                    PwfStatItem(
                      label: 'إجمالي الأنشطة',
                      value: items.length,
                      icon: Icons.event_available_outlined,
                    ),
                    PwfStatItem(
                      label: 'القادمة',
                      value: upcomingCount,
                      icon: Icons.upcoming_outlined,
                      color: const Color(0xFF1D7A46),
                    ),
                    PwfStatItem(
                      label: 'المكتملة',
                      value: completedCount,
                      icon: Icons.task_alt_outlined,
                      color: PwfHomePalette.secondary,
                    ),
                    PwfStatItem(
                      label: 'عدد الفئات',
                      value: categoryCount,
                      icon: Icons.category_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _ActivitiesFiltersCard(
                  query: _query,
                  selectedCategory: _category,
                  selectedStatus: _status,
                  upcomingOnly: _upcomingOnly,
                  onQueryChanged: (value) => setState(() => _query = value),
                  onCategoryChanged: (value) =>
                      setState(() => _category = value),
                  onStatusChanged: (value) => setState(() => _status = value),
                  onUpcomingOnlyChanged: (value) =>
                      setState(() => _upcomingOnly = value),
                ),
                const SizedBox(height: 18),
                if (hero != null) ...[
                  _ActivityHeroCard(item: hero, unitSlug: widget.unitSlug),
                  const SizedBox(height: 18),
                ],
                if (filtered.isEmpty)
                  const PwfEmptyBlock(
                    title: 'لا توجد أنشطة مطابقة',
                    message: 'جرّب تعديل عوامل التصفية أو البحث بكلمات أخرى.',
                    icon: Icons.event_busy_outlined,
                  )
                else
                  _ActivitiesGrid(
                    items: filtered,
                    unitSlug: widget.unitSlug,
                    unitNamesById: unitNamesById,
                    defaultSourceLabel: scopeLabel,
                  ),
                const SizedBox(height: 18),
                complementaryAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (_) {
                    if (complementaryFiltered.isEmpty)
                      return const SizedBox.shrink();
                    return _InlineComplementaryActivitiesCard(
                      unitSlug: widget.unitSlug,
                      isHomeScope: isHomeScope,
                      items: complementaryFiltered,
                      totalCount: complementaryFiltered.length,
                      unitNamesById: unitNamesById,
                    );
                  },
                ),
              ],
            );
          },
          loading: () =>
              const PwfLoadingBlock(message: 'جاري تحميل الأنشطة...'),
          error: (e, _) => PwfErrorBlock(
            onRetry: () =>
                ref.invalidate(activitiesForUnitProvider(widget.unitSlug)),
            message: e.toString(),
          ),
        ),
      ),
    );
  }

  List<Activity> _applyFilters(List<Activity> source) {
    final q = normalizeRichText(_query).trim().toLowerCase();

    final list = source.where((item) {
      if (_category != null && item.category != _category) return false;
      if (_status != null && item.status != _status) return false;
      if (_upcomingOnly && !_isUpcoming(item)) return false;
      if (q.isEmpty) return true;
      final haystack = [
        item.title,
        item.description,
        item.location,
        item.organizer,
        item.governorate,
        ...item.tags,
      ].map((e) => normalizeRichText(e).toLowerCase()).join(' ');
      return haystack.contains(q);
    }).toList();

    list.sort((a, b) {
      final aUpcoming = _isUpcoming(a) ? 1 : 0;
      final bUpcoming = _isUpcoming(b) ? 1 : 0;
      if (aUpcoming != bUpcoming) return bUpcoming.compareTo(aUpcoming);
      return b.startDate.compareTo(a.startDate);
    });
    return list;
  }
}

class PwfActivityDetailWebScreen extends ConsumerWidget {
  const PwfActivityDetailWebScreen({
    super.key,
    required this.unitSlug,
    required this.contentId,
  });

  final String unitSlug;
  final String contentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      activityContentDetailForUnitProvider(
        UnitActivityContentIdParam(unitSlug, contentId),
      ),
    );

    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: 'تفاصيل النشاط',
      showTitleSection: false,
      child: PwfSectionContainer(
        sectionKey: 'PwfActivityDetailWebScreen',
        child: async.when(
          data: (item) {
            if (item == null) {
              return const PwfEmptyBlock(
                title: 'النشاط غير موجود',
                message:
                    'العنصر غير منشور أو لا يطابق نطاق الوحدة أو فئة المحتوى المطلوبة.',
                icon: Icons.event_busy_outlined,
              );
            }
            return _ActivityDetailBody(item: item, unitSlug: unitSlug);
          },
          loading: () =>
              const PwfLoadingBlock(message: 'جاري تحميل تفاصيل النشاط...'),
          error: (e, _) => PwfErrorBlock(
            onRetry: () => ref.invalidate(
              activityContentDetailForUnitProvider(
                UnitActivityContentIdParam(unitSlug, contentId),
              ),
            ),
            message: e.toString(),
          ),
        ),
      ),
    );
  }
}

class _InlineComplementaryActivitiesCard extends StatelessWidget {
  const _InlineComplementaryActivitiesCard({
    required this.unitSlug,
    required this.isHomeScope,
    required this.items,
    required this.totalCount,
    required this.unitNamesById,
  });

  final String unitSlug;
  final bool isHomeScope;
  final List<Activity> items;
  final int totalCount;
  final Map<String, String> unitNamesById;

  @override
  Widget build(BuildContext context) {
    final title = isHomeScope ? 'أنشطة الوحدات والمحافظات' : 'أنشطة مرتبطة';
    final subtitle = isHomeScope
        ? 'مساحة تعريفية مرافقة تعرض أنشطة الوحدات بعد تطبيق نفس الفلاتر المستخدمة في الصفحة الحالية.'
        : 'لا يتم عرض أنشطة الوزارة داخل صفحة الوحدة؛ تظهر هنا الأنشطة المرتبطة فقط عند توفرها.';

    return PwfSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  (isHomeScope
                          ? PwfHomePalette.secondary
                          : PwfHomePalette.primary)
                      .withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    (isHomeScope
                            ? PwfHomePalette.secondary
                            : PwfHomePalette.primary)
                        .withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: PwfHomePalette.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: PwfHomePalette.gray,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PwfMetaBadge(
                      label: 'عدد الأنشطة: $totalCount',
                      icon: Icons.filter_alt_outlined,
                    ),
                    PwfMetaBadge(
                      label: isHomeScope
                          ? 'مصدر تكميلي أسفل أنشطة الوزارة'
                          : 'مصدر تكميلي أسفل أنشطة الوحدة',
                      icon: Icons.layers_outlined,
                      backgroundColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ActivitiesGrid(
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

class _ActivitiesFiltersCard extends StatelessWidget {
  const _ActivitiesFiltersCard({
    required this.query,
    required this.selectedCategory,
    required this.selectedStatus,
    required this.upcomingOnly,
    required this.onQueryChanged,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onUpcomingOnlyChanged,
  });

  final String query;
  final ActivityCategory? selectedCategory;
  final ActivityStatus? selectedStatus;
  final bool upcomingOnly;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<ActivityCategory?> onCategoryChanged;
  final ValueChanged<ActivityStatus?> onStatusChanged;
  final ValueChanged<bool> onUpcomingOnlyChanged;

  @override
  Widget build(BuildContext context) {
    return PwfSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'فلترة الأنشطة',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: PwfHomePalette.primary,
            ),
          ),
          const SizedBox(height: 12),
          PwfSearchBox(
            hint: 'ابحث في العنوان أو الوصف أو المكان أو الجهة المنظمة...',
            initialValue: query,
            onChanged: onQueryChanged,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PwfFilterChipButton(
                label: 'كل الفئات',
                selected: selectedCategory == null,
                onTap: () => onCategoryChanged(null),
              ),
              ...ActivityCategory.values.map(
                (category) => PwfFilterChipButton(
                  label: category.displayName,
                  selected: selectedCategory == category,
                  onTap: () => onCategoryChanged(category),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PwfFilterChipButton(
                label: 'كل الحالات',
                selected: selectedStatus == null,
                onTap: () => onStatusChanged(null),
              ),
              ...ActivityStatus.values.map(
                (status) => PwfFilterChipButton(
                  label: status.displayName,
                  selected: selectedStatus == status,
                  selectedColor: _statusColor(status),
                  onTap: () => onStatusChanged(status),
                ),
              ),
              PwfFilterChipButton(
                label: 'القادمة فقط',
                selected: upcomingOnly,
                selectedColor: const Color(0xFF1D7A46),
                onTap: () => onUpcomingOnlyChanged(!upcomingOnly),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityHeroCard extends StatelessWidget {
  const _ActivityHeroCard({required this.item, required this.unitSlug});

  final Activity item;
  final String unitSlug;

  @override
  Widget build(BuildContext context) {
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
          return Flex(
            direction: narrow ? Axis.vertical : Axis.horizontal,
            children: [
              Expanded(
                flex: narrow ? 0 : 5,
                child: SizedBox(
                  height: narrow ? 240 : 360,
                  child: item.imageUrl?.trim().isNotEmpty == true
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const _ActivityImageFallback(),
                        )
                      : const _ActivityImageFallback(),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          PwfMetaBadge(
                            label: item.category.displayName,
                            icon: Icons.category_outlined,
                          ),
                          PwfMetaBadge(
                            label: item.status.displayName,
                            icon: Icons.flag_outlined,
                            color: _statusColor(item.status),
                          ),
                          PwfMetaBadge(
                            label: pwfFormatArabicDate(item.startDate),
                            icon: Icons.calendar_today_outlined,
                            color: PwfHomePalette.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item.title,
                        style: GoogleFonts.cairo(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                          color: PwfHomePalette.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 14.5,
                          height: 1.8,
                          color: PwfHomePalette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 18,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: PwfHomePalette.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.location,
                                style: GoogleFonts.cairo(
                                  color: PwfHomePalette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.apartment_outlined,
                                size: 16,
                                color: PwfHomePalette.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.organizer,
                                style: GoogleFonts.cairo(
                                  color: PwfHomePalette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () => context.go(
                          UnitRoutes.activityDetail(unitSlug, item.publicDetailId),
                        ),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('عرض تفاصيل النشاط'),
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
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActivitiesGrid extends StatelessWidget {
  const _ActivitiesGrid({
    required this.items,
    required this.unitSlug,
    required this.unitNamesById,
    required this.defaultSourceLabel,
    this.compact = false,
  });

  final List<Activity> items;
  final String unitSlug;
  final Map<String, String> unitNamesById;
  final String defaultSourceLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cols = w >= 1180 ? 3 : (w >= 760 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            mainAxisExtent: compact ? 430 : 470,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _ActivityCard(
              item: item,
              unitSlug: unitSlug,
              sourceLabel: unitNamesById[item.unitId] ?? defaultSourceLabel,
              compact: compact,
            );
          },
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.item,
    required this.unitSlug,
    required this.sourceLabel,
    this.compact = false,
  });

  final Activity item;
  final String unitSlug;
  final String sourceLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(UnitRoutes.activityDetail(unitSlug, item.publicDetailId)),
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
                child: item.imageUrl?.trim().isNotEmpty == true
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const _ActivityImageFallback(),
                      )
                    : const _ActivityImageFallback(),
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
                          label: item.category.displayName,
                          icon: Icons.category_outlined,
                        ),
                        PwfMetaBadge(
                          label: sourceLabel,
                          icon: Icons.account_tree_outlined,
                          backgroundColor: const Color(0xFFF8F3E3),
                          color: PwfHomePalette.secondary,
                        ),
                        PwfMetaBadge(
                          label: item.status.displayName,
                          icon: Icons.flag_outlined,
                          color: _statusColor(item.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                        color: PwfHomePalette.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.description,
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
                              pwfFormatArabicDate(item.startDate),
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
                              Icons.location_on_outlined,
                              size: 16,
                              color: PwfHomePalette.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                item.location,
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

class _ActivityDetailBody extends ConsumerWidget {
  const _ActivityDetailBody({required this.item, required this.unitSlug});

  final Activity item;
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(orgUnitBySlugProvider(unitSlug)).valueOrNull;
    final scopeLabel = pwfResolveScopeLabel(unitSlug: unitSlug, unit: unit);
    final relatedItems =
        (ref.watch(activitiesForUnitProvider(unitSlug)).valueOrNull ??
                const <Activity>[])
            .where((e) => e.id != item.id)
            .take(3)
            .toList(growable: false);
    final detailPath = UnitRoutes.activityDetail(unitSlug, item.publicDetailId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PwfPublicIntroCard(
          title: item.title,
          subtitle: item.description,
          icon: Icons.event_note_outlined,
          unitSlug: unitSlug,
          note:
              'تفاصيل النشاط تشمل البيانات التشغيلية، التسجيل، المكان، الجهة المنظمة، والأنشطة ذات الصلة ضمن $scopeLabel.',
        ),
        const SizedBox(height: 18),
        PwfDetailActionsBar(
          subtitle:
              'يمكنك الرجوع إلى صفحة الأنشطة أو نسخ رابط هذا النشاط للمتابعة أو الإحالة.',
          actions: [
            FilledButton.icon(
              onPressed: () => context.go(UnitRoutes.activities(unitSlug)),
              icon: const Icon(Icons.view_list_rounded),
              label: const Text('كل الأنشطة'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(UnitRoutes.activities(unitSlug));
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
                    const SnackBar(content: Text('تم نسخ رابط النشاط')),
                  );
                }
              },
              icon: const Icon(Icons.link_rounded),
              label: const Text('نسخ الرابط'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (item.imageUrl?.trim().isNotEmpty == true)
          ClipRRect(
            borderRadius: PwfHomeRadii.br20,
            child: SizedBox(
              width: double.infinity,
              height: 360,
              child: Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ActivityImageFallback(),
              ),
            ),
          ),
        if (item.imageUrl?.trim().isNotEmpty == true)
          const SizedBox(height: 18),
        PwfSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PwfDetailSectionTitle(
                title: 'بيانات النشاط',
                subtitle:
                    'التصنيف والحالة والجدول الزمني والتسجيل والمتطلبات الأساسية.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  PwfMetaBadge(
                    label: item.category.displayName,
                    icon: Icons.category_outlined,
                  ),
                  PwfMetaBadge(
                    label: item.type.displayName,
                    icon: Icons.style_outlined,
                    color: PwfHomePalette.secondary,
                  ),
                  PwfMetaBadge(
                    label: item.status.displayName,
                    icon: Icons.flag_outlined,
                    color: _statusColor(item.status),
                  ),
                  PwfMetaBadge(
                    label: pwfFormatArabicDate(item.startDate),
                    icon: Icons.calendar_today_outlined,
                    color: PwfHomePalette.textSecondary,
                  ),
                  if (item.endDate != null)
                    PwfMetaBadge(
                      label: 'حتى ${pwfFormatArabicDate(item.endDate)}',
                      icon: Icons.event_repeat_outlined,
                      color: PwfHomePalette.textSecondary,
                    ),
                  if (item.isPinned)
                    const PwfMetaBadge(
                      label: 'مثبت',
                      icon: Icons.push_pin,
                      color: PwfHomePalette.royalRed,
                    ),
                  if (item.isFeatured)
                    const PwfMetaBadge(
                      label: 'مميز',
                      icon: Icons.star_rounded,
                      color: PwfHomePalette.secondary,
                    ),
                ],
              ),
              const SizedBox(height: 18),
              PwfDetailInfoGrid(
                items: [
                  PwfDetailInfoItem(
                    label: 'النطاق',
                    value: scopeLabel,
                    icon: Icons.account_tree_outlined,
                  ),
                  PwfDetailInfoItem(
                    label: 'المكان',
                    value: item.location,
                    icon: Icons.location_on_outlined,
                  ),
                  PwfDetailInfoItem(
                    label: 'الجهة المنظمة',
                    value: item.organizer,
                    icon: Icons.apartment_outlined,
                  ),
                  PwfDetailInfoItem(
                    label: 'المحافظة',
                    value: item.governorate,
                    icon: Icons.map_outlined,
                  ),
                  if (item.requiresRegistration)
                    PwfDetailInfoItem(
                      label: 'التسجيل',
                      value: 'يتطلب تسجيلًا مسبقًا',
                      icon: Icons.app_registration_outlined,
                    ),
                  if (!item.isFree && item.price != null)
                    PwfDetailInfoItem(
                      label: 'الرسوم',
                      value: '${item.price}',
                      icon: Icons.payments_outlined,
                    ),
                  if (item.registrationDeadline != null)
                    PwfDetailInfoItem(
                      label: 'آخر موعد للتسجيل',
                      value: pwfFormatArabicDate(item.registrationDeadline),
                      icon: Icons.event_busy_outlined,
                    ),
                ],
              ),
              const SizedBox(height: 18),
              const PwfDetailSectionTitle(title: 'الوصف الكامل'),
              const SizedBox(height: 10),
              SelectableText(
                item.description,
                style: GoogleFonts.cairo(
                  fontSize: 15.5,
                  height: 2.0,
                  color: const Color(0xFF1E293B),
                ),
              ),
              if (item.requirements.isNotEmpty) ...[
                const SizedBox(height: 18),
                const PwfDetailSectionTitle(title: 'المتطلبات'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: item.requirements
                      .map(
                        (tag) => PwfMetaBadge(
                          label: tag,
                          icon: Icons.checklist_outlined,
                          color: const Color(0xFF1D7A46),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 18),
                const PwfDetailSectionTitle(title: 'وسوم مرتبطة'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: item.tags
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
          const SizedBox(height: 18),
          PwfRelatedLinksCard(
            title: 'أنشطة ذات صلة',
            subtitle: 'عناصر أخرى من نفس النطاق يمكن متابعتها أو الرجوع إليها.',
            children: [
              for (final related in relatedItems)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => context.go(
                      UnitRoutes.activityDetail(unitSlug, related.publicDetailId),
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
                            Icons.event_note_outlined,
                            color: PwfHomePalette.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  related.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w800,
                                    color: PwfHomePalette.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  related.description,
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

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: PwfHomePalette.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.cairo(color: PwfHomePalette.textSecondary),
        ),
      ],
    );
  }
}

bool _isUpcoming(Activity item) {
  final today = DateTime.now();
  final startDay = DateTime(
    item.startDate.year,
    item.startDate.month,
    item.startDate.day,
  );
  final todayDay = DateTime(today.year, today.month, today.day);
  return item.status == ActivityStatus.upcoming ||
      item.status == ActivityStatus.ongoing ||
      !startDay.isBefore(todayDay);
}

Color _statusColor(ActivityStatus status) {
  switch (status) {
    case ActivityStatus.upcoming:
      return const Color(0xFF1D7A46);
    case ActivityStatus.ongoing:
      return PwfHomePalette.primary;
    case ActivityStatus.completed:
      return PwfHomePalette.secondary;
    case ActivityStatus.cancelled:
      return PwfHomePalette.royalRed;
    case ActivityStatus.postponed:
      return const Color(0xFFC2410C);
  }
}

class _ActivityImageFallback extends StatelessWidget {
  const _ActivityImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PwfHomePalette.primary.withValues(alpha: 0.08),
      child: const Center(
        child: Icon(
          Icons.event_note_outlined,
          size: 40,
          color: PwfHomePalette.primary,
        ),
      ),
    );
  }
}
