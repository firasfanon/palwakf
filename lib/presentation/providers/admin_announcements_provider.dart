import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/content/pwf_temporal_ordering.dart';

import '../../data/models/announcement.dart';
import 'package:waqf/presentation/providers/supabase_providers.dart';
import 'unit_context_provider.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

@immutable
class AdminAnnouncementsQuery {
  final String unitSlug;
  final bool includeInactive;
  final String search;
  final int limit;

  const AdminAnnouncementsQuery({
    required this.unitSlug,
    this.includeInactive = true,
    this.search = '',
    this.limit = 80,
  });

  @override
  bool operator ==(Object other) {
    return other is AdminAnnouncementsQuery &&
        other.unitSlug == unitSlug &&
        other.includeInactive == includeInactive &&
        other.search == search &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(unitSlug, includeInactive, search, limit);
}

final adminAnnouncementsProvider =
    FutureProvider.family<List<Announcement>, AdminAnnouncementsQuery>((
      ref,
      q,
    ) async {
      final unitId = await ref.watch(unitIdBySlugExactProvider(q.unitSlug).future);
      if (unitId == null || unitId.isEmpty) {
        throw StateError('Unknown or unavailable editorial unit scope.');
      }
      final supabase = ref.watch(supabaseServiceProvider).client;

      // postgrest 2.x typing nuance:
      // - apply filters (eq/or) while the builder is still a FilterBuilder
      // - calling order/limit turns it into a TransformBuilder (where eq/or are not visible)
      dynamic query = supabase
          .from(PwfDatabaseOwnerSurfaces.announcements)
          .select()
          .eq('unit_id', unitId);

      if (!q.includeInactive) {
        query = query.eq('is_active', true);
      }

      final s = q.search.trim();
      if (s.isNotEmpty) {
        final like = '%$s%';
        query = query.or('title.ilike.$like,content.ilike.$like');
      }

      final res = await query
          .order('publish_at', ascending: false)
          .order('created_at', ascending: false)
          .limit(q.limit);
      final items = (res as List)
          .map((e) => Announcement.fromDb(e as Map<String, dynamic>))
          .toList(growable: true);
      items.sort(
        (a, b) => PwfTemporalOrdering.newestFirst(
          a.publishAt ?? a.createdAt,
          b.publishAt ?? b.createdAt,
          leftStableKey: a.id.toString(),
          rightStableKey: b.id.toString(),
        ),
      );
      return List<Announcement>.unmodifiable(items);
    });
