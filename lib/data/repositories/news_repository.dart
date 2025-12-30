import '../models/news_article.dart';
import '../services/news_service.dart';

class NewsRepository {
  final NewsService _newsService;

  NewsRepository(this._newsService);

  // Get all news
  Future<List<NewsArticle>> getAllNews({
    int? limit,
    int? offset,
  }) async {
    try {
      return await _newsService.getAllNews(
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }

  // Get featured news
  Future<List<NewsArticle>> getFeaturedNews({int limit = 5}) async {
    try {
      return await _newsService.getFeaturedNews(limit: limit);
    } catch (e) {
      throw Exception('Failed to load featured news: $e');
    }
  }

  // Get latest news
  Future<List<NewsArticle>> getLatestNews({int limit = 10}) async {
    try {
      return await _newsService.getLatestNews(limit: limit);
    } catch (e) {
      throw Exception('Failed to load latest news: $e');
    }
  }

  // Get news by category
  Future<List<NewsArticle>> getNewsByCategory(NewsCategory category) async {
    try {
      return await _newsService.getNewsByCategory(category);
    } catch (e) {
      throw Exception('Failed to load news by category: $e');
    }
  }

  // Get single news article
  Future<NewsArticle?> getNewsById(int id) async {
    try {
      return await _newsService.getNewsById(id);
    } catch (e) {
      throw Exception('Failed to load news article: $e');
    }
  }

  // Search news
  Future<List<NewsArticle>> searchNews(String query) async {
    try {
      if (query.isEmpty) return [];
      return await _newsService.searchNews(query);
    } catch (e) {
      throw Exception('Failed to search news: $e');
    }
  }

  // Get news statistics
  Future<Map<String, dynamic>> getNewsStatistics() async {
    try {
      return await _newsService.getNewsStatistics();
    } catch (e) {
      throw Exception('Failed to load news statistics: $e');
    }
  }

  // Increment view count
  Future<void> incrementViewCount(int articleId) async {
    try {
      await _newsService.incrementViewCount(articleId);
    } catch (e) {
      // Fail silently for view count
    }
  }

  // Filter news
  Future<List<NewsArticle>> filterNews({
    NewsCategory? category,
    String? searchQuery,
    bool? isFeatured,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      List<NewsArticle> articles;

      // Get base articles
      if (category != null) {
        articles = await getNewsByCategory(category);
      } else {
        articles = await getAllNews();
      }

      // Apply filters
      if (searchQuery != null && searchQuery.isNotEmpty) {
        articles = articles.where((article) {
          return article.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              article.content.toLowerCase().contains(searchQuery.toLowerCase()) ||
              article.excerpt.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      }

      if (isFeatured != null && isFeatured) {
        articles = articles.where((article) => article.isFeatured).toList();
      }

      if (dateFrom != null) {
        articles = articles.where((article) {
          final articleDate = article.publishedAt ?? article.createdAt;
          return articleDate.isAfter(dateFrom);
        }).toList();
      }

      if (dateTo != null) {
        articles = articles.where((article) {
          final articleDate = article.publishedAt ?? article.createdAt;
          return articleDate.isBefore(dateTo);
        }).toList();
      }

      return articles;
    } catch (e) {
      throw Exception('Failed to filter news: $e');
    }
  }

  // Get related news
  Future<List<NewsArticle>> getRelatedNews(
      NewsArticle article, {
        int limit = 5,
      }) async {
    try {
      final categoryNews = await getNewsByCategory(article.category);

      // Remove the current article and limit results
      return categoryNews
          .where((news) => news.id != article.id)
          .take(limit)
          .toList();
    } catch (e) {
      throw Exception('Failed to load related news: $e');
    }
  }
}