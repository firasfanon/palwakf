import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:waqf/app/routing/unit_routes.dart';
import 'package:waqf/core/utils/text_normalize.dart';
import 'package:waqf/data/models/announcement.dart';
import 'package:waqf/features/platform/home/presentation/screens/pages/pwf_public_content_shared.dart';
import 'package:waqf/features/platform/home/presentation/screens/pwf_web_page_scaffold.dart';
import 'package:waqf/features/platform/home/presentation/theme/pwf_home_palette.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_section_container.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_internal_public_page_contract_widgets.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';
import 'package:waqf/presentation/providers/unit_announcements_provider.dart';
import 'package:waqf/presentation/providers/unit_dashboard_preview_providers.dart';

class PwfAnnouncementsListWebScreen extends ConsumerStatefulWidget {
  const PwfAnnouncementsListWebScreen({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  ConsumerState<PwfAnnouncementsListWebScreen> createState() =>
      _PwfAnnouncementsListWebScreenState();
}

class _PwfAnnouncementsListWebScreenState
    extends ConsumerState<PwfAnnouncementsListWebScreen> {
  String _query = '';
  Priority? _priority;
  bool _activeOnly = true;
  bool _importantOnly = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(announcementsForUnitProvider(widget.unitSlug));
    final complementaryAsync = ref.watch(
      complementaryAnnouncementsPreviewProvider(
        UnitPreviewParams(unitSlug: widget.unitSlug, limit: 9),
      ),
    );
    final unit = ref.watch(orgUnitBySlugProvider(widget.unitSlug)).valueOrNull;
    final scopeLabel = pwfResolveScopeLabel(
      unitSlug: widget.unitSlug,
      unit: unit,
    );
    final isHomeScope = widget.unitSlug.trim().toLowerCase() == 'home';

    return PwfWebPageScaffold(
      unitSlug: widget.unitSlug,
      title: 'الإعلانات',
      showTitleSection: false,
      child: PwfSectionContainer(
        sectionKey: 'PwfAnnouncementsListWebScreen',
        child: async.when(
          data: (items) {
            final filtered = _applyFilters(items);
            final complementaryFiltered = complementaryAsync.valueOrNull == null
                ? const <Announcement>[]
                : _applyFilters(complementaryAsync.valueOrNull!);
            final activeCount = items.where((e) => e.isActive).length;
            final importantCount = items
                .where((e) => _isImportant(e.priority))
                .length;
            final pinnedCount = items.where((e) => e.isPinned).length;
            final featured = filtered.isNotEmpty
                ? filtered.first
                : (items.isNotEmpty ? items.first : null);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PwfInternalPublicPageIntro(
                  specKey: 'announcements',
                  wrapInSectionContainer: false,
                  title: 'إعلانات $scopeLabel',
                  subtitle: isHomeScope
                      ? 'واجهة عامة مطورة لإعلانات الوزارة الرسمية، مع نافذة مختصرة للتنويهات القادمة من الوحدات والأنظمة.'
                      : 'واجهة عامة مطورة لإعلانات $scopeLabel، مع إبقاء الإعلانات الوزارية الأساسية حاضرة داخل الصفحة.',
                  icon: Icons.campaign_outlined,
                  unitSlug: widget.unitSlug,
                ),
                const SizedBox(height: 18),
                PwfStatsWrap(
                  items: [
                    PwfStatItem(
                      label: 'إجمالي الإعلانات',
                      value: items.length,
                      icon: Icons.notifications_none_outlined,
                    ),
                    PwfStatItem(
                      label: 'النشطة',
                      value: activeCount,
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF1D7A46),
                    ),
                    PwfStatItem(
                      label: 'المهمة والعاجلة',
                      value: importantCount,
                      icon: Icons.priority_high,
                      color: PwfHomePalette.royalRed,
                    ),
                    PwfStatItem(
                      label: 'المثبتة',
                      value: pinnedCount,
                      icon: Icons.push_pin_outlined,
                      color: PwfHomePalette.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _AnnouncementFiltersCard(
                  query: _query,
                  selectedPriority: _priority,
                  activeOnly: _activeOnly,
                  importantOnly: _importantOnly,
                  onQueryChanged: (value) => setState(() => _query = value),
                  onPriorityChanged: (value) =>
                      setState(() => _priority = value),
                  onActiveOnlyChanged: (value) =>
                      setState(() => _activeOnly = value),
                  onImportantOnlyChanged: (value) =>
                      setState(() => _importantOnly = value),
                ),
                const SizedBox(height: 18),
                if (featured != null) ...[
                  _AnnouncementHeroCard(
                    item: featured,
                    unitSlug: widget.unitSlug,
                  ),
                  const SizedBox(height: 18),
                ],
                if (filtered.isEmpty)
                  const PwfEmptyBlock(
                    title: 'لا توجد إعلانات مطابقة',
                    message:
                        'جرّب تغيير كلمات البحث أو توسيع الفلاتر لعرض نتائج أكثر.',
                    icon: Icons.notifications_off_outlined,
                  )
                else
                  _AnnouncementsGrid(
                    items: filtered,
                    unitSlug: widget.unitSlug,
                  ),
                const SizedBox(height: 18),
                complementaryAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (_) {
                    if (complementaryFiltered.isEmpty)
                      return const SizedBox.shrink();
                    return _InlineComplementaryAnnouncementsCard(
                      unitSlug: widget.unitSlug,
                      isHomeScope: isHomeScope,
                      items: complementaryFiltered,
                      totalCount: complementaryFiltered.length,
                    );
                  },
                ),
              ],
            );
          },
          loading: () =>
              const PwfLoadingBlock(message: 'جاري تحميل الإعلانات...'),
          error: (e, _) => PwfErrorBlock(
            onRetry: () =>
                ref.invalidate(announcementsForUnitProvider(widget.unitSlug)),
            message: e.toString(),
          ),
        ),
      ),
    );
  }

  List<Announcement> _applyFilters(List<Announcement> source) {
    final q = normalizeRichText(_query).trim().toLowerCase();
    final now = DateTime.now();

    final list = source.where((item) {
      if (_priority != null && item.priority != _priority) return false;
      if (_activeOnly) {
        final notExpired =
            item.validUntil == null ||
            !item.validUntil!.isBefore(DateTime(now.year, now.month, now.day));
        if (!item.isActive || !notExpired) return false;
      }
      if (_importantOnly && !_isImportant(item.priority)) return false;
      if (q.isEmpty) return true;
      final haystack = [
        item.title,
        item.content,
        item.targetAudience,
      ].map((e) => normalizeRichText(e).toLowerCase()).join(' ');
      return haystack.contains(q);
    }).toList();

    list.sort((a, b) {
      final aWeight = (a.isPinned ? 3 : 0) + (_priorityRank(a.priority));
      final bWeight = (b.isPinned ? 3 : 0) + (_priorityRank(b.priority));
      if (aWeight != bWeight) return bWeight.compareTo(aWeight);
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }
}

class PwfAnnouncementDetailWebScreen extends ConsumerWidget {
  const PwfAnnouncementDetailWebScreen({
    super.key,
    required this.unitSlug,
    required this.contentId,
  });

  final String unitSlug;
  final String contentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      announcementContentDetailForUnitProvider(
        UnitAnnouncementContentIdParam(unitSlug, contentId),
      ),
    );

    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: 'تفاصيل الإعلان',
      showTitleSection: false,
      child: PwfSectionContainer(
        sectionKey: 'PwfAnnouncementDetailWebScreen',
        child: async.when(
          data: (item) {
            if (item == null) {
              return const PwfEmptyBlock(
                title: 'الإعلان غير موجود',
                message:
                    'العنصر غير منشور أو لا يطابق نطاق الوحدة أو فئة المحتوى المطلوبة.',
                icon: Icons.notifications_off_outlined,
              );
            }
            return _AnnouncementDetailBody(item: item, unitSlug: unitSlug);
          },
          loading: () =>
              const PwfLoadingBlock(message: 'جاري تحميل تفاصيل الإعلان...'),
          error: (e, _) => PwfErrorBlock(
            onRetry: () => ref.invalidate(
              announcementContentDetailForUnitProvider(
                UnitAnnouncementContentIdParam(unitSlug, contentId),
              ),
            ),
            message: e.toString(),
          ),
        ),
      ),
    );
  }
}

class _InlineComplementaryAnnouncementsCard extends StatelessWidget {
  const _InlineComplementaryAnnouncementsCard({
    required this.unitSlug,
    required this.isHomeScope,
    required this.items,
    required this.totalCount,
  });

  final String unitSlug;
  final bool isHomeScope;
  final List<Announcement> items;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return PwfSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isHomeScope ? 'تنويهات من الوحدات والأنظمة' : 'تنويهات من الوزارة',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: PwfHomePalette.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isHomeScope
                ? 'مساحة تعريفية مرافقة تُظهر إعلانات الوحدات والأنظمة بعد تطبيق نفس الفلاتر الحالية.'
                : 'مساحة تعريفية مرافقة تُظهر الإعلانات الوزارية بعد تطبيق نفس الفلاتر الحالية على الصفحة.',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: PwfHomePalette.gray,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'عدد الإعلانات المعروضة: $totalCount',
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              color: PwfHomePalette.gray,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final item in items)
                SizedBox(
                  width: 260,
                  child: OutlinedButton(
                    onPressed: () => context.go(
                      UnitRoutes.announcementDetail(unitSlug, item.publicDetailId),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.centerRight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: GoogleFonts.cairo(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: PwfHomePalette.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: PwfHomePalette.gray,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnnouncementFiltersCard extends StatelessWidget {
  const _AnnouncementFiltersCard({
    required this.query,
    required this.selectedPriority,
    required this.activeOnly,
    required this.importantOnly,
    required this.onQueryChanged,
    required this.onPriorityChanged,
    required this.onActiveOnlyChanged,
    required this.onImportantOnlyChanged,
  });

  final String query;
  final Priority? selectedPriority;
  final bool activeOnly;
  final bool importantOnly;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<Priority?> onPriorityChanged;
  final ValueChanged<bool> onActiveOnlyChanged;
  final ValueChanged<bool> onImportantOnlyChanged;

  @override
  Widget build(BuildContext context) {
    return PwfSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'فلترة الإعلانات',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: PwfHomePalette.primary,
            ),
          ),
          const SizedBox(height: 12),
          PwfSearchBox(
            hint: 'ابحث في الإعلانات بالعناوين أو النصوص...',
            initialValue: query,
            onChanged: onQueryChanged,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PwfFilterChipButton(
                label: 'كل الأولويات',
                selected: selectedPriority == null,
                onTap: () => onPriorityChanged(null),
              ),
              ...Priority.values.map(
                (priority) => PwfFilterChipButton(
                  label: priority.displayName,
                  selected: selectedPriority == priority,
                  selectedColor: _priorityColor(priority),
                  onTap: () => onPriorityChanged(priority),
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
                label: 'النشطة فقط',
                selected: activeOnly,
                selectedColor: const Color(0xFF1D7A46),
                onTap: () => onActiveOnlyChanged(!activeOnly),
              ),
              PwfFilterChipButton(
                label: 'المهمة فقط',
                selected: importantOnly,
                selectedColor: PwfHomePalette.royalRed,
                onTap: () => onImportantOnlyChanged(!importantOnly),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnnouncementHeroCard extends StatelessWidget {
  const _AnnouncementHeroCard({required this.item, required this.unitSlug});

  final Announcement item;
  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(item.priority);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: PwfHomeRadii.br20,
        border: Border.all(color: color.withValues(alpha: 0.22), width: 1.3),
        boxShadow: const [
          BoxShadow(
            color: PwfHomePalette.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PwfMetaBadge(
                label: item.priority.displayName,
                icon: Icons.priority_high,
                color: color,
              ),
              if (item.isPinned)
                const PwfMetaBadge(
                  label: 'مثبت',
                  icon: Icons.push_pin,
                  color: PwfHomePalette.royalRed,
                ),
              PwfMetaBadge(
                label: item.isActive ? 'نشط' : 'غير نشط',
                icon: item.isActive
                    ? Icons.check_circle_outline
                    : Icons.pause_circle_outline,
                color: item.isActive
                    ? const Color(0xFF1D7A46)
                    : PwfHomePalette.textSecondary,
              ),
              if (item.validUntil != null)
                PwfMetaBadge(
                  label: 'حتى ${pwfFormatArabicDate(item.validUntil)}',
                  icon: Icons.event_available_outlined,
                  color: PwfHomePalette.textSecondary,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: GoogleFonts.cairo(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 1.35,
              color: PwfHomePalette.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.content,
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
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: PwfHomePalette.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    pwfFormatArabicDate(item.createdAt),
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
                    Icons.groups_outlined,
                    size: 16,
                    color: PwfHomePalette.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.targetAudience,
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
            onPressed: () =>
                context.go(UnitRoutes.announcementDetail(unitSlug, item.publicDetailId)),
            icon: const Icon(Icons.arrow_back),
            label: const Text('عرض تفاصيل الإعلان'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PwfHomePalette.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementsGrid extends StatelessWidget {
  const _AnnouncementsGrid({required this.items, required this.unitSlug});

  final List<Announcement> items;
  final String unitSlug;

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
            mainAxisExtent: 450,
          ),
          itemBuilder: (context, index) =>
              _AnnouncementCard(item: items[index], unitSlug: unitSlug),
        );
      },
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.item, required this.unitSlug});

  final Announcement item;
  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(item.priority);
    return InkWell(
      onTap: () => context.go(UnitRoutes.announcementDetail(unitSlug, item.publicDetailId)),
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
                height: 170,
                width: double.infinity,
                child: item.imageUrl?.trim().isNotEmpty == true
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const _AnnouncementImageFallback(),
                      )
                    : const _AnnouncementImageFallback(),
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
                          label: item.priority.displayName,
                          icon: Icons.priority_high,
                          color: color,
                        ),
                        if (item.isPinned)
                          const PwfMetaBadge(
                            label: 'مثبت',
                            icon: Icons.push_pin,
                            color: PwfHomePalette.royalRed,
                          ),
                        if (!item.isActive)
                          const PwfMetaBadge(
                            label: 'مغلق',
                            icon: Icons.pause_circle_outline,
                            color: PwfHomePalette.textSecondary,
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
                      item.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        height: 1.8,
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
                              pwfFormatArabicDate(item.createdAt),
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                color: PwfHomePalette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (item.validUntil != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.event_available_outlined,
                                size: 16,
                                color: PwfHomePalette.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'حتى ${pwfFormatArabicDate(item.validUntil)}',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.5,
                                  color: PwfHomePalette.textSecondary,
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
                          'قراءة الإعلان',
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

class _AnnouncementImageFallback extends StatelessWidget {
  const _AnnouncementImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PwfHomePalette.primary.withValues(alpha: 0.08),
      child: const Center(
        child: Icon(
          Icons.campaign_outlined,
          size: 42,
          color: PwfHomePalette.primary,
        ),
      ),
    );
  }
}

class _AnnouncementDetailBody extends ConsumerWidget {
  const _AnnouncementDetailBody({required this.item, required this.unitSlug});

  final Announcement item;
  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _priorityColor(item.priority);
    final unit = ref.watch(orgUnitBySlugProvider(unitSlug)).valueOrNull;
    final scopeLabel = pwfResolveScopeLabel(unitSlug: unitSlug, unit: unit);
    final relatedItems =
        (ref.watch(announcementsForUnitProvider(unitSlug)).valueOrNull ??
                const <Announcement>[])
            .where((e) => e.id != item.id)
            .take(3)
            .toList(growable: false);
    final detailPath = UnitRoutes.announcementDetail(unitSlug, item.publicDetailId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PwfInternalPublicPageIntro(
          specKey: 'announcements',
          wrapInSectionContainer: false,
          title: item.title,
          subtitle:
              'عرض تفصيلي للإعلان الرسمي ضمن واجهة متسقة مع الصفحة الرئيسية وخيارات العرض العامة.',
          icon: Icons.campaign_outlined,
          unitSlug: unitSlug,
          note:
              'يعرض هذا الإعلان ضمن نطاق $scopeLabel مع بيانات الصلاحية والأولوية وحالة النشر والفئة المستهدفة.',
        ),
        const SizedBox(height: 18),
        PwfDetailActionsBar(
          subtitle:
              'يمكنك الرجوع إلى قائمة الإعلانات أو نسخ رابط هذا الإعلان للمشاركة المرجعية.',
          actions: [
            FilledButton.icon(
              onPressed: () => context.go(UnitRoutes.announcements(unitSlug)),
              icon: const Icon(Icons.view_list_rounded),
              label: const Text('كل الإعلانات'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(UnitRoutes.announcements(unitSlug));
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
                    const SnackBar(content: Text('تم نسخ رابط الإعلان')),
                  );
                }
              },
              icon: const Icon(Icons.link_rounded),
              label: const Text('نسخ الرابط'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        PwfSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PwfDetailSectionTitle(
                title: 'بيانات الإعلان',
                subtitle:
                    'ملخص الإدخال وحالة الإعلان والفئة المستهدفة ومدة الصلاحية.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  PwfMetaBadge(
                    label: item.priority.displayName,
                    icon: Icons.priority_high,
                    color: color,
                  ),
                  PwfMetaBadge(
                    label: item.isActive ? 'نشط' : 'غير نشط',
                    icon: item.isActive
                        ? Icons.check_circle_outline
                        : Icons.pause_circle_outline,
                    color: item.isActive
                        ? const Color(0xFF1D7A46)
                        : PwfHomePalette.textSecondary,
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
                  if (item.validUntil != null)
                    PwfMetaBadge(
                      label: 'ينتهي ${pwfFormatArabicDate(item.validUntil)}',
                      icon: Icons.event_available_outlined,
                      color: PwfHomePalette.textSecondary,
                    ),
                  PwfMetaBadge(
                    label: item.targetAudience,
                    icon: Icons.groups_outlined,
                    color: PwfHomePalette.textSecondary,
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
                    label: 'تاريخ الإنشاء',
                    value: pwfFormatArabicDate(item.createdAt),
                    icon: Icons.calendar_today_outlined,
                  ),
                  if (item.publishAt != null)
                    PwfDetailInfoItem(
                      label: 'تاريخ النشر',
                      value: pwfFormatArabicDate(item.publishAt),
                      icon: Icons.schedule_outlined,
                    ),
                  if ((item.attachmentUrl ?? '').trim().isNotEmpty)
                    const PwfDetailInfoItem(
                      label: 'مرفق',
                      value: 'يوجد مرفق مرتبط بالإعلان',
                      icon: Icons.attach_file_outlined,
                    ),
                  if ((item.imageUrl ?? '').trim().isNotEmpty)
                    const PwfDetailInfoItem(
                      label: 'صورة',
                      value: 'توجد صورة مرافقة للإعلان',
                      icon: Icons.image_outlined,
                    ),
                ],
              ),
              if ((item.imageUrl ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: PwfHomeRadii.br20,
                  child: SizedBox(
                    width: double.infinity,
                    height: 320,
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: PwfHomePalette.primary.withValues(alpha: 0.08),
                        child: const Center(
                          child: Icon(
                            Icons.campaign_outlined,
                            size: 40,
                            color: PwfHomePalette.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              const PwfDetailSectionTitle(title: 'نص الإعلان'),
              const SizedBox(height: 10),
              SelectableText(
                item.content,
                style: GoogleFonts.cairo(
                  fontSize: 15.5,
                  height: 2.0,
                  color: const Color(0xFF1E293B),
                ),
              ),
              if ((item.attachmentUrl ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: item.attachmentUrl!),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ رابط المرفق')),
                      );
                    }
                  },
                  icon: const Icon(Icons.attach_file_outlined),
                  label: const Text('نسخ رابط المرفق'),
                ),
              ],
            ],
          ),
        ),
        if (relatedItems.isNotEmpty) ...[
          const SizedBox(height: 18),
          PwfRelatedLinksCard(
            title: 'إعلانات ذات صلة',
            subtitle: 'عناصر أخرى من نفس النطاق لمتابعة المستجدات والتنويهات.',
            children: [
              for (final related in relatedItems)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => context.go(
                      UnitRoutes.announcementDetail(unitSlug, related.publicDetailId),
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
                          Icon(
                            Icons.campaign_outlined,
                            color: _priorityColor(related.priority),
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
                                  related.content,
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

bool _isImportant(Priority priority) {
  return priority == Priority.high ||
      priority == Priority.urgent ||
      priority == Priority.critical;
}

int _priorityRank(Priority priority) {
  switch (priority) {
    case Priority.critical:
      return 6;
    case Priority.urgent:
      return 5;
    case Priority.high:
      return 4;
    case Priority.medium:
      return 3;
    case Priority.normal:
      return 2;
    case Priority.low:
      return 1;
  }
}

Color _priorityColor(Priority priority) {
  switch (priority) {
    case Priority.critical:
      return const Color(0xFF7F1D1D);
    case Priority.urgent:
      return const Color(0xFFB22222);
    case Priority.high:
      return const Color(0xFFC2410C);
    case Priority.medium:
      return const Color(0xFF9A7A00);
    case Priority.normal:
      return PwfHomePalette.primary;
    case Priority.low:
      return PwfHomePalette.textSecondary;
  }
}
