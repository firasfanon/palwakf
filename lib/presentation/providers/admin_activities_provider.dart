import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/activity.dart';
import 'package:waqf/presentation/providers/supabase_providers.dart';
import 'unit_context_provider.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

@immutable
class AdminActivitiesQuery {
  final String unitSlug;
  final String search;
  final int limit;

  const AdminActivitiesQuery({
    required this.unitSlug,
    this.search = '',
    this.limit = 80,
  });

  @override
  bool operator ==(Object other) {
    return other is AdminActivitiesQuery &&
        other.unitSlug == unitSlug &&
        other.search == search &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(unitSlug, search, limit);
}

final adminActivitiesProvider =
    FutureProvider.family<List<Activity>, AdminActivitiesQuery>((ref, q) async {
      final unitId = await ref.watch(unitIdBySlugProvider(q.unitSlug).future);
      final supabase = ref.watch(supabaseServiceProvider).client;

      // postgrest 2.x typing nuance:
      // - apply filters (eq/or) while the builder is still a FilterBuilder
      // - calling order/limit turns it into a TransformBuilder (where eq/or are not visible)
      dynamic query = supabase
          .from(PwfDatabaseOwnerSurfaces.activities)
          .select()
          .eq('unit_id', unitId);

      final s = q.search.trim();
      if (s.isNotEmpty) {
        final like = '%$s%';
        query = query.or('title.ilike.$like,description.ilike.$like');
      }

      final res = await query
          .order('start_date', ascending: false)
          .limit(q.limit);
      final items = (res as List)
          .map((e) => Activity.fromDb(e as Map<String, dynamic>))
          .toList(growable: true);
      items.sort((a, b) {
        final pinned = (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0);
        if (pinned != 0) return pinned;
        final featured = (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0);
        if (featured != 0) return featured;
        final order = b.sortOrder.compareTo(a.sortOrder);
        if (order != 0) return order;
        return (b.publishAt ?? b.startDate).compareTo(
          a.publishAt ?? a.startDate,
        );
      });
      return List<Activity>.unmodifiable(items);
    });
