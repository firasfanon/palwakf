import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/activity.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/services/supabase_service.dart';
import '../../core/utils/text_normalize.dart';
import 'unit_context_provider.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository(SupabaseService());
});

final activitiesFilterProvider =
    StateNotifierProvider<ActivitiesFilterNotifier, ActivitiesFilter>(
      (ref) => ActivitiesFilterNotifier(),
    );

class ActivitiesFilter {
  final ActivityCategory? category;
  final ActivityStatus? status;
  final String searchQuery;

  const ActivitiesFilter({this.category, this.status, this.searchQuery = ''});

  ActivitiesFilter copyWith({
    ActivityCategory? category,
    ActivityStatus? status,
    String? searchQuery,
    bool clearCategory = false,
    bool clearStatus = false,
  }) {
    return ActivitiesFilter(
      category: clearCategory ? null : (category ?? this.category),
      status: clearStatus ? null : (status ?? this.status),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ActivitiesFilterNotifier extends StateNotifier<ActivitiesFilter> {
  ActivitiesFilterNotifier() : super(const ActivitiesFilter());

  void setCategory(ActivityCategory? value) {
    state = state.copyWith(category: value, clearCategory: value == null);
  }

  void setStatus(ActivityStatus? value) {
    state = state.copyWith(status: value, clearStatus: value == null);
  }

  void setSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void clear() {
    state = const ActivitiesFilter();
  }
}

final filteredActivitiesProvider = FutureProvider<List<Activity>>((ref) async {
  final repo = ref.read(activityRepositoryProvider);
  final filter = ref.watch(activitiesFilterProvider);

  List<Activity> items;

  final homeUnitId = await ref.watch(unitIdBySlugExactProvider('home').future);
  if (homeUnitId == null || homeUnitId.isEmpty) return const <Activity>[];

  if (filter.category != null) {
    items = await repo.getActivitiesByCategoryForUnit(
      filter.category!,
      homeUnitId,
      unitSlug: 'home',
    );
  } else if (filter.status != null) {
    items = await repo.getActivitiesByStatusForUnit(
      filter.status!,
      homeUnitId,
      unitSlug: 'home',
    );
  } else {
    items = await repo.getAllActivitiesForUnit(homeUnitId, unitSlug: 'home');
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
