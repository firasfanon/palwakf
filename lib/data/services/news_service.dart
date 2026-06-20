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
  // sample/demo rows and public.* must never be substituted for real content.
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

  // Sample data for development/demo purposes
  List<NewsArticle> sampleNewsForDevelopmentOnly() {
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
