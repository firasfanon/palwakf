import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/news_article.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

class NewsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // news_service.dart - Clean version
  Future<List<NewsArticle>> getAllNews({int? limit, int? offset}) async {
    try {
      var query = _supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select()
          .eq('status', 'published')
          .order('published_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getSampleNews();
    }
  }

  // Get featured news articles
  Future<List<NewsArticle>> getFeaturedNews({int limit = 5}) async {
    try {
      final response = await _supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select()
          .eq('status', 'published')
          .eq('is_featured', true)
          .order('published_at', ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getSampleNews().where((article) => article.isFeatured).toList();
    }
  }

  // Get latest news articles
  Future<List<NewsArticle>> getLatestNews({int limit = 10}) async {
    try {
      final response = await _supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select()
          .eq('status', 'published')
          .order('published_at', ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getSampleNews().take(limit).toList();
    }
  }

  // Get news by category
  Future<List<NewsArticle>> getNewsByCategory(NewsCategory category) async {
    try {
      final response = await _supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select()
          .eq('status', 'published')
          .eq('category', category.name)
          .order('published_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getSampleNews()
          .where((article) => article.category == category)
          .toList();
    }
  }

  // Get single news article by ID
  Future<NewsArticle?> getNewsById(int id) async {
    try {
      final response = await _supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select()
          .eq('id', id)
          .eq('status', 'published')
          .single();

      return NewsArticle.fromJson(response);
    } catch (e) {
      return _getSampleNews().firstWhere((article) => article.id == id);
    }
  }

  // Search news articles
  Future<List<NewsArticle>> searchNews(String query) async {
    try {
      final response = await _supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select()
          .eq('status', 'published')
          .or('title.ilike.%$query%,content.ilike.%$query%')
          .order('published_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getSampleNews()
          .where(
            (article) =>
                article.title.toLowerCase().contains(query.toLowerCase()) ||
                article.content.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  // Get news statistics
  Future<Map<String, dynamic>> getNewsStatistics() async {
    try {
      final totalNews = await _supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select('id')
          .eq('status', 'published')
          .count(CountOption.exact);

      final featuredNews = await _supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select('id')
          .eq('status', 'published')
          .eq('is_featured', true)
          .count(CountOption.exact);

      return {
        'total_news': totalNews.count,
        'featured_news': featuredNews.count,
        'categories': NewsCategory.values.length,
      };
    } catch (e) {
      final sampleNews = _getSampleNews();
      return {
        'total_news': sampleNews.length,
        'featured_news': sampleNews.where((a) => a.isFeatured).length,
        'categories': NewsCategory.values.length,
      };
    }
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

  List<NewsArticle> _getSampleNews() {
    return const <NewsArticle>[];
  }

  // ============================
  // Unit-scoped methods (Institutional routing)
  // ============================

  Future<List<NewsArticle>> getAllNewsForUnit(
    String unitId, {
    int? limit,
    int? offset,
  }) async {
    try {
      // Try unit-scoped query first. If unit_id column doesn't exist yet,
      // fall back to global (home) news to avoid breaking the homepage.
      dynamic response;
      try {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .eq('unit_id', unitId)
            .order('published_at', ascending: false)
            .limit(limit ?? 1000);
      } catch (_) {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .order('published_at', ascending: false)
            .limit(limit ?? 1000);
      }
      return (response as List).map((e) => NewsArticle.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<NewsArticle>> getLatestNewsForUnit(
    String unitId, {
    int limit = 10,
  }) async {
    try {
      dynamic response;
      try {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .eq('unit_id', unitId)
            .order('published_at', ascending: false)
            .limit(limit);
      } catch (_) {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .order('published_at', ascending: false)
            .limit(limit);
      }
      return (response as List).map((e) => NewsArticle.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<NewsArticle>> getFeaturedNewsForUnit(
    String unitId, {
    int limit = 5,
  }) async {
    try {
      dynamic response;
      try {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .eq('unit_id', unitId)
            .eq('is_featured', true)
            .order('published_at', ascending: false)
            .limit(limit);
      } catch (_) {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .eq('is_featured', true)
            .order('published_at', ascending: false)
            .limit(limit);
      }
      return (response as List).map((e) => NewsArticle.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<NewsArticle>> getNewsByCategoryForUnit(
    NewsCategory category,
    String unitId,
  ) async {
    try {
      dynamic response;
      try {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .eq('unit_id', unitId)
            .eq('category', category.name)
            .order('published_at', ascending: false);
      } catch (_) {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .eq('category', category.name)
            .order('published_at', ascending: false);
      }
      return (response as List).map((e) => NewsArticle.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<NewsArticle?> getNewsByIdForUnit(int id, String unitId) async {
    try {
      dynamic response;
      try {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('id', id)
            .eq('unit_id', unitId)
            .eq('status', 'published')
            .maybeSingle();
      } catch (_) {
        // Fallback when unit_id is not available in schema.
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('id', id)
            .eq('status', 'published')
            .maybeSingle();
      }
      if (response == null) return null;
      return NewsArticle.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  Future<List<NewsArticle>> searchNewsForUnit(
    String query,
    String unitId,
  ) async {
    try {
      dynamic response;
      try {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .eq('unit_id', unitId)
            .or('title.ilike.%$query%,content.ilike.%$query%')
            .order('published_at', ascending: false);
      } catch (_) {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .or('title.ilike.%$query%,content.ilike.%$query%')
            .order('published_at', ascending: false);
      }
      return (response as List).map((e) => NewsArticle.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
