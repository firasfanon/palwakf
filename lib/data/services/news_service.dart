import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/news_article.dart';
import 'media_compat_mapper.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

class NewsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const bool _forceLegacyPublicMedia = bool.fromEnvironment(
    'PWF_FORCE_LEGACY_PUBLIC_MEDIA',
    defaultValue: false,
  );
  static const bool _mediaOwnerReadDefault = !_forceLegacyPublicMedia;
  static const bool _allowLegacyPublicBaseFallback = bool.fromEnvironment(
    'PWF_ALLOW_LEGACY_PUBLIC_MEDIA_BASE_FALLBACK',
    defaultValue: false,
  );
  static const Duration _mediaOwnerRuntimeTimeout = Duration(seconds: 8);

  Future<List<NewsArticle>> _getCompatNews({
    int? limit,
    int? offset,
    String? unitSlug,
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
      final response = await _supabase
          .from(PwfDatabaseOwnerSurfaces.vMediaNewsCompatV1)
          .select('*')
          .timeout(_mediaOwnerRuntimeTimeout);

      var items = (response as List<dynamic>)
          .map(
            (json) => MediaCompatMapper.newsFromCompatRow(
              json as Map<String, dynamic>,
            ),
          )
          .where((article) => article.status == PublishStatus.published)
          .toList();

      final normalizedUnitSlug = unitSlug?.trim().toLowerCase();
      if (normalizedUnitSlug != null &&
          normalizedUnitSlug.isNotEmpty &&
          normalizedUnitSlug != 'home') {
        items = items
            .where(
              (article) =>
                  (article.unitId ?? '').trim().toLowerCase() ==
                  normalizedUnitSlug,
            )
            .toList();
      }

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
        surface: PwfDatabaseOwnerSurfaces.vMediaNewsCompatV1,
        rows: windowed.length,
      );
      return windowed;
    } on TimeoutException {
      _logMediaRuntimeFallback(family: 'news', reason: 'owner-timeout');
      return const <NewsArticle>[];
    } catch (e, stackTrace) {
      dev.log(
        'Media Center owner-read news runtime failed; legacy fallback may run.',
        name: 'NewsService',
        error: e,
        stackTrace: stackTrace,
      );
      _logMediaRuntimeFallback(family: 'news', reason: 'owner-failure');
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
      'owner_read=true '
      'api_edge=public.$surface '
      'owner_schema=media_center projection=* '
      'filtering=client-side '
      'ordering=client-side '
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
      'legacy_public_fallback=true '
      'reason=$reason '
      'decision=media-center-legacy-public-fallback-only',
    );
  }

  Future<NewsArticle?> _getCompatNewsById(int id, {String? unitSlug}) async {
    if (!_mediaOwnerReadDefault) return null;
    try {
      final items = await _getCompatNews(limit: 500, unitSlug: unitSlug);
      for (final item in items) {
        if (item.id == id) return item;
      }
      return null;
    } catch (_) {
      return null;
    }
  }


  bool _canUseLegacyPublicBaseFallback(String operation) {
    if (_allowLegacyPublicBaseFallback) return true;
    _logMediaRuntimeFallback(
      family: 'news',
      reason: 'legacy-public-base-fallback-disabled:$operation',
    );
    return false;
  }

  // news_service.dart - Clean version
  Future<List<NewsArticle>> getAllNews({int? limit, int? offset}) async {
    final compat = await _getCompatNews(limit: limit, offset: offset);
    if (compat.isNotEmpty) return compat;
    if (!_canUseLegacyPublicBaseFallback('getAllNews')) return _getSampleNews();

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
    final compat = await _getCompatNews(limit: limit);
    if (compat.isNotEmpty) return compat.take(limit).toList();
    if (!_canUseLegacyPublicBaseFallback('getFeaturedNews')) {
      return _getSampleNews().where((article) => article.isFeatured).take(limit).toList();
    }

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
    final compat = await _getCompatNews(limit: limit);
    if (compat.isNotEmpty) return compat;
    if (!_canUseLegacyPublicBaseFallback('getLatestNews')) {
      return _getSampleNews().take(limit).toList();
    }

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
    final compat = await _getCompatNews(category: category);
    if (compat.isNotEmpty) return compat;
    if (!_canUseLegacyPublicBaseFallback('getNewsByCategory')) {
      return _getSampleNews()
          .where((article) => article.category == category)
          .toList();
    }

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
    final compat = await _getCompatNewsById(id);
    if (compat != null) return compat;
    if (!_canUseLegacyPublicBaseFallback('getNewsById')) {
      return _getSampleNews().firstWhere((article) => article.id == id);
    }

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
    final compat = await _getCompatNews(searchQuery: query);
    if (compat.isNotEmpty) return compat;
    if (!_canUseLegacyPublicBaseFallback('searchNews')) {
      return _getSampleNews()
          .where(
            (article) =>
                article.title.toLowerCase().contains(query.toLowerCase()) ||
                article.content.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }

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
    final compat = await _getCompatNews(limit: 1000);
    if (compat.isNotEmpty) {
      return {
        'total_news': compat.length,
        'featured_news': compat.where((a) => a.isFeatured).length,
        'categories': NewsCategory.values.length,
        'runtime_source': 'public.v_media_news_compat_v1',
        'runtime_decision': 'media-center-owner-read-default-root-cutover',
      };
    }

    if (!_canUseLegacyPublicBaseFallback('getNewsStatistics')) {
      final sampleNews = _getSampleNews();
      return {
        'total_news': sampleNews.length,
        'featured_news': sampleNews.where((a) => a.isFeatured).length,
        'categories': NewsCategory.values.length,
        'runtime_source': 'sample-news',
        'runtime_decision': 'legacy-public-base-disabled',
      };
    }

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

  // Sample data for development/demo purposes
  List<NewsArticle> _getSampleNews() {
    return [
      NewsArticle(
        id: 1,
        title: 'افتتاح مسجد جديد في مدينة رام الله',
        excerpt:
            'تم افتتاح مسجد جديد في حي الطيرة برام الله بحضور معالي الوزير وجمع من المواطنين',
        content: '''
تم بحمد الله افتتاح مسجد جديد في حي الطيرة بمدينة رام الله، وذلك بحضور معالي وزير الأوقاف والشؤون الدينية د. محمود الهباش، وعدد من المسؤولين في الوزارة، وجمع غفير من أهالي الحي والمصلين.

وأكد معالي الوزير في كلمة له خلال حفل الافتتاح على أهمية دور المساجد في حياة المجتمع الفلسطيني، وضرورة الحفاظ على هذه الصروح الدينية التي تعتبر منارات للهداية والإرشاد.

من جانبه، شكر إمام المسجد الجديد الشيخ أحمد محمد معالي الوزير على دعمه المتواصل للمساجد في فلسطين، مؤكداً على أن هذا المسجد سيكون منبراً للعلم والمعرفة وخدمة أهالي الحي.

يذكر أن المسجد الجديد يتسع لحوالي 500 مصل، ويضم قاعة للنساء وقاعة متعددة الأغراض للأنشطة المجتمعية.
        ''',
        imageUrl: 'https://example.com/mosque1.jpg',
        author: 'أحمد محمد',
        category: NewsCategory.mosques,
        status: PublishStatus.published,
        viewCount: 150,
        isFeatured: true,
        tags: ['مساجد', 'رام الله', 'افتتاح'],
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NewsArticle(
        id: 2,
        title: 'ندوة حول الوسطية في الإسلام',
        excerpt:
            'تنظم الوزارة ندوة علمية حول موضوع الوسطية في الإسلام بمشاركة علماء من مختلف البلدان العربية',
        content: '''
تنظم وزارة الأوقاف والشؤون الدينية الفلسطينية ندوة علمية مهمة حول موضوع "الوسطية في الإسلام" وذلك يوم الخميس القادم في قاعة المؤتمرات بالوزارة.

وتهدف الندوة إلى تسليط الضوء على مفهوم الوسطية في الإسلام وأهميتها في بناء مجتمع متوازن ومعتدل، خاصة في ظل التحديات التي تواجه الأمة الإسلامية في العصر الحديث.

سيشارك في الندوة نخبة من العلماء والمفكرين من مختلف البلدان العربية والإسلامية، حيث سيتم تناول محاور مختلفة تشمل:
- مفهوم الوسطية في القرآن والسنة
- دور الوسطية في تعزيز التعايش المجتمعي
- الوسطية والحوار بين الأديان
- تطبيقات الوسطية في الحياة العملية

ودعت الوزارة جميع المهتمين والطلبة والباحثين للمشاركة في هذه الندوة المهمة.
        ''',
        imageUrl: 'https://example.com/seminar1.jpg',
        author: 'فاطمة أحمد',
        category: NewsCategory.religious,
        status: PublishStatus.published,
        viewCount: 89,
        isFeatured: false,
        tags: ['ندوة', 'وسطية', 'إسلام'],
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      NewsArticle(
        id: 3,
        title: 'دورة تدريبية لأئمة المساجد حول الخطابة',
        excerpt:
            'تنطلق غداً دورة تدريبية متخصصة لأئمة المساجد حول فن الخطابة والإلقاء',
        content: '''
تنطلق غداً الأحد دورة تدريبية متخصصة لأئمة المساجد في محافظات الضفة الغربية حول "فن الخطابة والإلقاء" وذلك في مقر الوزارة برام الله.

وتأتي هذه الدورة ضمن البرنامج التدريبي السنوي الذي تنفذه الوزارة لتطوير قدرات أئمة المساجد وتعزيز مهاراتهم في مختلف المجالات الدينية والتربوية.

وستتناول الدورة التي تستمر لمدة ثلاثة أيام عدة محاور مهمة منها:
- أصول الخطابة في الإسلام
- تقنيات الإلقاء الفعال
- كيفية إعداد خطبة الجمعة
- التفاعل مع الجمهور
- استخدام الوسائل التعليمية الحديثة

وسيقوم بتدريب المشاركين نخبة من الخبراء والمختصين في مجال الخطابة والإعلام الديني.

يذكر أن عدد المشاركين في هذه الدورة يبلغ 40 إماماً من مختلف محافظات الوطن.
        ''',
        imageUrl: 'https://example.com/training1.jpg',
        author: 'محمد خالد',
        category: NewsCategory.education,
        status: PublishStatus.published,
        viewCount: 67,
        isFeatured: true,
        tags: ['تدريب', 'أئمة', 'خطابة'],
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      NewsArticle(
        id: 4,
        title: 'حملة لترميم المساجد التاريخية في القدس',
        excerpt:
            'تطلق الوزارة حملة واسعة لترميم وصيانة المساجد التاريخية في مدينة القدس المحتلة',
        content: '''
أطلقت وزارة الأوقاف والشؤون الدينية الفلسطينية حملة واسعة لترميم وصيانة المساجد التاريخية في مدينة القدس المحتلة، وذلك في إطار الجهود المبذولة للحفاظ على التراث الإسلامي في المدينة المقدسة.

وتشمل الحملة ترميم عدد من المساجد التاريخية المهمة في البلدة القديمة والأحياء المقدسية، حيث سيتم التركيز على الأعمال الضرورية للحفاظ على البنية التحتية لهذه المساجد.

وأكد معالي وزير الأوقاف أن هذه الحملة تأتي ضمن الالتزام الفلسطيني بحماية المقدسات الإسلامية في القدس، رغم كل التحديات والصعوبات التي تفرضها سلطات الاحتلال.

وتتضمن أعمال الترميم:
- إصلاح الأسقف والجدران
- تجديد أنظمة الإضاءة والتهوية
- ترميم المحاريب والمنابر
- تنظيف وصيانة الفسيفساء والزخارف الإسلامية

من المتوقع أن تستمر أعمال الترميم لمدة ستة أشهر بتمويل من عدة جهات محلية وإقليمية.
        ''',
        imageUrl: 'https://example.com/jerusalem1.jpg',
        author: 'سارة محمود',
        category: NewsCategory.general,
        status: PublishStatus.published,
        viewCount: 245,
        isFeatured: true,
        tags: ['القدس', 'ترميم', 'مساجد تاريخية'],
        publishedAt: DateTime.now().subtract(const Duration(days: 4)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      NewsArticle(
        id: 5,
        title: 'مسابقة حفظ القرآن الكريم للشباب',
        excerpt:
            'تعلن الوزارة عن إطلاق مسابقة حفظ القرآن الكريم للشباب على مستوى فلسطين',
        content: '''
أعلنت وزارة الأوقاف والشؤون الدينية الفلسطينية عن إطلاق مسابقة حفظ القرآن الكريم للشباب والفتيات في الفئة العمرية من 15 إلى 25 سنة، وذلك على مستوى جميع محافظات فلسطين.

وتهدف المسابقة إلى تشجيع الشباب الفلسطيني على حفظ كتاب الله الكريم وفهم معانيه، وتعزيز الهوية الإسلامية لدى الجيل الناشئ.

وتتضمن المسابقة عدة مستويات:
- المستوى الأول: حفظ 5 أجزاء من القرآن الكريم
- المستوى الثاني: حفظ 10 أجزاء من القرآن الكريم
- المستوى الثالث: حفظ 20 جزءاً من القرآن الكريم
- المستوى الرابع: حفظ القرآن الكريم كاملاً

وستقام التصفيات الأولية على مستوى المحافظات، ثم التصفيات النهائية على المستوى الوطني في رام الله.

الجوائز المالية تتراوح بين 500 إلى 5000 دولار للفائزين في المراكز الأولى، بالإضافة إلى شهادات تقدير ودروع تذكارية.

آخر موعد للتسجيل هو نهاية الشهر الجاري، ويمكن التسجيل من خلال موقع الوزارة الإلكتروني أو مراجعة مديريات الأوقاف في المحافظات.
        ''',
        imageUrl: 'https://example.com/quran1.jpg',
        author: 'يوسف إبراهيم',
        category: NewsCategory.education,
        status: PublishStatus.published,
        viewCount: 156,
        isFeatured: false,
        tags: ['مسابقة', 'قرآن', 'شباب'],
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  // ============================
  // Unit-scoped methods (Institutional routing)
  // ============================

  Future<List<NewsArticle>> getAllNewsForUnit(
    String unitId, {
    int? limit,
    int? offset,
  }) async {
    final compat = await _getCompatNews(limit: limit, offset: offset);
    if (compat.isNotEmpty) return compat;

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
    final compat = await _getCompatNews(limit: limit);
    if (compat.isNotEmpty) return compat;

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
    final compat = await _getCompatNews(limit: limit);
    if (compat.isNotEmpty) return compat.take(limit).toList();

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
    final compat = await _getCompatNews(category: category);
    if (compat.isNotEmpty) return compat;

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
    final compat = await _getCompatNewsById(id);
    if (compat != null) return compat;

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
    final compat = await _getCompatNews(searchQuery: query);
    if (compat.isNotEmpty) return compat;

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
