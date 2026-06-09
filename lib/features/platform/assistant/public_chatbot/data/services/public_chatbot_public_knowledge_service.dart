import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waqf/app/routing/unit_routes.dart';
import 'package:waqf/data/models/activity.dart';
import 'package:waqf/data/models/announcement.dart';
import 'package:waqf/data/models/friday_sermon.dart';
import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/data/models/media_gallery_item.dart';
import 'package:waqf/data/models/news_article.dart';
import 'package:waqf/data/repositories/activity_repository.dart';
import 'package:waqf/data/repositories/announcement_repository.dart';
import 'package:waqf/data/repositories/footer_repository.dart';
import 'package:waqf/data/repositories/friday_sermons_repository.dart';
import 'package:waqf/data/repositories/homepage_repository.dart';
import 'package:waqf/data/repositories/media_gallery_repository.dart';
import 'package:waqf/data/repositories/org_units_repository.dart';
import 'package:waqf/data/services/news_service.dart';
import 'package:waqf/data/services/supabase_service.dart';
import 'package:waqf/features/platform/assistant/assistant_core/data/services/chat_route_context_service.dart';
import 'package:waqf/features/platform/home/data/repositories/pwf_site_pages_repository.dart';

import '../models/public_chatbot_knowledge_answer.dart';

class PublicChatbotPublicKnowledgeService {
  const PublicChatbotPublicKnowledgeService({
    PwfSitePagesRepository sitePagesRepository = const PwfSitePagesRepository(),
  }) : _sitePagesRepository = sitePagesRepository;

  final PwfSitePagesRepository _sitePagesRepository;

  Future<PublicChatbotKnowledgeAnswer?> tryResolve({
    required String userMessage,
    required String unitSlug,
    required bool isArabic,
    String? currentRoute,
  }) async {
    final normalized = userMessage.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    final routeContext = ChatRouteContextService.resolve(
      currentRoute,
      fallbackUnitSlug: unitSlug,
    );
    final effectiveUnitSlug = routeContext.unitSlug.trim().isEmpty
        ? unitSlug
        : routeContext.unitSlug;

    final structuredIntent = await _tryStructuredPublicIntentAnswer(
      normalized: normalized,
      unitSlug: effectiveUnitSlug,
      isArabic: isArabic,
    );
    if (structuredIntent != null) return structuredIntent;

    final pageAnswer = await _tryPageAnswer(
      normalized: normalized,
      unitSlug: effectiveUnitSlug,
      isArabic: isArabic,
    );
    if (pageAnswer != null) return pageAnswer;

    final homepageSectionsAnswer = await _tryHomepageSectionsAnswer(
      normalized: normalized,
      unitSlug: effectiveUnitSlug,
      isArabic: isArabic,
    );
    if (homepageSectionsAnswer != null) return homepageSectionsAnswer;

    final newsAnswer = await _tryNewsAnswer(
      normalized: normalized,
      unitSlug: effectiveUnitSlug,
      isArabic: isArabic,
    );
    if (newsAnswer != null) return newsAnswer;

    final announcementsAnswer = await _tryAnnouncementsAnswer(
      normalized: normalized,
      unitSlug: effectiveUnitSlug,
      isArabic: isArabic,
    );
    if (announcementsAnswer != null) return announcementsAnswer;

    final activitiesAnswer = await _tryActivitiesAnswer(
      normalized: normalized,
      unitSlug: effectiveUnitSlug,
      isArabic: isArabic,
    );
    if (activitiesAnswer != null) return activitiesAnswer;

    final sermonsAnswer = await _tryFridaySermonsAnswer(
      normalized: normalized,
      unitSlug: effectiveUnitSlug,
      isArabic: isArabic,
    );
    if (sermonsAnswer != null) return sermonsAnswer;

    final mediaAnswer = await _tryMediaAnswer(
      normalized: normalized,
      unitSlug: effectiveUnitSlug,
      isArabic: isArabic,
    );
    if (mediaAnswer != null) return mediaAnswer;

    final linksAnswer = await _tryFooterLinksAnswer(
      normalized: normalized,
      isArabic: isArabic,
    );
    if (linksAnswer != null) return linksAnswer;

    final unitAnswer = await _tryUnitInfoAnswer(
      normalized: normalized,
      unitSlug: effectiveUnitSlug,
      isArabic: isArabic,
    );
    if (unitAnswer != null) return unitAnswer;

    final faqAnswer = _tryFaqAnswer(
      normalized: normalized,
      unitSlug: effectiveUnitSlug,
      isArabic: isArabic,
    );
    if (faqAnswer != null) return faqAnswer;

    return null;
  }

  Future<PublicChatbotKnowledgeAnswer?> _tryStructuredPublicIntentAnswer({
    required String normalized,
    required String unitSlug,
    required bool isArabic,
  }) async {
    if (_matchesAboutIntent(normalized)) {
      return _resolveAboutAnswer(unitSlug: unitSlug, isArabic: isArabic);
    }
    if (_matchesContactIntent(normalized)) {
      return _resolveContactAnswer(isArabic: isArabic);
    }
    if (_matchesServicesIntent(normalized)) {
      return _resolveServicesAnswer(unitSlug: unitSlug, isArabic: isArabic);
    }
    return null;
  }

  Future<PublicChatbotKnowledgeAnswer?> _resolveAboutAnswer({
    required String unitSlug,
    required bool isArabic,
  }) async {
    final pageAnswer = await _resolvePageAnswerBySlug(
      slug: 'about',
      route: '/about',
      sourceLabelAr: 'صفحة عن الوزارة',
      sourceLabelEn: 'About page',
      unitSlug: unitSlug,
      isArabic: isArabic,
    );
    if (pageAnswer != null) return pageAnswer;

    return PublicChatbotKnowledgeAnswer(
      text: _joinLines([
        isArabic
            ? 'بحسب المحتوى العام المعتمد: وزارة الأوقاف والشؤون الدينية تُعنى بإدارة الأوقاف وخدمة المساجد وتنظيم الزكاة والصدقات والإرشاد والتعليم الشرعي، مع تطوير الخدمات الدينية والتحول الرقمي.'
            : 'According to the approved public content, the Ministry of Awqaf and Religious Affairs manages awqaf, serves mosques, organizes zakat and charity work, and develops religious and digital public services.',
        isArabic
            ? 'يمكنك فتح صفحة عن الوزارة للحصول على نبذة تفصيلية ورسالة الوزارة وأهدافها.'
            : 'You can open the About page for a fuller overview, mission, and objectives.',
        isArabic ? 'الانتقال المباشر: /about' : 'Open: /about',
      ]),
      sourceLabelAr: 'صفحة عن الوزارة',
      sourceLabelEn: 'About page',
      route: '/about',
    );
  }

  Future<PublicChatbotKnowledgeAnswer?> _resolveContactAnswer({
    required bool isArabic,
  }) async {
    try {
      final footer = await FooterRepository(
        Supabase.instance.client,
      ).fetchFooterSettings();
      return PublicChatbotKnowledgeAnswer(
        text: _joinLines([
          isArabic
              ? 'بحسب بيانات الاتصال العامة المعتمدة:'
              : 'According to the approved public contact details:',
          if ((footer.contactPhone ?? '').trim().isNotEmpty)
            isArabic
                ? 'الهاتف: ${footer.contactPhone}'
                : 'Phone: ${footer.contactPhone}',
          if ((footer.contactEmail ?? '').trim().isNotEmpty)
            isArabic
                ? 'البريد الإلكتروني: ${footer.contactEmail}'
                : 'Email: ${footer.contactEmail}',
          if ((footer.contactAddress ?? '').trim().isNotEmpty)
            isArabic
                ? 'العنوان: ${footer.contactAddress}'
                : 'Address: ${footer.contactAddress}',
          if (footer.showWorkingHours)
            isArabic
                ? 'أوقات الدوام: ${footer.workingDays} | ${footer.workingHours}'
                : 'Working hours: ${footer.workingDays} | ${footer.workingHours}',
          isArabic
              ? 'أفضل مسار للمتابعة أو تعبئة نموذج التواصل هو صفحة اتصل بنا.'
              : 'The best route for follow-up or filling the contact form is the Contact page.',
          isArabic ? 'الانتقال المباشر: /contact' : 'Open: /contact',
        ]),
        sourceLabelAr: 'بيانات الاتصال العامة',
        sourceLabelEn: 'Public contact details',
        route: '/contact',
      );
    } catch (_) {
      return _fallbackPageAnswer(
        item: const _PageIntent(
          slug: 'contact',
          route: '/contact',
          sourceLabelAr: 'صفحة اتصل بنا',
          sourceLabelEn: 'Contact page',
          keywordsAr: <String>[],
          keywordsEn: <String>[],
        ),
        isArabic: isArabic,
      );
    }
  }

  Future<PublicChatbotKnowledgeAnswer?> _resolveServicesAnswer({
    required String unitSlug,
    required bool isArabic,
  }) async {
    try {
      final footer = await FooterRepository(
        Supabase.instance.client,
      ).fetchFooterSettings();
      final enabledQuick = footer.quickLinks
          .where((e) => e.enabled)
          .take(3)
          .toList(growable: false);
      final enabledServices = footer.servicesLinks
          .where((e) => e.enabled)
          .take(4)
          .toList(growable: false);
      final route = unitSlug.trim().isEmpty || unitSlug == 'home'
          ? '/services'
          : '/$unitSlug';
      return PublicChatbotKnowledgeAnswer(
        text: _joinLines([
          isArabic
              ? 'بحسب الروابط والخدمات العامة المعتمدة، هذه أفضل نقاط البداية المتاحة حاليًا:'
              : 'According to the approved public links and services, these are the best starting points available now:',
          ...enabledServices.map(
            (e) => isArabic
                ? '• ${e.label}: ${e.route}'
                : '• ${e.label}: ${e.route}',
          ),
          ...enabledQuick.map(
            (e) => isArabic
                ? '• ${e.label}: ${e.route}'
                : '• ${e.label}: ${e.route}',
          ),
          if (unitSlug != 'home')
            isArabic
                ? 'وللوصول إلى الأخبار والأنشطة والخدمات الخاصة بالوحدة الحالية ابدأ من: $route'
                : 'For news, activities, and services of the current unit, start from: $route',
          isArabic
              ? 'الانتقال المباشر: /services أو /eservices'
              : 'Open: /services or /eservices',
        ]),
        sourceLabelAr: 'الخدمات والروابط العامة',
        sourceLabelEn: 'Public services and links',
        route: '/services',
      );
    } catch (_) {
      final pageAnswer = await _resolvePageAnswerBySlug(
        slug: 'services',
        route: '/services',
        sourceLabelAr: 'صفحة الخدمات',
        sourceLabelEn: 'Services page',
        unitSlug: unitSlug,
        isArabic: isArabic,
      );
      return pageAnswer ??
          _fallbackPageAnswer(
            item: const _PageIntent(
              slug: 'services',
              route: '/services',
              sourceLabelAr: 'صفحة الخدمات',
              sourceLabelEn: 'Services page',
              keywordsAr: <String>[],
              keywordsEn: <String>[],
            ),
            isArabic: isArabic,
          );
    }
  }

  Future<PublicChatbotKnowledgeAnswer?> _tryPageAnswer({
    required String normalized,
    required String unitSlug,
    required bool isArabic,
  }) async {
    final catalog = <_PageIntent>[
      _PageIntent(
        slug: 'about',
        route: '/about',
        sourceLabelAr: 'صفحة عن الوزارة',
        sourceLabelEn: 'About page',
        keywordsAr: const [
          'عن الوزارة',
          'عن الأوقاف',
          'من أنتم',
          'الوزارة',
          'المؤسسة',
        ],
        keywordsEn: const ['about', 'ministry', 'institution'],
      ),
      _PageIntent(
        slug: 'services',
        route: '/services',
        sourceLabelAr: 'صفحة الخدمات',
        sourceLabelEn: 'Services page',
        keywordsAr: const ['الخدمات', 'الخدمة', 'ماذا تقدمون'],
        keywordsEn: const ['services', 'service'],
      ),
      _PageIntent(
        slug: 'contact',
        route: '/contact',
        sourceLabelAr: 'صفحة اتصل بنا',
        sourceLabelEn: 'Contact page',
        keywordsAr: const ['اتصل', 'تواصل', 'هاتف', 'بريد', 'عنوان'],
        keywordsEn: const ['contact', 'phone', 'email', 'address'],
      ),
      _PageIntent(
        slug: 'structure',
        route: '/structure',
        sourceLabelAr: 'صفحة الهيكل التنظيمي',
        sourceLabelEn: 'Structure page',
        keywordsAr: const ['الهيكل', 'الهيكل التنظيمي', 'الإدارات'],
        keywordsEn: const ['structure', 'organizational'],
      ),
      _PageIntent(
        slug: 'minister',
        route: '/minister',
        sourceLabelAr: 'صفحة كلمة الوزير',
        sourceLabelEn: 'Minister message page',
        keywordsAr: const ['الوزير', 'كلمة الوزير'],
        keywordsEn: const ['minister'],
      ),
      _PageIntent(
        slug: 'vision-mission',
        route: '/vision-mission',
        sourceLabelAr: 'صفحة الرؤية والرسالة',
        sourceLabelEn: 'Vision & mission page',
        keywordsAr: const ['الرؤية', 'الرسالة', 'الاهداف', 'الأهداف'],
        keywordsEn: const ['vision', 'mission'],
      ),
      _PageIntent(
        slug: 'eservices',
        route: '/eservices',
        sourceLabelAr: 'صفحة الخدمات الإلكترونية',
        sourceLabelEn: 'E-services page',
        keywordsAr: const [
          'الخدمات الإلكترونية',
          'الكترونية',
          'إلكترونية',
          'النماذج',
        ],
        keywordsEn: const ['e-services', 'forms', 'downloads'],
      ),
    ];

    for (final item in catalog) {
      if (!item.matches(normalized, isArabic: isArabic)) continue;
      final answer = await _resolvePageAnswerBySlug(
        slug: item.slug,
        route: item.route,
        sourceLabelAr: item.sourceLabelAr,
        sourceLabelEn: item.sourceLabelEn,
        unitSlug: unitSlug,
        isArabic: isArabic,
      );
      return answer ?? _fallbackPageAnswer(item: item, isArabic: isArabic);
    }
    return null;
  }

  Future<PublicChatbotKnowledgeAnswer?> _tryHomepageSectionsAnswer({
    required String normalized,
    required String unitSlug,
    required bool isArabic,
  }) async {
    if (!_containsAny(normalized, const [
      'الصفحة الرئيسية',
      'الرئيسية',
      'الأقسام',
      'اقسام',
      'ماذا يظهر',
      'ماذا يوجد',
      'الروابط السريعة',
      'الخدمات السريعة',
      'الإحصائيات',
      'الخريطة',
      'الابرازات',
      'الإبرازات',
      'homepage',
      'home page',
      'sections',
      'statistics',
      'quick links',
      'quick services',
      'feature highlights',
      'map',
    ])) {
      return null;
    }

    final unitId = await _resolveUnitId(unitSlug);
    if (unitId == null) return null;

    try {
      final sections = await HomepageRepository(
        Supabase.instance.client,
      ).fetchAllSectionsForUnit(unitId: unitId);
      if (sections.isEmpty) return null;
      final activeSections = sections
          .where((section) => section.isActive)
          .toList(growable: false);
      final sectionLabels = activeSections
          .take(6)
          .map((section) => _sectionLabel(section, isArabic: isArabic))
          .where((label) => label.trim().isNotEmpty)
          .toList(growable: false);
      final route = UnitRoutes.home(unitSlug);
      return PublicChatbotKnowledgeAnswer(
        text: _joinLines([
          isArabic
              ? 'بحسب أقسام الصفحة الحالية، هناك ${activeSections.length} أقسام مفعلة ضمن هذا النطاق.'
              : 'According to the current homepage sections, there are ${activeSections.length} active sections in this scope.',
          if (sectionLabels.isNotEmpty)
            isArabic
                ? 'أبرز الأقسام الحالية: ${sectionLabels.join('، ')}.'
                : 'Main active sections: ${sectionLabels.join(', ')}.',
          isArabic
              ? 'إذا أردت يمكنني إرشادك إلى الأخبار أو الإعلانات أو الأنشطة أو الخدمات الخاصة بهذه الصفحة.'
              : 'I can also guide you to news, announcements, activities, or services for this page.',
          isArabic ? 'الانتقال المباشر: $route' : 'Open: $route',
        ]),
        sourceLabelAr: 'أقسام الصفحة الرئيسية',
        sourceLabelEn: 'Homepage sections',
        route: route,
      );
    } catch (_) {
      return null;
    }
  }

  Future<PublicChatbotKnowledgeAnswer?> _tryNewsAnswer({
    required String normalized,
    required String unitSlug,
    required bool isArabic,
  }) async {
    if (!_containsAny(normalized, const [
      'خبر',
      'أخبار',
      'اخر الأخبار',
      'آخر الأخبار',
      'news',
      'latest news',
    ])) {
      return null;
    }
    final unitId = await _resolveUnitId(unitSlug);
    if (unitId == null) return null;
    final route = UnitRoutes.news(unitSlug);
    try {
      final items = await NewsService().getLatestNewsForUnit(unitId, limit: 3);
      if (items.isEmpty) return null;
      return PublicChatbotKnowledgeAnswer(
        text: _joinLines([
          isArabic
              ? 'بحسب الأخبار المنشورة في هذا النطاق، هذه أحدث العناصر المتاحة الآن:'
              : 'According to the published news in this scope, these are the latest available items:',
          ...items.map((item) => _newsBullet(item, isArabic: isArabic)),
          isArabic ? 'لمشاهدة جميع الأخبار: $route' : 'View all news: $route',
        ]),
        sourceLabelAr: 'الأخبار العامة',
        sourceLabelEn: 'Public news',
        route: route,
      );
    } catch (_) {
      return null;
    }
  }

  Future<PublicChatbotKnowledgeAnswer?> _tryAnnouncementsAnswer({
    required String normalized,
    required String unitSlug,
    required bool isArabic,
  }) async {
    if (!_containsAny(normalized, const [
      'إعلان',
      'إعلانات',
      'تنويه',
      'التعميم',
      'announcement',
      'announcements',
    ])) {
      return null;
    }
    final unitId = await _resolveUnitId(unitSlug);
    if (unitId == null) return null;
    final route = UnitRoutes.announcements(unitSlug);
    try {
      final items = await AnnouncementRepository(
        SupabaseService(),
      ).getActiveAnnouncementsForUnit(unitId, limit: 3);
      if (items.isEmpty) return null;
      return PublicChatbotKnowledgeAnswer(
        text: _joinLines([
          isArabic
              ? 'بحسب الإعلانات النشطة في هذا النطاق، هذه أقرب العناصر المتاحة حاليًا:'
              : 'According to the active announcements in this scope, these are the closest available items right now:',
          ...items.map((item) => _announcementBullet(item, isArabic: isArabic)),
          isArabic
              ? 'لمشاهدة جميع الإعلانات: $route'
              : 'View all announcements: $route',
        ]),
        sourceLabelAr: 'الإعلانات العامة',
        sourceLabelEn: 'Public announcements',
        route: route,
      );
    } catch (_) {
      return null;
    }
  }

  Future<PublicChatbotKnowledgeAnswer?> _tryActivitiesAnswer({
    required String normalized,
    required String unitSlug,
    required bool isArabic,
  }) async {
    if (!_containsAny(normalized, const [
      'نشاط',
      'أنشطة',
      'فعالية',
      'فعاليات',
      'activity',
      'activities',
      'event',
      'events',
    ])) {
      return null;
    }
    final unitId = await _resolveUnitId(unitSlug);
    if (unitId == null) return null;
    final route = UnitRoutes.activities(unitSlug);
    try {
      final repo = ActivityRepository(SupabaseService());
      var items = await repo.getUpcomingActivitiesForUnit(unitId, limit: 3);
      if (items.isEmpty) {
        items = await repo.getAllActivitiesForUnit(unitId, limit: 3);
      }
      if (items.isEmpty) return null;
      return PublicChatbotKnowledgeAnswer(
        text: _joinLines([
          isArabic
              ? 'بحسب الأنشطة في هذا النطاق، هذه أقرب البرامج أو الفعاليات المتاحة:'
              : 'According to the activities in this scope, these are the closest available programs or events:',
          ...items.map((item) => _activityBullet(item, isArabic: isArabic)),
          isArabic
              ? 'لمشاهدة جميع الأنشطة: $route'
              : 'View all activities: $route',
        ]),
        sourceLabelAr: 'الأنشطة العامة',
        sourceLabelEn: 'Public activities',
        route: route,
      );
    } catch (_) {
      return null;
    }
  }

  Future<PublicChatbotKnowledgeAnswer?> _tryFridaySermonsAnswer({
    required String normalized,
    required String unitSlug,
    required bool isArabic,
  }) async {
    if (!_containsAny(normalized, const [
      'خطبة',
      'خطب',
      'الجمعة',
      'sermon',
      'sermons',
      'friday',
    ])) {
      return null;
    }
    final route = UnitRoutes.fridaySermons(unitSlug);
    try {
      final items = await FridaySermonsRepository(
        Supabase.instance.client,
      ).listPublic(limit: 3);
      if (items.isEmpty) return null;
      return PublicChatbotKnowledgeAnswer(
        text: _joinLines([
          isArabic
              ? 'بحسب الخطب المنشورة حاليًا، هذه أحدث الخطب أو أقربها:'
              : 'According to the currently published sermons, these are the latest or closest items:',
          ...items.map((item) => _sermonBullet(item, isArabic: isArabic)),
          isArabic
              ? 'لمشاهدة أرشيف الخطب: $route'
              : 'View the sermons archive: $route',
        ]),
        sourceLabelAr: 'خطب الجمعة',
        sourceLabelEn: 'Friday sermons',
        route: route,
      );
    } catch (_) {
      return null;
    }
  }

  Future<PublicChatbotKnowledgeAnswer?> _tryMediaAnswer({
    required String normalized,
    required String unitSlug,
    required bool isArabic,
  }) async {
    if (!_containsAny(normalized, const [
      'معرض',
      'الصور',
      'فيديو',
      'فيديوهات',
      'وسائط',
      'media',
      'gallery',
      'photos',
      'videos',
    ])) {
      return null;
    }
    final unitId = await _resolveUnitId(unitSlug);
    if (unitId == null) return null;
    final route = UnitRoutes.media(unitSlug);
    try {
      final repo = MediaGalleryRepository(SupabaseService());
      final photos = await repo.fetchPublicForUnit(
        unitId,
        mediaType: MediaType.photo,
        limit: 2,
      );
      final videos = await repo.fetchPublicForUnit(
        unitId,
        mediaType: MediaType.video,
        limit: 2,
      );
      if (photos.isEmpty && videos.isEmpty) return null;
      final lines = <String>[
        isArabic
            ? 'بحسب المعرض الإعلامي في هذا النطاق، هذه أقرب المواد المتاحة:'
            : 'According to the media gallery in this scope, these are the closest available items:',
      ];
      if (photos.isNotEmpty) {
        lines.add(
          isArabic
              ? 'صور: ${photos.map((e) => e.title).join('، ')}'
              : 'Photos: ${photos.map((e) => e.title).join(', ')}',
        );
      }
      if (videos.isNotEmpty) {
        lines.add(
          isArabic
              ? 'فيديو: ${videos.map((e) => e.title).join('، ')}'
              : 'Videos: ${videos.map((e) => e.title).join(', ')}',
        );
      }
      lines.add(isArabic ? 'فتح المعرض: $route' : 'Open gallery: $route');
      return PublicChatbotKnowledgeAnswer(
        text: _joinLines(lines),
        sourceLabelAr: 'المعرض الإعلامي',
        sourceLabelEn: 'Media gallery',
        route: route,
      );
    } catch (_) {
      return null;
    }
  }

  Future<PublicChatbotKnowledgeAnswer?> _resolvePageAnswerBySlug({
    required String slug,
    required String route,
    required String sourceLabelAr,
    required String sourceLabelEn,
    required String unitSlug,
    required bool isArabic,
  }) async {
    final unitId = await _resolveUnitId(unitSlug);
    if (unitId == null) return null;
    try {
      final page = await _sitePagesRepository.getPageBySlugForUnit(
        slug: slug,
        unitId: unitId,
      );
      if (page == null) return null;
      final title = isArabic ? page.titleAr : page.titleEn;
      final body = isArabic ? page.bodyAr : page.bodyEn;
      final subtitle = isArabic ? page.subtitleAr : page.subtitleEn;
      final excerpt = _buildExcerpt([body, subtitle, title]);
      return PublicChatbotKnowledgeAnswer(
        text: _joinLines([
          isArabic
              ? 'بحسب $sourceLabelAr${title.trim().isEmpty ? '' : ' ($title)'}:'
              : 'According to the $sourceLabelEn${title.trim().isEmpty ? '' : ' ($title)'}:',
          if (excerpt.isNotEmpty) excerpt,
          isArabic
              ? 'يمكنك فتح الصفحة مباشرة: $route'
              : 'You can open the page directly: $route',
        ]),
        sourceLabelAr: sourceLabelAr,
        sourceLabelEn: sourceLabelEn,
        route: route,
      );
    } catch (_) {
      return null;
    }
  }

  Future<PublicChatbotKnowledgeAnswer?> _tryFooterLinksAnswer({
    required String normalized,
    required bool isArabic,
  }) async {
    final shouldCheckLinks = _containsAny(normalized, const [
      'رابط',
      'روابط',
      'النماذج',
      'نموذج',
      'تحميل',
      'خدمة',
      'الخدمات',
      'link',
      'links',
      'forms',
      'downloads',
    ]);
    final shouldCheckContact = _containsAny(normalized, const [
      'اتصل',
      'تواصل',
      'هاتف',
      'بريد',
      'عنوان',
      'دوام',
      'phone',
      'email',
      'address',
      'working hours',
    ]);
    if (!shouldCheckLinks && !shouldCheckContact) return null;

    try {
      final footer = await FooterRepository(
        Supabase.instance.client,
      ).fetchFooterSettings();
      if (shouldCheckContact) {
        final text = _joinLines([
          isArabic
              ? 'بحسب بيانات الاتصال العامة المعتمدة:'
              : 'According to the approved public contact details:',
          if ((footer.contactPhone ?? '').trim().isNotEmpty)
            isArabic
                ? 'الهاتف: ${footer.contactPhone}'
                : 'Phone: ${footer.contactPhone}',
          if ((footer.contactEmail ?? '').trim().isNotEmpty)
            isArabic
                ? 'البريد الإلكتروني: ${footer.contactEmail}'
                : 'Email: ${footer.contactEmail}',
          if ((footer.contactAddress ?? '').trim().isNotEmpty)
            isArabic
                ? 'العنوان: ${footer.contactAddress}'
                : 'Address: ${footer.contactAddress}',
          if (footer.showWorkingHours)
            isArabic
                ? 'أوقات الدوام: ${footer.workingDays} | ${footer.workingHours}'
                : 'Working hours: ${footer.workingDays} | ${footer.workingHours}',
          isArabic ? 'الانتقال المباشر: /contact' : 'Open: /contact',
        ]);
        return PublicChatbotKnowledgeAnswer(
          text: text,
          sourceLabelAr: 'بيانات الاتصال العامة',
          sourceLabelEn: 'Public contact details',
          route: '/contact',
        );
      }

      final enabledQuick = footer.quickLinks
          .where((e) => e.enabled)
          .take(3)
          .toList(growable: false);
      final enabledServices = footer.servicesLinks
          .where((e) => e.enabled)
          .take(3)
          .toList(growable: false);
      final text = _joinLines([
        isArabic
            ? 'بحسب الروابط العامة المعتمدة، هذه أقرب نقاط البدء المتاحة حاليًا:'
            : 'According to the approved public links, these are the best starting points available now:',
        ...enabledQuick.map(
          (e) => isArabic
              ? '• ${e.label}: ${e.route}'
              : '• ${e.label}: ${e.route}',
        ),
        ...enabledServices.map(
          (e) => isArabic
              ? '• ${e.label}: ${e.route}'
              : '• ${e.label}: ${e.route}',
        ),
        isArabic ? 'الانتقال المباشر: /eservices' : 'Open: /eservices',
      ]);
      return PublicChatbotKnowledgeAnswer(
        text: text,
        sourceLabelAr: 'الروابط والخدمات العامة',
        sourceLabelEn: 'Public links and services',
        route: '/eservices',
      );
    } catch (_) {
      return null;
    }
  }

  Future<PublicChatbotKnowledgeAnswer?> _tryUnitInfoAnswer({
    required String normalized,
    required String unitSlug,
    required bool isArabic,
  }) async {
    final isUnitQuestion = _containsAny(normalized, const [
      'وحدة',
      'وحدات',
      'مديرية',
      'مديريات',
      'كلية',
      'دار',
      'فرع',
      'قسم',
      'branch',
      'unit',
      'directorate',
    ]);
    if (!isUnitQuestion) return null;

    try {
      final unit = await OrgUnitsRepository(
        Supabase.instance.client,
      ).fetchUnitBySlug(unitSlug);
      if (unit == null) return null;

      final nameAr = (unit['name_ar'] ?? '').toString().trim();
      final nameEn = (unit['name_en'] ?? '').toString().trim();
      final code = (unit['code'] ?? '').toString().trim();
      final type = (unit['unit_type'] ?? '').toString().trim();
      final route = unitSlug == 'home' ? '/home' : '/$unitSlug';
      final displayName = isArabic
          ? (nameAr.isEmpty ? unitSlug : nameAr)
          : (nameEn.isEmpty ? unitSlug : nameEn);
      final typeLabel = isArabic
          ? _unitTypeLabelAr(type)
          : _unitTypeLabelEn(type);

      final text = _joinLines([
        isArabic
            ? 'بحسب بيانات الوحدات العامة، أنت الآن ضمن: $displayName.'
            : 'According to the public units data, you are currently within: $displayName.',
        if (typeLabel.isNotEmpty)
          isArabic ? 'نوع الوحدة: $typeLabel' : 'Unit type: $typeLabel',
        if (code.isNotEmpty) isArabic ? 'الرمز: $code' : 'Code: $code',
        isArabic
            ? 'يمكنك متابعة الأخبار والأنشطة والخدمات من الصفحة العامة للوحدة.'
            : 'You can continue to the unit public page for its news, activities, and services.',
        isArabic ? 'الانتقال المباشر: $route' : 'Open: $route',
      ]);

      return PublicChatbotKnowledgeAnswer(
        text: text,
        sourceLabelAr: 'صفحات الوحدات العامة',
        sourceLabelEn: 'Public unit pages',
        route: route,
      );
    } catch (_) {
      return null;
    }
  }

  PublicChatbotKnowledgeAnswer? _tryFaqAnswer({
    required String normalized,
    required String unitSlug,
    required bool isArabic,
  }) {
    final unitPath = unitSlug.trim().isEmpty || unitSlug == 'home'
        ? '/home'
        : '/$unitSlug';

    if (_containsAny(normalized, const [
      'مواقيت',
      'الصلاة',
      'اذان',
      'أذان',
      'الفجر',
      'المغرب',
      'العشاء',
      'prayer',
      'adhan',
    ])) {
      return PublicChatbotKnowledgeAnswer(
        text: _joinLines([
          isArabic
              ? 'مصدر الإجابة: خدمة مواقيت الصلاة العامة. يمكنك متابعة المواقيت اليومية ووقت الأذان من صفحة مواقيت الصلاة الرسمية.'
              : 'Source: the public prayer-times service. You can check daily timings and adhan times from the official prayer-times page.',
          isArabic ? 'الانتقال المباشر: /prayer-times' : 'Open: /prayer-times',
        ]),
        sourceLabelAr: 'خدمة مواقيت الصلاة',
        sourceLabelEn: 'Prayer times service',
        route: '/prayer-times',
      );
    }

    if (_containsAny(normalized, const [
      'زكاة',
      'الزكاة',
      'احسب الزكاة',
      'حساب الزكاة',
      'zakat',
    ])) {
      return PublicChatbotKnowledgeAnswer(
        text: _joinLines([
          isArabic
              ? 'مصدر الإجابة: خدمة الزكاة العامة. يمكنك استخدام حاسبة الزكاة للوصول إلى تقدير أولي ثم متابعة صفحة الزكاة أو التبرعات.'
              : 'Source: the public zakat service. You can use the zakat calculator for an initial estimate and then continue to the zakat page.',
          isArabic ? 'الانتقال المباشر: /home/zakat' : 'Open: /home/zakat',
        ]),
        sourceLabelAr: 'خدمة الزكاة',
        sourceLabelEn: 'Zakat service',
        route: '/home/zakat',
      );
    }

    if (_containsAny(normalized, const [
      'مسجد',
      'أقرب مسجد',
      'اقرب مسجد',
      'mosque',
      'nearest mosque',
    ])) {
      return PublicChatbotKnowledgeAnswer(
        text: _joinLines([
          isArabic
              ? 'مصدر الإجابة: صفحة المساجد العامة. يمكنك فتح صفحة المساجد للوصول إلى المعلومات العامة حول المساجد والخدمات المرتبطة بها. وإذا كنت تبحث ضمن وحدة محددة فابدأ من صفحتها العامة: $unitPath'
              : 'Source: the public mosques page. Open the mosques page for public information related to mosques and related services. If you are looking within a specific unit, start from its public page: $unitPath',
          isArabic ? 'الانتقال المباشر: /mosques' : 'Open: /mosques',
        ]),
        sourceLabelAr: 'صفحة المساجد',
        sourceLabelEn: 'Mosques page',
        route: '/mosques',
      );
    }

    if (_containsAny(normalized, const [
      'شكوى',
      'شكاوى',
      'مقترح',
      'complaint',
      'suggestion',
    ])) {
      return PublicChatbotKnowledgeAnswer(
        text: _joinLines([
          isArabic
              ? 'مصدر الإجابة: الأسئلة الشائعة للشكاوى والمقترحات. عادة يتم الرد خلال 3–5 أيام عمل، ويمكن التقديم مجهولًا مع تفضيل إدخال وسيلة تواصل لتسهيل المتابعة.'
              : 'Source: the complaints and suggestions FAQ. Responses usually arrive within 3–5 business days, and anonymous submission is allowed, though contact details help with follow-up.',
          isArabic ? 'الانتقال المباشر: /complaints' : 'Open: /complaints',
        ]),
        sourceLabelAr: 'الأسئلة الشائعة للشكاوى',
        sourceLabelEn: 'Complaints FAQ',
        route: '/complaints',
      );
    }

    if (_containsAny(normalized, const [
      'نموذج',
      'نماذج',
      'روابط',
      'رابط',
      'استمارة',
      'تحميل',
      'form',
      'download',
      'link',
    ])) {
      return PublicChatbotKnowledgeAnswer(
        text: _joinLines([
          isArabic
              ? 'مصدر الإجابة: صفحة الخدمات الإلكترونية والروابط العامة. أفضل نقطة بداية للوصول إلى النماذج والتنزيلات هي صفحة الخدمات الإلكترونية.'
              : 'Source: the e-services and public links pages. The best starting point for forms and downloads is the e-services page.',
          isArabic ? 'الانتقال المباشر: /eservices' : 'Open: /eservices',
        ]),
        sourceLabelAr: 'الخدمات الإلكترونية والروابط العامة',
        sourceLabelEn: 'E-services and public links',
        route: '/eservices',
      );
    }

    if (_containsAny(normalized, const [
      'وحدة',
      'وحدات',
      'مديرية',
      'المديريات',
      'فرع',
      'branch',
      'unit',
      'directorate',
    ])) {
      return PublicChatbotKnowledgeAnswer(
        text: isArabic
            ? 'مصدر الإجابة: صفحات الوحدات العامة. يمكنك فتح الصفحة العامة للوحدة المطلوبة أو البدء من الصفحة الحالية: $unitPath. ومن هناك تصل إلى الأخبار والأنشطة والخدمات الخاصة بها.'
            : 'Source: the public unit pages. You can open the public page of the required unit, or start from the current unit page: $unitPath. From there you can reach its news, activities, and services.',
        sourceLabelAr: 'صفحات الوحدات العامة',
        sourceLabelEn: 'Public unit pages',
        route: unitPath,
      );
    }

    return null;
  }

  Future<String?> _resolveUnitId(String unitSlug) async {
    try {
      final repo = OrgUnitsRepository(Supabase.instance.client);
      final normalized = unitSlug.trim().isEmpty
          ? 'home'
          : unitSlug.trim().toLowerCase();
      return await repo.fetchUnitIdBySlug(normalized);
    } catch (_) {
      return null;
    }
  }

  String _sectionLabel(HomepageSection section, {required bool isArabic}) {
    final normalized = section.sectionName.trim().toLowerCase();
    switch (normalized) {
      case 'pwf_news':
      case 'news':
        return isArabic ? 'الأخبار' : 'News';
      case 'pwf_announcements':
      case 'announcements':
        return isArabic ? 'الإعلانات' : 'Announcements';
      case 'pwf_activities':
      case 'activities':
        return isArabic ? 'الأنشطة' : 'Activities';
      case 'pwf_friday_sermons':
      case 'friday_sermons':
        return isArabic ? 'خطب الجمعة' : 'Friday sermons';
      case 'pwf_media_gallery':
      case 'media_gallery':
        return isArabic ? 'المعرض الإعلامي' : 'Media gallery';
      case 'pwf_important_links':
        return isArabic ? 'الروابط السريعة' : 'Quick links';
      case 'pwf_eservices_portal':
        return isArabic ? 'بوابة الخدمات الإلكترونية' : 'E-services portal';
      case 'pwf_feature_highlights':
        return isArabic ? 'الإبرازات' : 'Feature highlights';
      case 'pwf_stats_grid':
      case 'statistics':
        return isArabic ? 'الإحصائيات' : 'Statistics';
      case 'pwf_mini_map_teaser':
        return isArabic ? 'الخريطة التمهيدية' : 'Mini map teaser';
      default:
        return normalized;
    }
  }

  String _newsBullet(NewsArticle item, {required bool isArabic}) {
    final dateLabel = item.publishedAt == null
        ? ''
        : (isArabic
              ? _formatDateAr(item.publishedAt!)
              : _formatDateEn(item.publishedAt!));
    final excerpt = _buildExcerpt([item.excerpt, item.title]);
    return isArabic
        ? '• ${item.title}${dateLabel.isEmpty ? '' : ' — $dateLabel'}${excerpt.isEmpty ? '' : '\n  $excerpt'}'
        : '• ${item.title}${dateLabel.isEmpty ? '' : ' — $dateLabel'}${excerpt.isEmpty ? '' : '\n  $excerpt'}';
  }

  String _announcementBullet(Announcement item, {required bool isArabic}) {
    final priority = isArabic
        ? _priorityLabelAr(item.priority)
        : _priorityLabelEn(item.priority);
    final validity = item.validUntil == null
        ? (isArabic ? 'مفتوح حاليًا' : 'Open now')
        : (isArabic
              ? 'حتى ${_formatDateAr(item.validUntil!)}'
              : 'Until ${_formatDateEn(item.validUntil!)}');
    return isArabic
        ? '• ${item.title} — $priority${validity.isEmpty ? '' : ' | $validity'}'
        : '• ${item.title} — $priority${validity.isEmpty ? '' : ' | $validity'}';
  }

  String _activityBullet(Activity item, {required bool isArabic}) {
    final dateLabel = isArabic
        ? _formatDateAr(item.startDate)
        : _formatDateEn(item.startDate);
    return isArabic
        ? '• ${item.title} — $dateLabel${item.location.trim().isEmpty ? '' : ' | ${item.location.trim()}'}'
        : '• ${item.title} — $dateLabel${item.location.trim().isEmpty ? '' : ' | ${item.location.trim()}'}';
  }

  String _sermonBullet(FridaySermon item, {required bool isArabic}) {
    final title = isArabic
        ? item.titleAr
        : (item.titleEn?.trim().isNotEmpty == true
              ? item.titleEn!
              : item.titleAr);
    final meta = <String>[
      isArabic
          ? _formatDateAr(item.sermonDate)
          : _formatDateEn(item.sermonDate),
      if ((item.speakerName ?? '').trim().isNotEmpty) item.speakerName!.trim(),
      if ((item.mosqueName ?? '').trim().isNotEmpty) item.mosqueName!.trim(),
    ].join(isArabic ? ' | ' : ' | ');
    return '• $title${meta.isEmpty ? '' : ' — $meta'}';
  }

  String _priorityLabelAr(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'منخفض';
      case Priority.normal:
        return 'عادي';
      case Priority.medium:
        return 'متوسط';
      case Priority.high:
        return 'مرتفع';
      case Priority.urgent:
        return 'عاجل';
      case Priority.critical:
        return 'حرج';
    }
  }

  String _priorityLabelEn(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.normal:
        return 'Normal';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.urgent:
        return 'Urgent';
      case Priority.critical:
        return 'Critical';
    }
  }

  String _formatDateAr(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateEn(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  PublicChatbotKnowledgeAnswer _fallbackPageAnswer({
    required _PageIntent item,
    required bool isArabic,
  }) {
    final text = isArabic
        ? 'المصدر المقصود هنا هو ${item.sourceLabelAr}. الصفحة موجودة ضمن الموقع العام ويمكن فتحها مباشرة من الرابط: ${item.route}'
        : 'The intended source here is the ${item.sourceLabelEn}. You can open it directly from: ${item.route}';
    return PublicChatbotKnowledgeAnswer(
      text: text,
      sourceLabelAr: item.sourceLabelAr,
      sourceLabelEn: item.sourceLabelEn,
      route: item.route,
    );
  }

  bool _matchesAboutIntent(String normalized) {
    return _containsAny(normalized, const [
      'عن الوزارة',
      'عن الأوقاف',
      'عن الوقف',
      'من أنتم',
      'نبذة',
      'رسالتكم',
      'رؤيتكم',
      'about the ministry',
      'about you',
      'who are you',
      'overview',
      'mission',
      'vision',
    ]);
  }

  bool _matchesContactIntent(String normalized) {
    return _containsAny(normalized, const [
      'اتصل',
      'تواصل',
      'هاتف',
      'بريد',
      'عنوان',
      'دوام',
      'شكوى تواصل',
      'contact',
      'phone',
      'email',
      'address',
      'working hours',
    ]);
  }

  bool _matchesServicesIntent(String normalized) {
    return _containsAny(normalized, const [
      'الخدمات',
      'خدماتكم',
      'ما الخدمات',
      'ماذا تقدمون',
      'النماذج',
      'الروابط',
      'الخدمات الإلكترونية',
      'services',
      'service',
      'forms',
      'downloads',
      'e-services',
    ]);
  }

  bool _containsAny(String normalized, List<String> values) {
    return values.any((value) => normalized.contains(value.toLowerCase()));
  }

  String _buildExcerpt(List<String> candidates) {
    for (final value in candidates) {
      final cleaned = _clean(value);
      if (cleaned.isNotEmpty) {
        if (cleaned.length <= 320) return cleaned;
        return '${cleaned.substring(0, 317)}...';
      }
    }
    return '';
  }

  String _clean(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _joinLines(List<String> lines) {
    return lines.where((line) => line.trim().isNotEmpty).join('\n\n');
  }

  String _unitTypeLabelAr(String type) {
    switch (type) {
      case 'directorate':
        return 'مديرية';
      case 'general_directorate':
        return 'إدارة عامة';
      case 'school':
        return 'كلية أو مدرسة';
      case 'system':
        return 'نظام';
      case 'womens_work':
        return 'عمل نسائي';
      case 'orphanage':
        return 'دار أيتام';
      case 'college':
        return 'كلية';
      case 'ministry':
        return 'الوزارة';
      default:
        return type;
    }
  }

  String _unitTypeLabelEn(String type) {
    switch (type) {
      case 'directorate':
        return 'Directorate';
      case 'general_directorate':
        return 'General directorate';
      case 'school':
        return 'School';
      case 'system':
        return 'System';
      case 'womens_work':
        return "Women's work";
      case 'orphanage':
        return 'Orphanage';
      case 'college':
        return 'College';
      case 'ministry':
        return 'Ministry';
      default:
        return type;
    }
  }
}

class _PageIntent {
  const _PageIntent({
    required this.slug,
    required this.route,
    required this.sourceLabelAr,
    required this.sourceLabelEn,
    required this.keywordsAr,
    required this.keywordsEn,
  });

  final String slug;
  final String route;
  final String sourceLabelAr;
  final String sourceLabelEn;
  final List<String> keywordsAr;
  final List<String> keywordsEn;

  bool matches(String normalized, {required bool isArabic}) {
    final values = isArabic ? keywordsAr : keywordsEn;
    return values.any((value) => normalized.contains(value.toLowerCase()));
  }
}
