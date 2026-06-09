import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/activity.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/services/supabase_service.dart';
import '../../core/utils/text_normalize.dart';
import 'unit_context_provider.dart';
import 'activities_provider.dart';

final unitActivityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository(SupabaseService());
});

/// Simple unfiltered list for unit pages (used by Web identity pages).
final activitiesForUnitProvider = FutureProvider.family<List<Activity>, String>(
  (ref, unitSlug) async {
    final unitId = await ref.watch(unitIdBySlugProvider(unitSlug).future);
    return ref
        .read(unitActivityRepositoryProvider)
        .getAllActivitiesForUnit(unitId);
  },
);

class UnitActivityIdParam {
  final String unitSlug;
  final int id;
  const UnitActivityIdParam(this.unitSlug, this.id);
}

/// Activity detail for unit.
/// Fail-open: repository falls back to global lookup if unit scoping fails.
final activityForUnitByIdProvider =
    FutureProvider.family<Activity?, UnitActivityIdParam>((ref, p) async {
      final unitId = await ref.watch(unitIdBySlugProvider(p.unitSlug).future);
      return ref
          .read(unitActivityRepositoryProvider)
          .getActivityByIdForUnit(p.id, unitId);
    });

final filteredActivitiesForUnitProvider =
    FutureProvider.family<List<Activity>, String>((ref, unitSlug) async {
      final repo = ref.read(unitActivityRepositoryProvider);
      final filter = ref.watch(activitiesFilterProvider);
      final unitId = await ref.watch(unitIdBySlugProvider(unitSlug).future);

      List<Activity> items;
      if (filter.category != null) {
        items = await repo.getActivitiesByCategoryForUnit(
          filter.category!,
          unitId,
        );
      } else if (filter.status != null) {
        items = await repo.getActivitiesByStatusForUnit(filter.status!, unitId);
      } else {
        items = await repo.getAllActivitiesForUnit(unitId);
      }

      final q = filter.searchQuery.trim();
      if (q.isNotEmpty) {
        final lower = q.toLowerCase();
        items = items.where((a) {
          final t = normalizeRichText(a.title).toLowerCase();
          final d = normalizeRichText(a.description).toLowerCase();
          final l = normalizeRichText(a.location).toLowerCase();
          return t.contains(lower) || d.contains(lower) || l.contains(lower);
        }).toList();
      }

      return items;
    });
