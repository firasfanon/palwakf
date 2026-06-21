import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/news_article.dart';
import 'media_compat_mapper.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';
import 'package:waqf/core/public_runtime/pwf_public_media_runtime_gateway.dart';

class NewsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const bool _forceLegacyPublicMedia = bool.fromEnvironment(
    'PWF_FORCE_LEGACY_PUBLIC_MEDIA',
    defaultValue: false,
  );
  static const bool _mediaOwnerReadDefault = !_forceLegacyPublicMedia;
  static const Duration _mediaOwnerRuntimeTimeout = Duration(seconds: 8);

  Future<List<NewsArticle>> _getCompatNews({
    int? limit,
    int? offset,
    String? unitSlug,
    String? ownerOrgUnitId,
    Set<String>? unitScopeKeys,
    NewsCategory? category,
    String? searchQuery,
  }) async {
    if (!_mediaOwnerReadDefault) {
      _logMediaRuntimeFallback(
        family: 'news',
        reason: 'forced-legacy-public-media',
      );
      return const <NewsArticle>[];
    }

    try {
      final unitRef = unitSlug?.trim().isNotEmpty == true
          ? unitSlug!.trim()
          : (ownerOrgUnitId?.trim().isNotEmpty == true
              ? ownerOrgUnitId!.trim()
              : 'home');
      final rows = await PwfPublicMediaRuntimeGateway(
        _supabase,
      ).fetchFeed(
        unitRef: unitRef,
        familyKey: 'news',
        limit: (limit ?? 50).clamp(1, 50).toInt(),
        offset: 0,
      ).timeout(_mediaOwnerRuntimeTimeout);

      var items = rows
          .map(MediaCompatMapper.newsFromCompatRow)
          .where((article) => article.status == PublishStatus.published)
          .toList();

      if (category != null && category != NewsCategory.general) {
        items = items.where((article) => article.category == category).toList();
      }

      final q = searchQuery?.trim().toLowerCase();
      if (q != null && q.isNotEmpty) {
        items = items.where((article) {
          return article.title.toLowerCase().contains(q) ||
              article.content.toLowerCase().contains(q) ||
              article.excerpt.toLowerCase().contains(q);
        }).toList();
      }
      _sortNewsOwnerRows(items);
      final windowed = _window(items, limit: limit, offset: offset);
      _logMediaRuntimeSource(
        family: 'news',
        surface: PwfDatabaseOwnerSurfaces.publicMediaRuntimeFeedRpcV2,
        rows: windowed.length,
      );
      return windowed;
    } on TimeoutException {
      _logMediaRuntimeFallback(family: 'news', reason: 'public-rpc-timeout');
      return const <NewsArticle>[];
    } catch (_) {
      if (kDebugMode) {
        debugPrint(
          'PWF_MEDIA_CENTER_PUBLIC_RPC_UNAVAILABLE '
          'family=news '
          'rpc=${PwfDatabaseOwnerSurfaces.publicMediaRuntimeFeedRpcV2} '
          'fallback=false',
        );
      }
      _logMediaRuntimeFallback(family: 'news', reason: 'public-rpc-failure');
      return const <NewsArticle>[];
    }
  }

  void _sortNewsOwnerRows(List<NewsArticle> items) {
    items.sort((a, b) {
      final pinned = _boolDesc(a.isPinned, b.isPinned);
      if (pinned != 0) return pinned;
      final order = a.sortOrder.compareTo(b.sortOrder);
      if (order != 0) return order;
      final aDate = a.publishedAt ?? a.createdAt;
      final bDate = b.publishedAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
  }

  int _boolDesc(bool a, bool b) => a == b ? 0 : (a ? -1 : 1);

  List<T> _window<T>(List<T> items, {int? limit, int? offset}) {
    final start = offset == null || offset < 0 ? 0 : offset;
    if (start >= items.length) return <T>[];
    final end = limit == null
        ? items.length
        : (start + limit).clamp(0, items.length).toInt();
    return items.sublist(start, end);
  }

  void _logMediaRuntimeSource({
    required String family,
    required String surface,
    required int rows,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      'PWF_MEDIA_CENTER_ROOT_CUTOVER '
      'family=$family '
      'public_rpc=true '
      'surface=$surface '
      'projection=allow-listed '
      'filtering=server-resolved-unit '
      'ordering=server-side '
      'rows=$rows '
      'decision=media-center-owner-read-default-root-cutover',
    );
  }

  void _logMediaRuntimeFallback({
    required String family,
    required String reason,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      'PWF_MEDIA_CENTER_LEGACY_FALLBACK_ONLY '
      'family=$family '
      'legacy_public_fallback=false '
      'reason=$reason '
      'decision=media-center-owner-read-no-public-fallback',
    );
  }

  Future<NewsArticle?> _getCompatNewsByContentId(
    String contentId, {
    String? unitSlug,
    String? ownerOrgUnitId,
  }) async {
    if (!_mediaOwnerReadDefault) return null;
    final safeContentId = contentId.trim();
    if (safeContentId.isEmpty) return null;
    final unitRef = unitSlug?.trim().isNotEmpty == true
        ? unitSlug!.trim()
        : (ownerOrgUnitId?.trim().isNotEmpty == true
            ? ownerOrgUnitId!.trim()
            : 'home');
    try {
      final rows = await PwfPublicMediaRuntimeGateway(_supabase)
          .fetchDetail(
            unitRef: unitRef,
            contentId: safeContentId,
            familyKey: 'news',
          )
          .timeout(_mediaOwnerRuntimeTimeout);
      if (rows.isEmpty) return null;
      final article = MediaCompatMapper.newsFromCompatRow(rows.first);
      if (article.status != PublishStatus.published) return null;
      if (article != null) {
        _logMediaRuntimeSource(
          family: 'news',
          surface: PwfDatabaseOwnerSurfaces.publicMediaRuntimeDetailRpcV2,
          rows: 1,
        );
      }
      return article;
    } on TimeoutException {
      _logMediaRuntimeFallback(family: 'news', reason: 'public-detail-rpc-timeout');
      return null;
    } catch (_) {
      if (kDebugMode) {
        debugPrint(
          'PWF_MEDIA_CENTER_PUBLIC_DETAIL_RPC_UNAVAILABLE '
          'family=news '
          'rpc=${PwfDatabaseOwnerSurfaces.publicMediaRuntimeDetailRpcV2} '
          'fallback=false',
        );
      }
      _logMediaRuntimeFallback(family: 'news', reason: 'public-detail-rpc-failure');
      return null;
    }
  }



  // Public root reads are owner-runtime only. Empty is a valid result;
  // Public runtime reads only — no fallback data.
  Future<List<NewsArticle>> getAllNews({int? limit, int? offset}) {
    return _getCompatNews(limit: limit, offset: offset);
  }

  Future<List<NewsArticle>> getFeaturedNews({int limit = 5}) async {
    final items = await _getCompatNews(limit: limit);
    return items.where((article) => article.isFeatured).take(limit).toList();
  }

  Future<List<NewsArticle>> getLatestNews({int limit = 10}) {
    return _getCompatNews(limit: limit);
  }

  Future<List<NewsArticle>> getNewsByCategory(NewsCategory category) {
    return _getCompatNews(category: category);
  }

  Future<NewsArticle?> getNewsById(int id) {
    return _getCompatNewsByContentId(id.toString());
  }

  /// Scoped public detail resolver. No feed/cache/list fallback is permitted.
  Future<NewsArticle?> getNewsByContentIdForUnit(
    String contentId,
    String unitId, {
    String? unitSlug,
  }) {
    return _getCompatNewsByContentId(
      contentId,
      unitSlug: unitSlug ?? unitId,
      ownerOrgUnitId: unitId,
    );
  }

  Future<List<NewsArticle>> searchNews(String query) {
    return _getCompatNews(searchQuery: query);
  }

  Future<Map<String, dynamic>> getNewsStatistics() async {
    final source = await _getCompatNews(limit: 1000);
    return {
      'total_news': source.length,
      'featured_news': source.where((a) => a.isFeatured).length,
      'categories': NewsCategory.values.length,
      'runtime_source': PwfDatabaseOwnerSurfaces.unitPublicNewsRuntimeV1,
      'runtime_decision': 'owner-runtime-only-no-sample-fallback',
    };
  }

  // Increment view count
  Future<void> incrementViewCount(int articleId) async {
    try {
      await _supabase.rpc(
        'increment_view_count',
        params: {'article_id': articleId},
      );
    } catch (e) {
      // Handle error silently
    }
  }

  List<NewsArticle> sampleNewsForDevelopmentOnly() {
    return const <NewsArticle>[];
  }

  // ============================
  // Unit-scoped methods (Institutional routing)
  // ============================

  Future<List<NewsArticle>> getAllNewsForUnit(
    String unitId, {
    String? unitSlug,
    int? limit,
    int? offset,
  }) async {
    final compat = await _getCompatNews(
      limit: limit,
      offset: offset,
      unitSlug: unitSlug ?? unitId,
      ownerOrgUnitId: unitId,
    );
    return compat;
  }

  Future<List<NewsArticle>> getLatestNewsForUnit(
    String unitId, {
    String? unitSlug,
    int limit = 10,
  }) async {
    final compat = await _getCompatNews(
      limit: limit,
      unitSlug: unitSlug ?? unitId,
      ownerOrgUnitId: unitId,
    );
    return compat;
  }

  Future<List<NewsArticle>> getFeaturedNewsForUnit(
    String unitId, {
    String? unitSlug,
    int limit = 5,
  }) async {
    final compat = await _getCompatNews(
      limit: limit,
      unitSlug: unitSlug ?? unitId,
      ownerOrgUnitId: unitId,
    );
    return compat.take(limit).toList();
  }

  Future<List<NewsArticle>> getNewsByCategoryForUnit(
    NewsCategory category,
    String unitId, {
    String? unitSlug,
  }) async {
    final compat = await _getCompatNews(
      category: category,
      unitSlug: unitSlug ?? unitId,
      ownerOrgUnitId: unitId,
    );
    return compat;
  }

  Future<NewsArticle?> getNewsByIdForUnit(
    int id,
    String unitId, {
    String? unitSlug,
  }) async {
    final compat = await _getCompatNewsByContentId(
      id.toString(),
      unitSlug: unitSlug ?? unitId,
      ownerOrgUnitId: unitId,
    );
    return compat;
  }

  Future<List<NewsArticle>> searchNewsForUnit(
    String query,
    String unitId, {
    String? unitSlug,
  }) async {
    final compat = await _getCompatNews(
      searchQuery: query,
      unitSlug: unitSlug ?? unitId,
      ownerOrgUnitId: unitId,
    );
    return compat;
  }
}
