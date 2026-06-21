import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/news_article.dart';
import 'package:waqf/presentation/providers/supabase_providers.dart';
import 'unit_context_provider.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

@immutable
class AdminNewsQuery {
  final String unitSlug;
  final bool includeAllStatuses;
  final String search;
  final int limit;

  const AdminNewsQuery({
    required this.unitSlug,
    this.includeAllStatuses = true,
    this.search = '',
    this.limit = 50,
  });

  @override
  bool operator ==(Object other) {
    return other is AdminNewsQuery &&
        other.unitSlug == unitSlug &&
        other.includeAllStatuses == includeAllStatuses &&
        other.search == search &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(unitSlug, includeAllStatuses, search, limit);
}

final adminNewsArticlesProvider =
    FutureProvider.family<List<NewsArticle>, AdminNewsQuery>((ref, q) async {
      final unitId = await ref.watch(unitIdBySlugExactProvider(q.unitSlug).future);
      if (unitId == null || unitId.isEmpty) {
        throw StateError('Unknown or unavailable editorial unit scope.');
      }
      final supabase = ref.watch(supabaseServiceProvider).client;

      // postgrest 2.x typing nuance:
      // - filter methods (eq/or) must be applied while the builder is still a FilterBuilder
      // - calling order/limit turns it into a TransformBuilder (where eq/or are not visible)
      dynamic query = supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select()
          .eq('unit_id', unitId);

      if (!q.includeAllStatuses) {
        query = query.eq('status', 'published');
      }

      final s = q.search.trim();
      if (s.isNotEmpty) {
        final like = '%$s%';
        query = query.or(
          'title.ilike.$like,excerpt.ilike.$like,content.ilike.$like',
        );
      }

      final res = await query
          .order('created_at', ascending: false)
          .limit(q.limit);
      final items = (res as List)
          .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
          .toList(growable: true);
      items.sort((a, b) {
        final pinned = (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0);
        if (pinned != 0) return pinned;
        final featured = (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0);
        if (featured != 0) return featured;
        final order = b.sortOrder.compareTo(a.sortOrder);
        if (order != 0) return order;
        return (b.publishedAt ?? b.createdAt).compareTo(
          a.publishedAt ?? a.createdAt,
        );
      });
      return List<NewsArticle>.unmodifiable(items);
    });
