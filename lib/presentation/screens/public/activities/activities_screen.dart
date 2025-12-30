import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/utils/text_normalize.dart';
import '../../../../data/models/activity.dart';
import '../../../providers/activities_provider.dart';
import '../../../providers/unit_activities_provider.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/web/web_public_page.dart';
import '../../../widgets/common/app_filter_chip.dart';

class ActivitiesScreen extends ConsumerWidget {
  final String unitSlug;

  const ActivitiesScreen({super.key, required this.unitSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(activitiesFilterProvider);

    if (kIsWeb) {
      return WebPublicPage(
        title: 'الأنشطة',
        subtitle: 'فعاليات الوزارة وأنشطتها ومواعيدها',
        headerExtras: (_) => _WebHeaderFilters(filter: filter),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: _ActivitiesBody(unitSlug: unitSlug, isWeb: true, showFiltersCard: false),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'الأنشطة'),
        body: Padding(
          padding: EdgeInsets.all(AppConstants.paddingM),
          child: _ActivitiesBody(unitSlug: unitSlug, isWeb: false, showFiltersCard: true),
        ),
      ),
    );
  }
}

class _WebHeaderFilters extends ConsumerWidget {
  final ActivitiesFilter filter;
  const _WebHeaderFilters({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Search box (kept white for readability over gradient)
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: TextField(
              onChanged: ref.read(activitiesFilterProvider.notifier).setSearchQuery,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: 'بحث في الأنشطة (العنوان/الوصف/المكان)...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            AppFilterChip(
              label: 'كل الفئات',
              isSelected: filter.category == null,
              onSelected: () => ref.read(activitiesFilterProvider.notifier).setCategory(null),
              onDarkBackground: true,
            ),
            ...ActivityCategory.values.map(
              (c) => AppFilterChip(
                label: c.displayName,
                isSelected: filter.category == c,
                onSelected: () => ref.read(activitiesFilterProvider.notifier).setCategory(c),
                onDarkBackground: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            AppFilterChip(
              label: 'كل الحالات',
              isSelected: filter.status == null,
              onSelected: () => ref.read(activitiesFilterProvider.notifier).setStatus(null),
              onDarkBackground: true,
            ),
            ...ActivityStatus.values.map(
              (s) => AppFilterChip(
                label: s.displayName,
                isSelected: filter.status == s,
                onSelected: () => ref.read(activitiesFilterProvider.notifier).setStatus(s),
                onDarkBackground: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActivitiesBody extends ConsumerWidget {
  final String unitSlug;
  final bool isWeb;
  final bool showFiltersCard;
  const _ActivitiesBody({required this.unitSlug, required this.isWeb, required this.showFiltersCard});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(activitiesFilterProvider);
    final async = ref.watch(filteredActivitiesForUnitProvider(unitSlug));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showFiltersCard) ...[
          _FiltersCard(isWeb: isWeb, filter: filter),
          const SizedBox(height: 16),
        ],
        async.when(
          data: (items) {
            if (items.isEmpty) {
              return _EmptyState(
                title: 'لا توجد أنشطة مطابقة',
                subtitle: filter.searchQuery.trim().isNotEmpty || filter.category != null || filter.status != null
                    ? 'جرّب إزالة عوامل التصفية أو تغيير كلمات البحث.'
                    : 'سيتم عرض أنشطة الوزارة هنا عند إضافتها.',
                onClear: () => ref.read(activitiesFilterProvider.notifier).clear(),
                showClear: filter.searchQuery.trim().isNotEmpty || filter.category != null || filter.status != null,
              );
            }

            if (isWeb) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () => ref.invalidate(filteredActivitiesForUnitProvider(unitSlug)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('تحديث'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActivitiesGridWeb(items: items),
                ],
              );
            }

            return Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(filteredActivitiesForUnitProvider(unitSlug));
                },
                child: _ActivitiesList(items: items),
              ),
            );
          },
          loading: () => isWeb
              ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              : const Expanded(child: Center(child: CircularProgressIndicator())),
          error: (e, _) => isWeb
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(e.toString(), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(filteredActivitiesForUnitProvider(unitSlug)),
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(e.toString(), textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => ref.invalidate(filteredActivitiesForUnitProvider(unitSlug)),
                            icon: const Icon(Icons.refresh),
                            label: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _FiltersCard extends ConsumerWidget {
  final bool isWeb;
  final ActivitiesFilter filter;
  const _FiltersCard({required this.isWeb, required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: isWeb ? const EdgeInsets.all(18) : const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: ref.read(activitiesFilterProvider.notifier).setSearchQuery,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'بحث في الأنشطة (العنوان/الوصف/المكان)...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppFilterChip(
                label: 'كل الفئات',
                isSelected: filter.category == null,
                onSelected: () => ref.read(activitiesFilterProvider.notifier).setCategory(null),
              ),
              ...ActivityCategory.values.map(
                (c) => AppFilterChip(
                  label: _categoryLabel(c),
                  isSelected: filter.category == c,
                  onSelected: () => ref.read(activitiesFilterProvider.notifier).setCategory(c),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppFilterChip(
                label: 'كل الحالات',
                isSelected: filter.status == null,
                onSelected: () => ref.read(activitiesFilterProvider.notifier).setStatus(null),
              ),
              ...ActivityStatus.values.map(
                (s) => AppFilterChip(
                  label: _statusLabel(s),
                  isSelected: filter.status == s,
                  onSelected: () => ref.read(activitiesFilterProvider.notifier).setStatus(s),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _categoryLabel(ActivityCategory c) {
    // Use model extension labels (covers all enum values).
    return c.displayName;
  }

  String _statusLabel(ActivityStatus s) {
    return s.displayName;
  }
}

class _ActivitiesList extends StatelessWidget {
  final List<Activity> items;
  const _ActivitiesList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _ActivityCard(activity: items[i]),
    );
  }
}

class _ActivitiesGridWeb extends StatelessWidget {
  final List<Activity> items;
  const _ActivitiesGridWeb({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cols = w >= 1100 ? 3 : (w >= 760 ? 2 : 1);
        return GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: cols == 1 ? 2.2 : 1.45,
          ),
          itemCount: items.length,
          itemBuilder: (context, i) => _ActivityCard(activity: items[i]),
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;
  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final start = activity.startDate;
    final end = activity.endDate;

    final dateText = end == null
        ? app_date.AppDateUtils.formatArabicDate(start)
        : '${app_date.AppDateUtils.formatArabicDate(start)} - ${app_date.AppDateUtils.formatArabicDate(end)}';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    normalizeRichText(activity.title),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                _Pill(
                  text: _statusPill(activity.status),
                  icon: Icons.event,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dateText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
            if (activity.location.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[700]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      normalizeRichText(activity.location),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Text(
              normalizeRichText(activity.description).trim().isNotEmpty
                  ? normalizeRichText(activity.description).trim()
                  : '—',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _statusPill(ActivityStatus? s) => s?.displayName ?? '—';
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Pill({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              // color will be inherited by DefaultTextStyle if needed
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onClear;
  final bool showClear;
  const _EmptyState({
    required this.title,
    required this.subtitle,
    this.onClear,
    this.showClear = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy, size: 52, color: Colors.grey),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            if (showClear && onClear != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.clear_all),
                label: const Text('إزالة التصفية'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
