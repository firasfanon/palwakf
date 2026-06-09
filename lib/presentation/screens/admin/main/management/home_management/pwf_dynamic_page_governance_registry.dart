import 'package:flutter/material.dart';

import '../../../../../../app/routing/app_routes.dart';
import 'package:waqf/features/platform/home/presentation/specs/pwf_internal_public_page_specs.dart';

/// Governance registry for the dynamic public page.
///
/// This is the canonical operational reference used by Home Management to show
/// which components are:
/// - sovereign/central on the ministry platform level
/// - shared between ministry home and unit slugs
/// - central services injected into the dynamic page
/// - shell/layout elements whose shape is unified but data can be context-aware

enum PwfDynamicComponentScope { shell, sovereign, shared, injected }

extension PwfDynamicComponentScopeX on PwfDynamicComponentScope {
  String get labelAr {
    switch (this) {
      case PwfDynamicComponentScope.shell:
        return 'قالب / Shell';
      case PwfDynamicComponentScope.sovereign:
        return 'سيادي مركزي';
      case PwfDynamicComponentScope.shared:
        return 'مشترك مع الوحدات';
      case PwfDynamicComponentScope.injected:
        return 'خدمة مركزية محقونة';
    }
  }

  Color get color {
    switch (this) {
      case PwfDynamicComponentScope.shell:
        return const Color(0xFF546E7A);
      case PwfDynamicComponentScope.sovereign:
        return const Color(0xFF0B3A70);
      case PwfDynamicComponentScope.shared:
        return const Color(0xFF2E7D32);
      case PwfDynamicComponentScope.injected:
        return const Color(0xFF8E24AA);
    }
  }
}

class PwfDynamicPageComponentDef {
  final String key;
  final String titleAr;
  final String categoryAr;
  final PwfDynamicComponentScope scope;
  final bool appearsOnHome;
  final bool appearsOnUnitSlug;
  final bool isSectionCatalogItem;
  final String managedByAr;
  final String? adminRoute;
  final String notesAr;
  final IconData icon;
  final String? internalPageSpecKey;

  const PwfDynamicPageComponentDef({
    required this.key,
    required this.titleAr,
    required this.categoryAr,
    required this.scope,
    required this.appearsOnHome,
    required this.appearsOnUnitSlug,
    required this.isSectionCatalogItem,
    required this.managedByAr,
    required this.notesAr,
    required this.icon,
    this.adminRoute,
    this.internalPageSpecKey,
  });

  bool get usesInternalPublicContract =>
      (internalPageSpecKey ?? '').trim().isNotEmpty;
  String get internalContractLabelAr {
    final spec = (internalPageSpecKey == null)
        ? null
        : findPwfInternalPublicPageSpec(internalPageSpecKey!);
    return spec == null ? 'بدون عقد صفحة داخلية' : 'عقد صفحة: ${spec.titleAr}';
  }

  bool get hasAdminRoute => (adminRoute ?? '').trim().isNotEmpty;
}

const List<PwfDynamicPageComponentDef> kPwfDynamicPageComponents = [
  PwfDynamicPageComponentDef(
    key: 'pwf_top_bar',
    titleAr: 'الشريط العلوي',
    categoryAr: 'Shell / القالب العام',
    scope: PwfDynamicComponentScope.shell,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'المنصة مع بيانات قد تصبح سياقية لاحقًا',
    adminRoute: AppRoutes.adminHomeManagement,
    notesAr:
        'جزء ثابت من القالب العام، ويجب اعتباره ضمن طبقة الواجهة الموحدة لا كمحتوى مستقل.',
    icon: Icons.vertical_align_top_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_main_header',
    titleAr: 'الهيدر الرئيسي',
    categoryAr: 'Shell / القالب العام',
    scope: PwfDynamicComponentScope.shell,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: false,
    managedByAr: 'المنصة، مع حاجة لإغلاق السياق حسب slug',
    adminRoute: AppRoutes.adminHomeManagement,
    notesAr:
        'القالب ثابت حاليًا لكن النصوص وبعض الأزرار ما زالت أقرب إلى السياق الوزاري الثابت وتحتاج إغلاقًا حسب slug.',
    icon: Icons.web_asset_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_main_nav',
    titleAr: 'شريط التنقل الرئيسي',
    categoryAr: 'التنقل والربط',
    scope: PwfDynamicComponentScope.shared,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'المنصة + الوحدات عبر slug',
    adminRoute: AppRoutes.adminHomeManagement,
    notesAr:
        'الهيكل البصري ثابت، لكن الروابط والمداخل يجب أن تصبح مدارة فعليًا بحسب slug لا ثابتة فقط.',
    icon: Icons.route_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_footer',
    titleAr: 'الفوتر',
    categoryAr: 'التنقل والربط',
    scope: PwfDynamicComponentScope.shared,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'المنصة + الوحدات عبر slug',
    adminRoute: AppRoutes.adminHomeManagement,
    notesAr:
        'الفوتر مرتبط فعليًا بـ unitSlug ويجلب بيانات الاتصال والروابط والتواصل الاجتماعي بحسب السياق.',
    icon: Icons.view_agenda_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_hero_slider',
    titleAr: 'السلايدر الرئيسي / Hero',
    categoryAr: 'الهوية والسيادة المؤسسية',
    scope: PwfDynamicComponentScope.sovereign,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'PalWakf / الوزارة',
    adminRoute: AppRoutes.adminHeroSlider,
    notesAr:
        'مكوّن سيادي مركزي ضمن الصفحة الديناميكية، حتى عند عرضه تحت slug وحداتي يبقى إدارته من المستوى الوزاري.',
    icon: Icons.slideshow_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_minister_word',
    titleAr: 'كلمة الوزير',
    categoryAr: 'الهوية والسيادة المؤسسية',
    scope: PwfDynamicComponentScope.sovereign,
    appearsOnHome: true,
    appearsOnUnitSlug: false,
    isSectionCatalogItem: true,
    managedByAr: 'PalWakf / الوزارة',
    adminRoute: AppRoutes.adminHomeManagement,
    notesAr:
        'محتوى سيادي خاص بالوزارة ويجب أن يبقى مرتبطًا بسياق home لا سياق الوحدة.',
    icon: Icons.record_voice_over_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'vision_mission',
    titleAr: 'الرسالة والرؤيا',
    categoryAr: 'الهوية والسيادة المؤسسية',
    scope: PwfDynamicComponentScope.sovereign,
    appearsOnHome: true,
    appearsOnUnitSlug: false,
    isSectionCatalogItem: false,
    managedByAr: 'PalWakf / الوزارة',
    adminRoute: AppRoutes.adminHomeManagement,
    notesAr:
        'صفحات/محتوى سيادي مؤسسي، ليست section حالية في الكاتالوج لكنها جزء من الحوكمة المرجعية للواجهة.',
    icon: Icons.flag_circle_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_breaking_news_marquee',
    titleAr: 'الأخبار العاجلة',
    categoryAr: 'الهوية والسيادة المؤسسية',
    scope: PwfDynamicComponentScope.sovereign,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'PalWakf مع إمكانية التخصيص السياقي لاحقًا',
    adminRoute: AppRoutes.adminBreakingNews,
    notesAr:
        'بارز وعالي التأثير، وإدارته الحالية أقرب للمركزية حتى لو ظهر ضمن slug.',
    icon: Icons.campaign_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_news',
    internalPageSpecKey: 'news',
    titleAr: 'الأخبار',
    categoryAr: 'المحتوى المشترك',
    scope: PwfDynamicComponentScope.shared,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'الوزارة عند home والوحدات عند slug',
    adminRoute: AppRoutes.adminHomeManagement,
    notesAr:
        'نفس النوع من المحتوى، لكن النطاق يختلف: home للوزارة وslug للوحدة.',
    icon: Icons.newspaper_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_news_tabs',
    internalPageSpecKey: 'news',
    titleAr: 'تبويبات الأخبار',
    categoryAr: 'المحتوى المشترك',
    scope: PwfDynamicComponentScope.shared,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'المنصة، كعرض منظم لعائلة الأخبار',
    adminRoute: AppRoutes.adminHomeManagement,
    notesAr: 'يمثل طريقة عرض لعائلة الأخبار لا CRUD منفصل مستقل عن الأخبار.',
    icon: Icons.tab_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_announcements',
    internalPageSpecKey: 'announcements',
    titleAr: 'الإعلانات',
    categoryAr: 'المحتوى المشترك',
    scope: PwfDynamicComponentScope.shared,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'الوزارة عند home والوحدات عند slug',
    adminRoute: AppRoutes.adminHomeManagement,
    notesAr: 'محتوى تحريري/إعلاني مشترك يجب أن يُدار بنطاق home أو unit.',
    icon: Icons.campaign_outlined,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_activities',
    internalPageSpecKey: 'activities',
    titleAr: 'الأنشطة والفعاليات',
    categoryAr: 'المحتوى المشترك',
    scope: PwfDynamicComponentScope.shared,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'الوزارة عند home والوحدات عند slug',
    adminRoute: AppRoutes.adminActivitiesManagement,
    notesAr: 'تدار من نفس المنظومة لكن على نطاقين: وزاري ووحداتي.',
    icon: Icons.event_note_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'events',
    titleAr: 'الفعاليات',
    categoryAr: 'المحتوى المشترك',
    scope: PwfDynamicComponentScope.shared,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: false,
    managedByAr: 'الوزارة عند home والوحدات عند slug',
    adminRoute: AppRoutes.adminActivitiesManagement,
    notesAr:
        'لم تُفصل بعد كقسم مستقل في الكاتالوج، لكنها جزء وظيفي من المحتوى المشترك المطلوب تطويره.',
    icon: Icons.event_available_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_media_gallery',
    titleAr: 'المعرض الإعلامي',
    categoryAr: 'الوسائط المشتركة',
    scope: PwfDynamicComponentScope.shared,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'الوزارة عند home والوحدات عند slug',
    adminRoute: AppRoutes.adminHomeManagement,
    notesAr:
        'عائلة موحدة يجب إدارتها دون تكرار بين المعرض العام والصور والفيديوهات.',
    icon: Icons.perm_media_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_important_links',
    titleAr: 'الروابط المهمة',
    categoryAr: 'التنقل والربط',
    scope: PwfDynamicComponentScope.shared,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'الوزارة عند home والوحدات عند slug',
    adminRoute: AppRoutes.adminHomeManagement,
    notesAr:
        'مرشح حاليًا لإغلاق فجوة الربط بالسياق لأنه لا يُمرر له unitSlug فعليًا في renderer الحالي.',
    icon: Icons.link_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_quick_links_grid',
    titleAr: 'الروابط السريعة والخدمات السريعة',
    categoryAr: 'التنقل والربط',
    scope: PwfDynamicComponentScope.shared,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'الوزارة عند home والوحدات عند slug',
    adminRoute: AppRoutes.adminHomeManagement,
    notesAr: 'جزء من المداخل السياقية ويحتاج ربطًا أوضح بين home والوحدات.',
    icon: Icons.flash_on_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_stats_grid',
    titleAr: 'الإحصائيات',
    categoryAr: 'محتوى / ربط',
    scope: PwfDynamicComponentScope.shared,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'المنصة، مع قابلية التخصيص السياقي لاحقًا',
    adminRoute: AppRoutes.adminHomeManagement,
    notesAr:
        'تظهر في الصفحة الحالية ويجب حسم ما إذا كانت عامة دائمًا أو قابلة للتبدل حسب الوحدة.',
    icon: Icons.insert_chart_outlined_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_mini_map_teaser',
    titleAr: 'الخريطة المصغرة',
    categoryAr: 'محتوى / ربط',
    scope: PwfDynamicComponentScope.shared,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'المنصة مع ربط لاحق بالمستكشف',
    adminRoute: AppRoutes.adminHomeManagement,
    notesAr:
        'عنصر موجود في الكاتالوج ولم يُفعل بالكامل بعد، ويجب تطويره فوق الهيكل الحالي لا من الصفر.',
    icon: Icons.map_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_feature_highlights',
    titleAr: 'البطاقات المميزة',
    categoryAr: 'محتوى / ربط',
    scope: PwfDynamicComponentScope.shared,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'المنصة + الوحدات حسب الحاجة',
    adminRoute: AppRoutes.adminHomeManagement,
    notesAr: 'تحتاج قرار تفعيل وربط، لكنها جزء معتمد من الكاتالوج الحالي.',
    icon: Icons.featured_play_list_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'contact_social',
    titleAr: 'بيانات الاتصال ووسائل التواصل',
    categoryAr: 'التنقل والربط',
    scope: PwfDynamicComponentScope.shared,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: false,
    managedByAr: 'الوزارة عند home والوحدات عند slug',
    adminRoute: AppRoutes.adminHomeManagement,
    notesAr:
        'ليست Section مستقلة في الكاتالوج لكنها جزء حاكم من الفوتر والسياق الديناميكي.',
    icon: Icons.contact_phone_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_prayer_times',
    internalPageSpecKey: 'prayer_times',
    titleAr: 'مواقيت الصلاة',
    categoryAr: 'الخدمات المركزية المحقونة',
    scope: PwfDynamicComponentScope.injected,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'PalWakf / المنصة',
    adminRoute: AppRoutes.adminPrayerTimes,
    notesAr:
        'خدمة مركزية تُدار من المنصة وتُحقن داخل الصفحة الديناميكية بغض النظر عن slug.',
    icon: Icons.access_time_filled_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'pwf_friday_sermons',
    titleAr: 'خطب الجمعة',
    categoryAr: 'الخدمات المركزية المحقونة',
    scope: PwfDynamicComponentScope.injected,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: true,
    managedByAr: 'PalWakf / المنصة',
    adminRoute: AppRoutes.adminFridaySermons,
    notesAr:
        'خدمة/محتوى مركزي محقون في الصفحة الديناميكية ويُدار من المستوى الوزاري.',
    icon: Icons.mic_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'quran',
    titleAr: 'القرآن',
    categoryAr: 'الخدمات المركزية المحقونة',
    scope: PwfDynamicComponentScope.injected,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: false,
    managedByAr: 'PalWakf / المنصة',
    adminRoute: AppRoutes.adminQuran,
    notesAr:
        'خدمة مركزية مع شاشة إدارية مستقلة، وليست section حالية في كاتالوج الصفحة.',
    icon: Icons.menu_book_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'zakat',
    titleAr: 'الزكاة',
    categoryAr: 'الخدمات المركزية المحقونة',
    scope: PwfDynamicComponentScope.injected,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: false,
    managedByAr: 'PalWakf / المنصة',
    adminRoute: AppRoutes.adminZakat,
    notesAr:
        'خدمة مركزية مع شاشة إدارية مستقلة، ويمكن حقنها لاحقًا في الصفحة الديناميكية.',
    icon: Icons.volunteer_activism_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'complaints',
    titleAr: 'الشكاوى',
    categoryAr: 'الخدمات المركزية المحقونة',
    scope: PwfDynamicComponentScope.injected,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: false,
    managedByAr: 'PalWakf / الوزارة',
    adminRoute: AppRoutes.adminComplaints,
    notesAr:
        'خدمة سيادية/مركزية على مستوى المنصة، ولها الآن مسار إداري مركزي داخل لوحة التحكم.',
    icon: Icons.report_gmailerrorred_rounded,
  ),
  PwfDynamicPageComponentDef(
    key: 'emergency',
    titleAr: 'الطوارئ',
    categoryAr: 'الخدمات المركزية المحقونة',
    scope: PwfDynamicComponentScope.injected,
    appearsOnHome: true,
    appearsOnUnitSlug: true,
    isSectionCatalogItem: false,
    managedByAr: 'PalWakf / الوزارة مع بيانات قد تصبح سياقية',
    notesAr:
        'زر/خدمة حساسة في الهيدر الرئيسي، وتحتاج حوكمة واضحة بين المركزية والسياق المحلي.',
    icon: Icons.emergency_rounded,
  ),
];

List<PwfDynamicPageComponentDef> pwfDynamicComponentsByScope(
  PwfDynamicComponentScope scope,
) {
  return kPwfDynamicPageComponents.where((e) => e.scope == scope).toList();
}
