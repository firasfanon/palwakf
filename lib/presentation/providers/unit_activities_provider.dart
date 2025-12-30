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

final filteredActivitiesForUnitProvider = FutureProvider.family<List<Activity>, String>((ref, unitSlug) async {
  final repo = ref.read(unitActivityRepositoryProvider);
  final filter = ref.watch(activitiesFilterProvider);
  final unitId = await ref.watch(unitIdBySlugProvider(unitSlug).future);

  List<Activity> items;
  if (filter.category != null) {
    items = await repo.getActivitiesByCategoryForUnit(filter.category!, unitId);
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
