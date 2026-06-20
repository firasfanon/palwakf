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
    final unitId = await ref.watch(unitIdBySlugExactProvider(unitSlug).future);
    if (unitId == null || unitId.isEmpty) return const <Activity>[];
    return ref
        .read(unitActivityRepositoryProvider)
        .getAllActivitiesForUnit(unitId, unitSlug: unitSlug);
  },
);

class UnitActivityIdParam {
  final String unitSlug;
  final int id;
  const UnitActivityIdParam(this.unitSlug, this.id);
}



class UnitActivityContentIdParam {
  const UnitActivityContentIdParam(this.unitSlug, this.contentId);

  final String unitSlug;
  final String contentId;

  String get normalizedUnitSlug {
    final value = unitSlug.trim().toLowerCase();
    return value.isEmpty ? 'home' : value;
  }

  @override
  bool operator ==(Object other) =>
      other is UnitActivityContentIdParam &&
      other.normalizedUnitSlug == normalizedUnitSlug &&
      other.contentId == contentId;

  @override
  int get hashCode => Object.hash(normalizedUnitSlug, contentId);
}

/// Direct public detail RPC provider; no bounded feed/cache fallback.
final activityContentDetailForUnitProvider =
    FutureProvider.family<Activity?, UnitActivityContentIdParam>((ref, p) async {
      final unitId = await ref.watch(
        unitIdBySlugExactProvider(p.normalizedUnitSlug).future,
      );
      if (unitId == null || unitId.isEmpty) return null;
      return ref.read(unitActivityRepositoryProvider).getActivityByContentIdForUnit(
            p.contentId,
            unitId,
            unitSlug: p.normalizedUnitSlug,
          );
    });

/// Activity detail for unit.
/// Returns null when the requested item is not owned by this unit.
final activityForUnitByIdProvider =
    FutureProvider.family<Activity?, UnitActivityIdParam>((ref, p) async {
      final unitId = await ref.watch(unitIdBySlugExactProvider(p.unitSlug).future);
      if (unitId == null || unitId.isEmpty) return null;
      return ref
          .read(unitActivityRepositoryProvider)
          .getActivityByIdForUnit(
            p.id,
            unitId,
            unitSlug: p.unitSlug,
          );
    });

final filteredActivitiesForUnitProvider =
    FutureProvider.family<List<Activity>, String>((ref, unitSlug) async {
      final repo = ref.read(unitActivityRepositoryProvider);
      final filter = ref.watch(activitiesFilterProvider);
      final unitId = await ref.watch(unitIdBySlugExactProvider(unitSlug).future);
      if (unitId == null || unitId.isEmpty) return const <Activity>[];

      List<Activity> items;
      if (filter.category != null) {
        items = await repo.getActivitiesByCategoryForUnit(
          filter.category!,
          unitId,
          unitSlug: unitSlug,
        );
      } else if (filter.status != null) {
        items = await repo.getActivitiesByStatusForUnit(
          filter.status!,
          unitId,
          unitSlug: unitSlug,
        );
      } else {
        items = await repo.getAllActivitiesForUnit(unitId, unitSlug: unitSlug);
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
