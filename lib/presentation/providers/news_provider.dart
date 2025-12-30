import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/news_article.dart';
import '../../data/services/news_service.dart';

// News service provider
final newsServiceProvider = Provider<NewsService>((ref) {
  return NewsService();
});

// All news provider
final newsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final newsService = ref.read(newsServiceProvider);
  return await newsService.getAllNews();
});

// Latest news provider
final latestNewsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final newsService = ref.read(newsServiceProvider);
  return await newsService.getLatestNews(limit: 10);
});

// Featured news provider
final featuredNewsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final newsService = ref.read(newsServiceProvider);
  return await newsService.getFeaturedNews();
});

// News by category provider
final newsByCategoryProvider = FutureProvider.family<List<NewsArticle>, NewsCategory>(
      (ref, category) async {
    final newsService = ref.read(newsServiceProvider);
    return await newsService.getNewsByCategory(category);
  },
);

// Single news article provider
final newsArticleProvider = FutureProvider.family<NewsArticle?, int>(
      (ref, id) async {
    final newsService = ref.read(newsServiceProvider);
    return await newsService.getNewsById(id);
  },
);

// Search news provider
final searchNewsProvider = FutureProvider.family<List<NewsArticle>, String>(
      (ref, query) async {
    if (query.isEmpty) return [];
    final newsService = ref.read(newsServiceProvider);
    return await newsService.searchNews(query);
  },
);

// News statistics provider
final newsStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final newsService = ref.read(newsServiceProvider);
  return await newsService.getNewsStatistics();
});

// News filter state provider
final newsFilterProvider = StateNotifierProvider<NewsFilterNotifier, NewsFilter>(
      (ref) => NewsFilterNotifier(),
);

class NewsFilter {
  final NewsCategory? category;
  final String searchQuery;
  final bool showFeaturedOnly;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const NewsFilter({
    this.category,
    this.searchQuery = '',
    this.showFeaturedOnly = false,
    this.dateFrom,
    this.dateTo,
  });

  NewsFilter copyWith({
    NewsCategory? category,
    String? searchQuery,
    bool? showFeaturedOnly,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return NewsFilter(
      category: category,
      searchQuery: searchQuery ?? this.searchQuery,
      showFeaturedOnly: showFeaturedOnly ?? this.showFeaturedOnly,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  bool get hasActiveFilters {
    return category != null ||
        searchQuery.isNotEmpty ||
        showFeaturedOnly ||
        dateFrom != null ||
        dateTo != null;
  }
}

class NewsFilterNotifier extends StateNotifier<NewsFilter> {
  NewsFilterNotifier() : super(const NewsFilter());

  void setCategory(NewsCategory? category) {
    state = state.copyWith(category: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setShowFeaturedOnly(bool showFeatured) {
    state = state.copyWith(showFeaturedOnly: showFeatured);
  }

  void setDateRange(DateTime? from, DateTime? to) {
    state = state.copyWith(dateFrom: from, dateTo: to);
  }

  void clearFilters() {
    state = const NewsFilter();
  }

  void clearCategory() {
    state = state.copyWith(category: null);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }
}

// Filtered news provider that combines filters
final filteredNewsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final newsService = ref.read(newsServiceProvider);
  final filter = ref.watch(newsFilterProvider);

  List<NewsArticle> articles;

  // Get articles based on category filter
  if (filter.category != null) {
    articles = await newsService.getNewsByCategory(filter.category!);
  } else {
    articles = await newsService.getAllNews();
  }

  // Apply search filter
  if (filter.searchQuery.isNotEmpty) {
    articles = articles.where((article) {
      return article.title.toLowerCase().contains(filter.searchQuery.toLowerCase()) ||
          article.content.toLowerCase().contains(filter.searchQuery.toLowerCase()) ||
          article.excerpt.toLowerCase().contains(filter.searchQuery.toLowerCase());
    }).toList();
  }

  // Apply featured filter
  if (filter.showFeaturedOnly) {
    articles = articles.where((article) => article.isFeatured).toList();
  }

  // Apply date range filter
  if (filter.dateFrom != null || filter.dateTo != null) {
    articles = articles.where((article) {
      final articleDate = article.publishedAt ?? article.createdAt;

      if (filter.dateFrom != null && articleDate.isBefore(filter.dateFrom!)) {
        return false;
      }

      if (filter.dateTo != null && articleDate.isAfter(filter.dateTo!)) {
        return false;
      }

      return true;
    }).toList();
  }

  return articles;
});

// Paginated news provider
final paginatedNewsProvider = StateNotifierProvider<PaginatedNewsNotifier, PaginatedNewsState>(
      (ref) => PaginatedNewsNotifier(ref.read(newsServiceProvider)),
);

class PaginatedNewsState {
  final List<NewsArticle> articles;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int currentPage;

  const PaginatedNewsState({
    this.articles = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 0,
  });

  PaginatedNewsState copyWith({
    List<NewsArticle>? articles,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? currentPage,
  }) {
    return PaginatedNewsState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class PaginatedNewsNotifier extends StateNotifier<PaginatedNewsState> {
  final NewsService _newsService;
  static const int _pageSize = 20;

  PaginatedNewsNotifier(this._newsService) : super(const PaginatedNewsState());

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final articles = await _newsService.getAllNews(
        limit: _pageSize,
        offset: 0,
      );

      state = state.copyWith(
        articles: articles,
        isLoading: false,
        hasMore: articles.length == _pageSize,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final newArticles = await _newsService.getAllNews(
        limit: _pageSize,
        offset: state.currentPage * _pageSize,
      );

      state = state.copyWith(
        articles: [...state.articles, ...newArticles],
        isLoading: false,
        hasMore: newArticles.length == _pageSize,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = const PaginatedNewsState();
    await loadInitial();
  }
}

// News categories provider
final newsCategoriesProvider = Provider<List<NewsCategory>>((ref) {
  return NewsCategory.values;
});

// News view count incrementer
final incrementViewCountProvider = FutureProvider.family<void, int>(
      (ref, articleId) async {
    final newsService = ref.read(newsServiceProvider);
    await newsService.incrementViewCount(articleId);
  },
);

// Recently viewed news provider
final recentlyViewedNewsProvider = StateNotifierProvider<RecentlyViewedNotifier, List<NewsArticle>>(
      (ref) => RecentlyViewedNotifier(),
);

class RecentlyViewedNotifier extends StateNotifier<List<NewsArticle>> {
  RecentlyViewedNotifier() : super([]);

  void addArticle(NewsArticle article) {
    // Remove if already exists
    final currentList = state.where((a) => a.id != article.id).toList();

    // Add to beginning
    currentList.insert(0, article);

    // Keep only last 10 articles
    if (currentList.length > 10) {
      currentList.removeRange(10, currentList.length);
    }

    state = currentList;
  }

  void clearHistory() {
    state = [];
  }
}

// News bookmarks provider
final newsBookmarksProvider = StateNotifierProvider<NewsBookmarksNotifier, List<NewsArticle>>(
      (ref) => NewsBookmarksNotifier(),
);

class NewsBookmarksNotifier extends StateNotifier<List<NewsArticle>> {
  NewsBookmarksNotifier() : super([]);

  void toggleBookmark(NewsArticle article) {
    final isBookmarked = state.any((a) => a.id == article.id);

    if (isBookmarked) {
      state = state.where((a) => a.id != article.id).toList();
    } else {
      state = [...state, article];
    }
  }

  bool isBookmarked(int articleId) {
    return state.any((a) => a.id == articleId);
  }

  void removeBookmark(int articleId) {
    state = state.where((a) => a.id != articleId).toList();
  }

  void clearBookmarks() {
    state = [];
  }
}