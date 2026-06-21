import 'package:flutter/material.dart';

import '../../../app/routing/app_routes.dart';
import '../../../core/enums/system_key.dart';

class AdminPanelTabItem {
  const AdminPanelTabItem({
    required this.key,
    required this.label,
    required this.icon,
  });

  final String key;
  final String label;
  final IconData icon;
}

class AdminPanelGroup {
  const AdminPanelGroup({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<AdminPanelEntry> items;
}

class AdminPanelEntry {
  const AdminPanelEntry({
    required this.label,
    required this.description,
    required this.route,
    required this.icon,
    this.badge,
  });

  final String label;
  final String description;
  final String route;
  final IconData icon;
  final int? badge;
}

class AdminPanelEntrySection {
  const AdminPanelEntrySection({
    required this.title,
    required this.icon,
    required this.routes,
  });

  final String title;
  final IconData icon;
  final List<String> routes;
}

enum AdminGovernanceTier { administrativeCore, connectedSystem }

extension AdminGovernanceTierX on AdminGovernanceTier {
  String get labelAr {
    switch (this) {
      case AdminGovernanceTier.administrativeCore:
        return 'العقل الإداري / النظام المرجعي';
      case AdminGovernanceTier.connectedSystem:
        return 'نظام شبه مستقل مرتبط بالمنصة';
    }
  }
}

class AdminGovernedSystem {
  const AdminGovernedSystem({
    required this.systemKey,
    required this.label,
    required this.description,
    required this.icon,
    required this.tier,
    required this.familyAr,
    required this.notesAr,
    this.adminRoute,
    this.visibleInAdminSystemsTab = false,
  });

  final SystemKey systemKey;
  final String label;
  final String description;
  final IconData icon;
  final AdminGovernanceTier tier;
  final String familyAr;
  final String notesAr;
  final String? adminRoute;
  final bool visibleInAdminSystemsTab;
}

class AdminPanelRegistry {
  const AdminPanelRegistry._();

  static const tabs = <AdminPanelTabItem>[
    AdminPanelTabItem(
      key: 'main',
      label: 'الرئيسية',
      icon: Icons.dashboard_outlined,
    ),
    AdminPanelTabItem(
      key: 'public',
      label: 'الواجهة العامة',
      icon: Icons.web_outlined,
    ),
    AdminPanelTabItem(
      key: 'surfaces_services',
      label: 'خدمات الجمهور',
      icon: Icons.apps_rounded,
    ),
    AdminPanelTabItem(
      key: 'media',
      label: 'الإعلام والنشر',
      icon: Icons.perm_media_outlined,
    ),
    AdminPanelTabItem(
      key: 'systems',
      label: 'الأنظمة التشغيلية',
      icon: Icons.widgets_outlined,
    ),
    AdminPanelTabItem(
      key: 'platform',
      label: 'إدارة المنصة',
      icon: Icons.settings_outlined,
    ),
    AdminPanelTabItem(
      key: 'governance',
      label: 'الرقابة والجودة',
      icon: Icons.verified_user_outlined,
    ),
    AdminPanelTabItem(
      key: 'developer',
      label: 'المطور',
      icon: Icons.developer_mode_outlined,
    ),
  ];

  static const mainGroup = AdminPanelGroup(
    id: 'main',
    title: 'الرئيسية',
    subtitle:
        'مداخل سريعة إلى اللوحة والمساعد ومعاينة الشات العام وبوابة إدارة المنصة.',
    items: [
      AdminPanelEntry(
        label: 'لوحة التحكم',
        description: 'المدخل الرئيسي إلى المؤشرات والوصول السريع.',
        route: AppRoutes.adminDashboard,
        icon: Icons.dashboard_rounded,
      ),
      AdminPanelEntry(
        label: 'المساعد الداخلي',
        description: 'الوصول إلى المساعد الإداري الخاص بالموظفين.',
        route: AppRoutes.adminAssistant,
        icon: Icons.assistant_rounded,
      ),
      AdminPanelEntry(
        label: 'معاينة شات الجمهور',
        description: 'اختبار تجربة الشات العام كما تظهر للزوار.',
        route: AppRoutes.adminChatbot,
        icon: Icons.smart_toy_rounded,
      ),
      AdminPanelEntry(
        label: 'نشاطي',
        description:
            'متابعة آخر نشاطات المستخدم داخل لوحة التحكم وسجل الحركة الشخصي.',
        route: AppRoutes.adminMyActivity,
        icon: Icons.history_rounded,
      ),
      AdminPanelEntry(
        label: 'دليل الاستخدام',
        description: 'الدليل المؤسسي الحي للمنصة حسب الدور والنظام والصلاحية.',
        route: AppRoutes.adminUsageGuide,
        icon: Icons.menu_book_rounded,
      ),
      AdminPanelEntry(
        label: 'بوابة إدارة المنصة',
        description: 'تجميع الحوكمة والإدارة العامة والأنظمة من مكان واحد.',
        route: AppRoutes.adminSettings,
        icon: Icons.settings_suggest_rounded,
      ),
    ],
  );

  static const publicGroup = AdminPanelGroup(
    id: 'public',
    title: 'المحتوى والواجهات',
    subtitle:
        'إدارة renderer الواجهة العامة والصفحة الرئيسية وصفحات الوحدات والأنظمة دون خلطها بمراكز الخدمات أو الإعلام.',
    items: [
      AdminPanelEntry(
        label: 'إدارة الصفحة الرئيسية',
        description:
            'ترتيب أقسام الصفحة الرئيسية العامة والهوية العامة ومكونات الـ body الخاصة بـ home فقط.',
        route: AppRoutes.adminHomeManagement,
        icon: Icons.home_filled,
      ),
      AdminPanelEntry(
        label: 'إدارة واجهات الوحدات',
        description:
            'إدارة الصفحات الديناميكية الخاصة بالوحدات واختيار allowedSections ومعاينتها من مصدر الوحدات الحقيقي.',
        route: AppRoutes.adminUnitSurfacesManagement,
        icon: Icons.account_tree_rounded,
      ),
      AdminPanelEntry(
        label: 'إدارة واجهات الأنظمة',
        description:
            'إدارة Body الأنظمة المرتبطة بالمنصة تحت نفس العقد الحاكم مع بقاء الـ Chrome عامًا ومركزيًا.',
        route: AppRoutes.adminSystemSurfacesManagement,
        icon: Icons.widgets_rounded,
      ),
      AdminPanelEntry(
        label: 'إدارة المحتوى المشترك',
        description:
            'إدارة العناصر المشتركة غير الإعلامية في الواجهة العامة دون خلطها بالمركز الإعلامي.',
        route: AppRoutes.adminSharedContent,
        icon: Icons.dashboard_customize_rounded,
      ),
    ],
  );

  static const surfacesServicesGroup = AdminPanelGroup(
    id: 'surfaces_services',
    title: 'مركز الخدمات',
    subtitle:
        'مساحة عمل تشغيلية لخدمات الجمهور والخدمات الإلكترونية والطلبات والنماذج والاستعلامات والشكاوى وروابط الوصول. لا يضم المحتوى الإعلامي.',
    items: [
      AdminPanelEntry(
        label: 'لوحة مركز الخدمات',
        description:
            'مساحة عمل يومية تبدأ من الاستقبال والمتابعة والشكاوى والإبراز، مع إبقاء الحوكمة عند الطلب.',
        route: AppRoutes.adminSurfacesServices,
        icon: Icons.apps_rounded,
      ),
      AdminPanelEntry(
        label: 'دليل الخدمات',
        description: 'إدارة صفحة الخدمات العامة وبطاقات دليل الخدمات الحكومية.',
        route: AppRoutes.adminServicesPage,
        icon: Icons.design_services_rounded,
      ),
      AdminPanelEntry(
        label: 'الخدمات الإلكترونية',
        description:
            'إدارة صفحة الخدمات الإلكترونية وروابط الوصول إلى الخدمات الرقمية.',
        route: AppRoutes.adminEServicesPage,
        icon: Icons.computer_rounded,
      ),
      AdminPanelEntry(
        label: 'استقبال الطلبات',
        description:
            'مسودة تشغيلية لاستقبال طلبات الخدمة وتوجيهها حسب المسار والنطاق والمرفقات المطلوبة.',
        route: AppRoutes.adminSurfacesServicesRequests,
        icon: Icons.assignment_rounded,
      ),
      AdminPanelEntry(
        label: 'طابور الطلبات',
        description:
            'مسودة طابور إداري لفرز طلبات الخدمات ومتابعة الحالة ومصدر البيانات قبل الربط الإنتاجي.',
        route: AppRoutes.adminSurfacesServicesRequestQueue,
        icon: Icons.fact_check_rounded,
      ),
      AdminPanelEntry(
        label: 'سجل النماذج',
        description:
            'مسودة سجل موحد للنماذج الرسمية المرتبطة بدليل الخدمات والمراجع التنظيمية.',
        route: AppRoutes.adminSurfacesServicesFormsRegistry,
        icon: Icons.snippet_folder_rounded,
      ),
      AdminPanelEntry(
        label: 'الشكاوى والملاحظات',
        description:
            'قناة الشكاوى والملاحظات والبلاغات التشغيلية، بعيدًا عن الإعلام.',
        route: AppRoutes.adminComplaints,
        icon: Icons.report_gmailerrorred_rounded,
      ),
      AdminPanelEntry(
        label: 'الزكاة',
        description: 'إدارة خدمة الزكاة العامة ضمن نطاق خدمات platform.',
        route: AppRoutes.adminZakat,
        icon: Icons.volunteer_activism_rounded,
      ),
      AdminPanelEntry(
        label: 'مواقيت الصلاة',
        description: 'إدارة مواقيت الصلاة وواجهتها العامة.',
        route: AppRoutes.adminPrayerTimes,
        icon: Icons.access_time_filled_rounded,
      ),
      AdminPanelEntry(
        label: 'القرآن الكريم',
        description: 'إدارة خدمة القرآن الكريم ضمن المنصة.',
        route: AppRoutes.adminQuran,
        icon: Icons.menu_book_rounded,
      ),
      AdminPanelEntry(
        label: 'الخدمات السريعة',
        description:
            'إدارة اختصارات الخدمات الظاهرة في الصفحة الرئيسية وصفحات الوحدات.',
        route: AppRoutes.adminSurfacesServicesQuickServices,
        icon: Icons.miscellaneous_services_rounded,
      ),
      AdminPanelEntry(
        label: 'بوابة الخدمات الإلكترونية',
        description:
            'إدارة بطاقات بوابة الخدمات الإلكترونية داخل الواجهة العامة.',
        route: AppRoutes.adminSurfacesServicesEServicesPortal,
        icon: Icons.hub_rounded,
      ),
      AdminPanelEntry(
        label: 'الروابط السريعة',
        description: 'إدارة روابط الوصول السريعة scoped حسب home أو الوحدة.',
        route: AppRoutes.adminSurfacesServicesQuickLinks,
        icon: Icons.link_rounded,
      ),
      AdminPanelEntry(
        label: 'الروابط المهمة',
        description: 'تنظيم الروابط المهمة ضمن نفس طبقة الروابط المشتركة.',
        route: AppRoutes.adminSurfacesServicesImportantLinks,
        icon: Icons.bookmark_added_rounded,
      ),
      AdminPanelEntry(
        label: 'البطاقات المميزة',
        description:
            'إدارة بطاقات الإبراز التي توجه الزائر إلى خدمات أو صفحات مهمة.',
        route: AppRoutes.adminSurfacesServicesFeatureHighlights,
        icon: Icons.auto_awesome_rounded,
      ),
      AdminPanelEntry(
        label: 'الإحصائيات',
        description: 'إدارة عدادات وإحصائيات الصفحة الرئيسية وصفحات الوحدات.',
        route: AppRoutes.adminSurfacesServicesStatistics,
        icon: Icons.bar_chart_rounded,
      ),
      AdminPanelEntry(
        label: 'الخريطة التمهيدية',
        description: 'إدارة القسم التمهيدي للخريطة والمستكشف داخل الواجهة.',
        route: AppRoutes.adminSurfacesServicesMiniMapTeaser,
        icon: Icons.map_rounded,
      ),
      AdminPanelEntry(
        label: 'الأنظمة والقوانين والتعليمات',
        description:
            'المراجع الرسمية: قوانين، أنظمة، تعليمات، تعاميم، أدلة إجرائية، ونماذج مرتبطة بالخدمات.',
        route: AppRoutes.adminSurfacesServicesLegalReferences,
        icon: Icons.gavel_rounded,
      ),
    ],
  );

  static const mediaCenterGroup = AdminPanelGroup(
    id: 'media_center',
    title: 'المركز الإعلامي',
    subtitle:
        'المحتوى المنشور والرصد والتوثيق الإعلامي: أخبار، إعلانات، أنشطة، فعاليات، اجتماعيات، وسائط، مرصد، وتقارير.',
    items: [
      AdminPanelEntry(
        label: 'لوحة المركز الإعلامي',
        description:
            'لوحة service-first لتشغيل خدمات الإعلام مع إبقاء الحوكمة والتشخيص عند الطلب.',
        route: AppRoutes.adminMediaCenter,
        icon: Icons.perm_media_rounded,
      ),
      AdminPanelEntry(
        label: 'المركز الإعلامي للوحدات',
        description:
            'مساحة تحرير محكومة تعرض محتوى الوحدة الحالية فقط، مع اختيار سياق صريح للحسابات ذات السلطة الشاملة.',
        route: AppRoutes.adminUnitMediaCenter,
        icon: Icons.account_tree_rounded,
      ),
      AdminPanelEntry(
        label: 'معلومات الحوكمة',
        description:
            'حوكمة المركز الإعلامي ومبررات الصفحات وسير التحرير والصلاحيات.',
        route: AppRoutes.adminMediaCenterGovernance,
        icon: Icons.policy_rounded,
      ),
      AdminPanelEntry(
        label: 'الأخبار',
        description: 'إدارة أخبار الوزارة والوحدات مع فصل home عن slug.',
        route: AppRoutes.adminMediaCenterNews,
        icon: Icons.newspaper_rounded,
      ),
      AdminPanelEntry(
        label: 'الإعلانات',
        description:
            'إدارة الإعلانات العامة وإعلانات الوحدات حسب الأولوية وتاريخ الظهور.',
        route: AppRoutes.adminMediaCenterAnnouncements,
        icon: Icons.campaign_rounded,
      ),
      AdminPanelEntry(
        label: 'الأنشطة',
        description: 'أرشيف وتوثيق النشاط المؤسسي والميداني للوزارة والوحدات.',
        route: AppRoutes.adminMediaCenterActivities,
        icon: Icons.event_note_rounded,
      ),
      AdminPanelEntry(
        label: 'الفعاليات',
        description: 'إدارة أحداث لها موعد ومكان وحضور وحالة قادمة أو منتهية.',
        route: AppRoutes.adminMediaCenterEvents,
        icon: Icons.celebration_rounded,
      ),
      AdminPanelEntry(
        label: 'الاجتماعيات',
        description:
            'تهاني وتعازي ومناسبات اجتماعية رسمية؛ تصنف إعلاميًا لا كخدمة جمهور.',
        route: AppRoutes.adminMediaCenterSocialPosts,
        icon: Icons.groups_2_rounded,
      ),
      AdminPanelEntry(
        label: 'معرض الصور',
        description: 'إدارة الصور الرسمية وصور الوحدات مع النص البديل والحقوق.',
        route: AppRoutes.adminMediaCenterPhotos,
        icon: Icons.photo_library_rounded,
      ),
      AdminPanelEntry(
        label: 'الفيديوهات',
        description: 'إدارة الفيديوهات والروابط الخارجية ومواد المعاينة.',
        route: AppRoutes.adminMediaCenterVideos,
        icon: Icons.ondemand_video_rounded,
      ),
      AdminPanelEntry(
        label: 'الأخبار العاجلة',
        description: 'إدارة الرسائل العاجلة ذات الظهور المركزي والزمن المحدد.',
        route: AppRoutes.adminMediaCenterBreakingNews,
        icon: Icons.priority_high_rounded,
      ),
      AdminPanelEntry(
        label: 'خُطب الجمعة',
        description: 'إدارة الخطب والمحتوى التخصصي المرتبط بها.',
        route: AppRoutes.adminMediaCenterFridaySermons,
        icon: Icons.mic_rounded,
      ),
      AdminPanelEntry(
        label: 'السلايدر والحملات البصرية',
        description: 'إدارة الشرائح والرسائل البصرية وCTA وترتيب الظهور.',
        route: AppRoutes.adminMediaCenterHeroSlider,
        icon: Icons.slideshow_rounded,
      ),
      AdminPanelEntry(
        label: 'البيانات الصحفية',
        description: 'مواقف وتوضيحات رسمية بصياغة حكومية مع اعتماد مركزي.',
        route: AppRoutes.adminMediaCenterPressReleases,
        icon: Icons.article_rounded,
      ),
      AdminPanelEntry(
        label: 'التصريحات الرسمية',
        description:
            'تصريحات منسوبة لمسؤول أو ناطق رسمي مع ضبط المتحدث والصفة.',
        route: AppRoutes.adminMediaCenterOfficialStatements,
        icon: Icons.record_voice_over_rounded,
      ),
      AdminPanelEntry(
        label: 'الحملات التوعوية',
        description: 'حملات ذات هدف وفترة وجمهور مستهدف ومواد مصاحبة.',
        route: AppRoutes.adminMediaCenterAwarenessCampaigns,
        icon: Icons.campaign_rounded,
      ),
      AdminPanelEntry(
        label: 'الأجندة الإعلامية',
        description: 'تخطيط النشر والتغطيات والحملات والمناسبات القادمة.',
        route: AppRoutes.adminMediaCenterEditorialCalendar,
        icon: Icons.calendar_month_rounded,
      ),
      AdminPanelEntry(
        label: 'مكتبة المواد الإعلامية',
        description:
            'الشعار والقوالب والصور المعتمدة والكتيبات والمواد الرسمية.',
        route: AppRoutes.adminMediaCenterMediaLibrary,
        icon: Icons.folder_special_rounded,
      ),
      AdminPanelEntry(
        label: 'مرصد حماية المقدسات',
        description:
            'رصد موثق للانتهاكات والاعتداءات على المقدسات مع إحصائيات وتقارير.',
        route: AppRoutes.adminMediaCenterSanctitiesObservatory,
        icon: Icons.shield_rounded,
      ),
      AdminPanelEntry(
        label: 'التقارير الإعلامية',
        description:
            'تقارير منشورة أو داخلية حول الحملات والتغطيات والإنجازات الإعلامية.',
        route: AppRoutes.adminMediaCenterMediaReports,
        icon: Icons.summarize_rounded,
      ),
      AdminPanelEntry(
        label: 'التغطيات والرصد الإعلامي',
        description:
            'متابعة ما ينشر عن الوزارة وقضايا الأوقاف في الإعلام الخارجي.',
        route: AppRoutes.adminMediaCenterMediaCoverage,
        icon: Icons.travel_explore_rounded,
      ),
      AdminPanelEntry(
        label: 'قصص الأثر الوقفي',
        description:
            'قصص أثر موثقة وغير دعائية عن أثر الوقف والمشاريع الوقفية.',
        route: AppRoutes.adminMediaCenterWaqfImpactStories,
        icon: Icons.auto_stories_rounded,
      ),
    ],
  );

  static const publicPagesGroup = AdminPanelGroup(
    id: 'public_pages',
    title: 'الصفحات الرسمية الثابتة',
    subtitle:
        'صفحات تعريفية وتنظيمية عامة لا تُصنف كخدمات جمهور ولا كمحتوى إعلامي.',
    items: [
      AdminPanelEntry(
        label: 'بوابة الصفحات العامة',
        description:
            'فهرس إداري لجميع الصفحات العامة المرتبطة حقيقيًا بالقوائم والموقع.',
        route: AppRoutes.adminPublicPagesHub,
        icon: Icons.web_asset_rounded,
      ),
      AdminPanelEntry(
        label: 'عن الوزارة',
        description: 'إدارة الصفحة التعريفية الرسمية للوزارة.',
        route: AppRoutes.adminAboutPage,
        icon: Icons.info_outline_rounded,
      ),
      AdminPanelEntry(
        label: 'كلمة الوزير',
        description: 'إدارة الرسالة الرسمية لصفحة كلمة الوزير.',
        route: AppRoutes.adminMinisterPage,
        icon: Icons.record_voice_over_outlined,
      ),
      AdminPanelEntry(
        label: 'الرؤية والرسالة',
        description: 'إدارة النصوص المرجعية للرؤية والرسالة والقيم.',
        route: AppRoutes.adminVisionMissionPage,
        icon: Icons.track_changes_outlined,
      ),
      AdminPanelEntry(
        label: 'الهيكل التنظيمي',
        description: 'إدارة عرض صفحة الهيكل التنظيمي المرتبطة بمرجع الوحدات.',
        route: AppRoutes.adminStructurePage,
        icon: Icons.account_tree_outlined,
      ),
      AdminPanelEntry(
        label: 'الوزراء السابقون',
        description: 'إدارة الصفحة التاريخية للوزراء السابقين.',
        route: AppRoutes.adminFormerMinistersPage,
        icon: Icons.history_edu_outlined,
      ),
      AdminPanelEntry(
        label: 'المشاريع',
        description: 'إدارة صفحة المشاريع والمبادرات العامة.',
        route: AppRoutes.adminProjectsPage,
        icon: Icons.work_outline_rounded,
      ),
      AdminPanelEntry(
        label: 'اتصل بنا',
        description: 'إدارة صفحة الاتصال وبيانات الوصول الرسمية.',
        route: AppRoutes.adminContactPage,
        icon: Icons.contact_phone_outlined,
      ),
      AdminPanelEntry(
        label: 'سياسة الخصوصية',
        description: 'إدارة النص الرسمي لسياسة الخصوصية.',
        route: AppRoutes.adminPrivacyPage,
        icon: Icons.privacy_tip_outlined,
      ),
      AdminPanelEntry(
        label: 'شروط الاستخدام',
        description: 'إدارة النص الرسمي لشروط الاستخدام.',
        route: AppRoutes.adminTermsPage,
        icon: Icons.rule_folder_outlined,
      ),
      AdminPanelEntry(
        label: 'خريطة الموقع',
        description: 'إدارة صفحة خريطة الموقع وروابطها العامة.',
        route: AppRoutes.adminSitemapPage,
        icon: Icons.map_outlined,
      ),
    ],
  );

  static const platformServicesGroup = AdminPanelGroup(
    id: 'platform_services',
    title: 'خدمات المنصة',
    subtitle:
        'مساحات إدارية حقيقية لخدمات المنصة العامة، منفصلة عن إدارة الصفحة الرئيسية نفسها.',
    items: [
      AdminPanelEntry(
        label: 'خدمة الزكاة',
        description: 'صفحة إدارية فعلية لإدارة الزكاة تحت إطار المنصة.',
        route: AppRoutes.adminZakat,
        icon: Icons.volunteer_activism_rounded,
      ),
      AdminPanelEntry(
        label: 'مواقيت الصلاة',
        description: 'صفحة إدارية فعلية لإدارة مواقيت الصلاة ضمن خدمات المنصة.',
        route: AppRoutes.adminPrayerTimes,
        icon: Icons.access_time_filled_rounded,
      ),
      AdminPanelEntry(
        label: 'القرآن الكريم',
        description: 'صفحة إدارية فعلية لإدارة القرآن الكريم ضمن خدمات المنصة.',
        route: AppRoutes.adminQuran,
        icon: Icons.menu_book_rounded,
      ),
    ],
  );

  static const platformGroup = AdminPanelGroup(
    id: 'platform',
    title: 'المنصة',
    subtitle:
        'إدارة المستخدمين والوحدات والملف الشخصي مع بوابة الحوكمة العامة.',
    items: [
      AdminPanelEntry(
        label: 'بوابة إدارة المنصة',
        description: 'بوابة الحوكمة والتنظيم والإحالة بين أقسام الإدارة.',
        route: AppRoutes.adminSettings,
        icon: Icons.settings_outlined,
      ),
      AdminPanelEntry(
        label: 'النظام الإداري المرجعي',
        description:
            'الوصول إلى awqaf_system / adminData باعتباره مرجعًا إداريًا داخليًا لا نظامًا فرعيًا عاديًا.',
        route: AppRoutes.adminData,
        icon: Icons.hub_rounded,
      ),
      AdminPanelEntry(
        label: 'استلام سجل الأصول الوقفية',
        description:
            'استلام مخرجات awqaf_system كـ review-ready فقط، دون تعديل waqf_assets أو منطق المراجعة.',
        route: AppRoutes.adminWaqfAssetsIntegrationIntake,
        icon: Icons.account_tree_rounded,
      ),
      AdminPanelEntry(
        label: 'عقود الربط بين الأنظمة',
        description:
            'مصفوفة read-only لعقود الربط بين awqaf_system والوثائق والقضايا والمهام والمالية والمساعد والمستكشف.',
        route: AppRoutes.adminCrossSystemContracts,
        icon: Icons.account_tree_outlined,
      ),
      AdminPanelEntry(
        label: 'سجل الأنظمة والأقسام',
        description:
            'إضافة الأنظمة والخدمات والأقسام ديناميكيًا وربطها بالداشبورد والسايدبار وRBAC.',
        route: AppRoutes.adminDynamicSystemRegistry,
        icon: Icons.playlist_add_check_circle_rounded,
      ),
      AdminPanelEntry(
        label: 'مركز تشغيل الأنظمة المندمجة',
        description:
            'مراقبة الأنظمة شبه المستقلة، الصلاحيات، الصحة، الصيانة، والمسارات التشغيلية دون خلط منطق الأنظمة داخل المنصة.',
        route: AppRoutes.adminSystemOperations,
        icon: Icons.account_tree_rounded,
      ),
      AdminPanelEntry(
        label: 'الخدمات التقنية',
        description:
            'بوابة محكومة للنسخ الاحتياطي، الصيانة، صحة النظام، النشر، والسجلات دون تنفيذ مؤثر من Flutter.',
        route: AppRoutes.adminTechnicalServices,
        icon: Icons.admin_panel_settings_rounded,
      ),
      AdminPanelEntry(
        label: 'النسخ الاحتياطي',
        description:
            'جاهزية backup/restore دون export أو restore من الواجهة ودون تجاوز RLS.',
        route: AppRoutes.adminTechnicalServicesBackup,
        icon: Icons.backup_rounded,
      ),
      AdminPanelEntry(
        label: 'وضع الصيانة',
        description:
            'تخطيط نوافذ الصيانة ورسائلها وحدودها دون إغلاق تلقائي للموقع.',
        route: AppRoutes.adminTechnicalServicesMaintenance,
        icon: Icons.construction_rounded,
      ),
      AdminPanelEntry(
        label: 'صحة النظام',
        description:
            'قراءة مؤشرات صحة Flutter Web وSupabase وRPCs وPostGIS دون mutation.',
        route: AppRoutes.adminTechnicalServicesHealth,
        icon: Icons.monitor_heart_rounded,
      ),
      AdminPanelEntry(
        label: 'النشر والإصدارات',
        description:
            'توثيق Flutter/Dart/Vercel وأوامر التشغيل والبناء دون CI/CD مباشر من اللوحة.',
        route: AppRoutes.adminTechnicalServicesDeployment,
        icon: Icons.rocket_launch_rounded,
      ),
      AdminPanelEntry(
        label: 'السجلات والتدقيق التقني',
        description:
            'متابعة سجلات التشغيل والـ smoke evidence وطلبات الصيانة دون حذف سجلات.',
        route: AppRoutes.adminTechnicalServicesAudit,
        icon: Icons.manage_search_rounded,
      ),
      AdminPanelEntry(
        label: 'برنامج نقل ملكية الجداول',
        description:
            'متابعة تنظيف public schema، حسم كاش الوحدات، واختيار مرشحي النقل إلى site_content/media_center/platform_services.',
        route: AppRoutes.adminDatabaseMigration,
        icon: Icons.schema_rounded,
      ),
      AdminPanelEntry(
        label: 'نظام الواجهات السيادي',
        description:
            'معرض مكونات PWF-SIS وجسر الهوية البصرية وPilot أوقاف وخطة التعميم المضبوطة.',
        route: AppRoutes.adminDesignSystem,
        icon: Icons.design_services_rounded,
      ),
      AdminPanelEntry(
        label: 'تعميم PWF-SIS والأدلة',
        description:
            'مصفوفة rollout وBrowser UAT وrole validation وrollback قبل أي اعتماد إنتاجي.',
        route: AppRoutes.adminDesignSystemRolloutEvidence,
        icon: Icons.fact_check_rounded,
      ),
      AdminPanelEntry(
        label: 'نطاق Wave 2 في PWF-SIS',
        description:
            'اختيار مرشح Wave 2 ومصفوفة المخاطر والأدلة قبل أي تعميم خارج pilot.',
        route: AppRoutes.adminDesignSystemWave2Scope,
        icon: Icons.rule_folder_rounded,
      ),
      AdminPanelEntry(
        label: 'جرد مسارات Media Center',
        description:
            'جرد مسارات المركز الإعلامي وتصنيف مخاطرها قبل قرار Wave 2 التنفيذي.',
        route: AppRoutes.adminDesignSystemWave2MediaInventory,
        icon: Icons.route_rounded,
      ),
      AdminPanelEntry(
        label: 'مركز التقارير',
        description:
            'استعادة شاشة التقارير التنفيذية التي كانت موجودة في الكود وغير مركبة في التنقل.',
        route: AppRoutes.adminReports,
        icon: Icons.analytics_rounded,
      ),
      AdminPanelEntry(
        label: 'المستخدمون',
        description: 'إدارة المستخدمين، التفعيل، والصلاحيات الإدارية.',
        route: AppRoutes.adminUsers,
        icon: Icons.people_outline,
      ),
      AdminPanelEntry(
        label: 'المؤسسات والوحدات',
        description: 'إدارة المؤسسات والوحدات التنظيمية والربط المؤسسي.',
        route: AppRoutes.adminOrgUnits,
        icon: Icons.apartment_outlined,
      ),
      AdminPanelEntry(
        label: 'تفعيل الوحدات والنشر',
        description:
            'فصل حالة تفعيل الوحدة عن نشر سطحها العام، ومراجعة جاهزية الظهور للعامة.',
        route: AppRoutes.adminUnitOperationalActivation,
        icon: Icons.toggle_on_rounded,
      ),
      AdminPanelEntry(
        label: 'الشكاوى',
        description:
            'الخدمة السيادية للشكاوى على مستوى المنصة مع مسار إداري مركزي.',
        route: AppRoutes.adminComplaints,
        icon: Icons.report_gmailerrorred_rounded,
      ),
      AdminPanelEntry(
        label: 'الذكاء الوثائقي',
        description:
            'إدارة وظائف استعادة الوثائق، الاستخراج المنظم، الربط، وطوابير المراجعة.',
        route: AppRoutes.adminDocumentIntelligence,
        icon: Icons.auto_awesome_motion_rounded,
      ),
      AdminPanelEntry(
        label: 'مراجعة الوثائق',
        description:
            'الوصول المباشر إلى طابور مراجعة الوثائق والروابط المقترحة.',
        route: AppRoutes.adminDocumentIntelligenceReviewQueue,
        icon: Icons.rate_review_rounded,
      ),
      AdminPanelEntry(
        label: 'الملف الشخصي',
        description: 'الوصول إلى إعدادات الحساب والملف الشخصي.',
        route: AppRoutes.adminProfile,
        icon: Icons.person_outline,
      ),
    ],
  );

  static const systemsGroup = AdminPanelGroup(
    id: 'systems',
    title: 'الأنظمة',
    subtitle:
        'الوصول المباشر إلى الأنظمة شبه المستقلة والتشغيلية المرتبطة بالمنصة.',
    items: [
      AdminPanelEntry(
        label: 'نظام الأراضي الوقفية',
        description: 'الدخول إلى نظام الأصول والأراضي الوقفية.',
        route: AppRoutes.adminWaqfLands,
        icon: Icons.landscape_rounded,
      ),
      AdminPanelEntry(
        label: 'استلام waqf_assets من awqaf_system',
        description:
            'صفحة عقد استلام read-only توضّح الجاهزية والقيود قبل أي تكامل كامل.',
        route: AppRoutes.adminWaqfAssetsIntegrationIntake,
        icon: Icons.rule_folder_rounded,
      ),
      AdminPanelEntry(
        label: 'عقود الربط بين الأنظمة',
        description:
            'مصفوفة read-only لعقود الربط بين awqaf_system والوثائق والقضايا والمهام والمالية والمساعد والمستكشف.',
        route: AppRoutes.adminCrossSystemContracts,
        icon: Icons.account_tree_outlined,
      ),
      AdminPanelEntry(
        label: 'نظام المساجد',
        description: 'إدارة نظام المساجد وخدماته المرتبطة.',
        route: AppRoutes.adminMosques,
        icon: Icons.mosque_rounded,
      ),
      AdminPanelEntry(
        label: 'نظام القضايا',
        description: 'الوصول إلى القضايا الوقفية ومتابعتها.',
        route: AppRoutes.adminCases,
        icon: Icons.gavel_rounded,
        badge: 45,
      ),
      AdminPanelEntry(
        label: 'نظام المهام',
        description:
            'إدارة المهام والمتابعات وربطها بالأصول والقضايا والفوترة.',
        route: AppRoutes.adminTasks,
        icon: Icons.task_alt_rounded,
      ),
      AdminPanelEntry(
        label: 'نظام الوثائق',
        description: 'إدارة الوثائق والأرشفة والمرفقات.',
        route: AppRoutes.adminDocuments,
        icon: Icons.folder_rounded,
      ),
    ],
  );

  static const governanceAuditGroup = AdminPanelGroup(
    id: 'governance',
    title: 'الحوكمة والتدقيق',
    subtitle:
        'مداخل on-demand للجاهزية والتدقيق وUAT والتوثيق دون مزاحمة واجهات التشغيل اليومي.',
    items: [
      AdminPanelEntry(
        label: 'مركز التقارير',
        description: 'تقارير تنفيذية وجاهزية عامة للمنصة والأنظمة.',
        route: AppRoutes.adminReports,
        icon: Icons.analytics_rounded,
      ),
      AdminPanelEntry(
        label: 'دليل الاستخدام الحي',
        description: 'دليل مؤسسي مرتبط بالأدوار والصلاحيات والأنظمة.',
        route: AppRoutes.adminUsageGuide,
        icon: Icons.menu_book_rounded,
      ),
      AdminPanelEntry(
        label: 'حوكمة المركز الإعلامي',
        description: 'معلومات حوكمة المركز الإعلامي وصفحاته ومبررات النشر.',
        route: AppRoutes.adminMediaCenterGovernance,
        icon: Icons.policy_rounded,
      ),
      AdminPanelEntry(
        label: 'مراجعة الوثائق',
        description: 'طابور مراجعة مركز الوثائق والروابط المقترحة.',
        route: AppRoutes.adminDocumentIntelligenceReviewQueue,
        icon: Icons.rate_review_rounded,
      ),
      AdminPanelEntry(
        label: 'حوكمة استلام waqf_assets',
        description:
            'حدود الاستلام من awqaf_system، وقائمة Do Not Touch، وبوابات P1 قبل التكامل الكامل.',
        route: AppRoutes.adminWaqfAssetsIntegrationIntake,
        icon: Icons.verified_user_rounded,
      ),
      AdminPanelEntry(
        label: 'عقود الربط بين الأنظمة',
        description:
            'مصفوفة read-only لعقود الربط بين awqaf_system والوثائق والقضايا والمهام والمالية والمساعد والمستكشف.',
        route: AppRoutes.adminCrossSystemContracts,
        icon: Icons.account_tree_outlined,
      ),
      AdminPanelEntry(
        label: 'أدوات المطور',
        description:
            'تشخيص المسارات وأسماء الصفحات ومتابعة TODO التطوير التشغيلي بعد استقرار التحليل.',
        route: AppRoutes.adminDeveloper,
        icon: Icons.developer_mode_rounded,
      ),
    ],
  );

  static const developerGroup = AdminPanelGroup(
    id: 'developer',
    title: 'المطور',
    subtitle:
        'أدوات صيانة وتشخيص للمطور، تشمل إظهار أسماء الصفحات ومساراتها عبر النظام لتسهيل تتبع الأخطاء.',
    items: [
      AdminPanelEntry(
        label: 'أدوات المطور',
        description:
            'تشغيل وضع الصيانة وإظهار أسماء الصفحات والمسارات وسجل التطوير التشغيلي الحالي.',
        route: AppRoutes.adminDeveloper,
        icon: Icons.developer_mode_rounded,
      ),
    ],
  );

  static const governedSystems = <AdminGovernedSystem>[
    AdminGovernedSystem(
      systemKey: SystemKey.adminData,
      label: 'awqaf_system',
      description:
          'العقل الإداري للمنصة ومصدر الحقيقة الإداري المرجعي المرتبط بالمؤسسة والوحدات والمرجعيات والسيادة الإدارية.',
      icon: Icons.hub_outlined,
      tier: AdminGovernanceTier.administrativeCore,
      familyAr: 'النظام الإداري المرجعي الرئيسي',
      notesAr:
          'يمثل awqaf_system المسار المرجعي/الإداري الرئيسي للمنصة. route العرض الحالي في التطبيق العام هو /admin-data، لكنه لا يعامَل كنظام فرعي عادي.',
      adminRoute: AppRoutes.adminData,
    ),
    AdminGovernedSystem(
      systemKey: SystemKey.platformAdmin,
      label: 'لوحة الإدارة',
      description:
          'النظام الحاكم لإدارة المنصة، المستخدمين، الحوكمة، والبوابات الإدارية.',
      icon: Icons.admin_panel_settings_outlined,
      tier: AdminGovernanceTier.administrativeCore,
      familyAr: 'الحوكمة والإدارة العامة',
      notesAr:
          'تلتقي مع awqaf_system في الحوكمة العامة، لكنها ليست بديلًا عنه كمصدر إداري سيادي للبيانات المرجعية.',
      adminRoute: AppRoutes.adminUsers,
    ),
    AdminGovernedSystem(
      systemKey: SystemKey.site,
      label: 'الموقع العام',
      description:
          'الواجهة العامة للوزارة والوحدات وما يتصل بها من محتوى وتشغيل.',
      icon: Icons.public_outlined,
      tier: AdminGovernanceTier.connectedSystem,
      familyAr: 'واجهة عامة ديناميكية',
      notesAr:
          'صفحة ديناميكية موحدة تتغذى من home أو slug، وتلتزم بالعقد الحاكم للمنصة.',
      adminRoute: AppRoutes.adminHomeManagement,
    ),
    AdminGovernedSystem(
      systemKey: SystemKey.mustakshif,
      label: 'مستكشف الوقف',
      description:
          'النظام المكاني/التاريخي لتحليل الأصول الوقفية والطبقات والروابط التاريخية.',
      icon: Icons.map_outlined,
      tier: AdminGovernanceTier.connectedSystem,
      familyAr: 'نظام تحليلي مكاني/تاريخي',
      notesAr:
          'نظام شبه مستقل متصل حوكميًا بالمنصة ويشارك العقد العام وقاعدة البيانات، وليس مجرد صفحة محتوى.',
    ),
    AdminGovernedSystem(
      systemKey: SystemKey.lands,
      label: 'نظام الأراضي الوقفية',
      description:
          'شاشة الإدارة الحالية للأصول/الأراضي الوقفية داخل لوحة التحكم.',
      icon: Icons.landscape_outlined,
      tier: AdminGovernanceTier.connectedSystem,
      familyAr: 'تشغيلي/أصول',
      notesAr: 'واجهة تشغيلية مرتبطة بالأصول الوقفية ضمن العقد العام للمنصة.',
      adminRoute: AppRoutes.adminWaqfLands,
      visibleInAdminSystemsTab: true,
    ),
    AdminGovernedSystem(
      systemKey: SystemKey.properties,
      label: 'نظام العقارات/الأصول',
      description:
          'نظام تشغيلي مرتبط بالأصول الوقفية والعقود والاستعمالات عند تفعيله.',
      icon: Icons.location_city_outlined,
      tier: AdminGovernanceTier.connectedSystem,
      familyAr: 'تشغيلي/أصول',
      notesAr: 'نظام متخصص سيضاف أو يتوسع لاحقًا ضمن بنية المنصة المتصلة.',
    ),
    AdminGovernedSystem(
      systemKey: SystemKey.cases,
      label: 'نظام القضايا',
      description: 'إدارة القضايا الوقفية والروابط القانونية للأصول الوقفية.',
      icon: Icons.gavel_outlined,
      tier: AdminGovernanceTier.connectedSystem,
      familyAr: 'نظام قانوني/تشغيلي',
      notesAr:
          'نظام شبه مستقل مرتبط بالمنصة ويخضع للحوكمة العامة وRBAC المشترك.',
      adminRoute: AppRoutes.adminCases,
      visibleInAdminSystemsTab: true,
    ),
    AdminGovernedSystem(
      systemKey: SystemKey.tasks,
      label: 'نظام المهام',
      description:
          'متابعة المهام الميدانية والإدارية وربطها بالأصول والقضايا والفوترة.',
      icon: Icons.task_alt_outlined,
      tier: AdminGovernanceTier.connectedSystem,
      familyAr: 'نظام تشغيلي/متابعة',
      notesAr:
          'يدير التنفيذ والمتابعة دون أن يعيد تعريف البيانات المرجعية السيادية.',
      adminRoute: AppRoutes.adminTasks,
      visibleInAdminSystemsTab: true,
    ),
    AdminGovernedSystem(
      systemKey: SystemKey.mosques,
      label: 'نظام المساجد',
      description: 'إدارة المساجد وخدماتها وربطها بالمنصة الحالية.',
      icon: Icons.mosque_outlined,
      tier: AdminGovernanceTier.connectedSystem,
      familyAr: 'خدمة تخصصية مرتبطة',
      notesAr:
          'نظام متخصص مرتبط بالمنصة ويستفيد من الهوية والصلاحيات المشتركة.',
      adminRoute: AppRoutes.adminMosques,
      visibleInAdminSystemsTab: true,
    ),
    AdminGovernedSystem(
      systemKey: SystemKey.billing,
      label: 'نظام الفوترة',
      description:
          'الفواتير والعقود والدفعات والمتأخرات المرتبطة بالأصول الوقفية.',
      icon: Icons.receipt_long_outlined,
      tier: AdminGovernanceTier.connectedSystem,
      familyAr: 'نظام مالي/تشغيلي',
      notesAr:
          'يرتبط بالعقد الحاكم للمنصة لكنه يحتفظ بمنطقه المالي والتشغيلي الخاص.',
    ),
  ];

  static List<AdminGovernedSystem> governedSystemsByTier(
    AdminGovernanceTier tier,
  ) {
    return governedSystems
        .where((system) => system.tier == tier)
        .toList(growable: false);
  }

  static List<AdminGovernedSystem> get administrativeCoreSystems =>
      governedSystemsByTier(AdminGovernanceTier.administrativeCore);

  static List<AdminGovernedSystem> get connectedSystems =>
      governedSystemsByTier(AdminGovernanceTier.connectedSystem);

  static const orderedGroups = <AdminPanelGroup>[
    mainGroup,
    publicGroup,
    surfacesServicesGroup,
    mediaCenterGroup,
    publicPagesGroup,
    platformGroup,
    systemsGroup,
    governanceAuditGroup,
    developerGroup,
  ];

  static const groupEntrySections = <String, List<AdminPanelEntrySection>>{
    'main': [
      AdminPanelEntrySection(
        title: 'العمل اليومي',
        icon: Icons.space_dashboard_rounded,
        routes: [
          AppRoutes.adminDashboard,
          AppRoutes.adminMyActivity,
          AppRoutes.adminAssistant,
        ],
      ),
      AdminPanelEntrySection(
        title: 'الدعم والمعاينة',
        icon: Icons.support_agent_rounded,
        routes: [
          AppRoutes.adminChatbot,
          AppRoutes.adminUsageGuide,
        ],
      ),
      AdminPanelEntrySection(
        title: 'الإدارة العامة',
        icon: Icons.settings_suggest_rounded,
        routes: [AppRoutes.adminSettings],
      ),
    ],
    'public': [
      AdminPanelEntrySection(
        title: 'إدارة الواجهات',
        icon: Icons.dashboard_customize_rounded,
        routes: [
          AppRoutes.adminHomeManagement,
          AppRoutes.adminUnitSurfacesManagement,
          AppRoutes.adminSystemSurfacesManagement,
          AppRoutes.adminSharedContent,
        ],
      ),
    ],
    'surfaces_services': [
      AdminPanelEntrySection(
        title: 'الاستقبال والمتابعة',
        icon: Icons.assignment_rounded,
        routes: [
          AppRoutes.adminServicesPage,
          AppRoutes.adminSurfacesServicesRequests,
          AppRoutes.adminSurfacesServicesRequestQueue,
          AppRoutes.adminSurfacesServicesFormsRegistry,
          AppRoutes.adminComplaints,
        ],
      ),
      AdminPanelEntrySection(
        title: 'الخدمات الإلكترونية والوصول',
        icon: Icons.computer_rounded,
        routes: [
          AppRoutes.adminEServicesPage,
          AppRoutes.adminSurfacesServicesEServicesPortal,
          AppRoutes.adminSurfacesServicesQuickServices,
          AppRoutes.adminSurfacesServicesQuickLinks,
          AppRoutes.adminSurfacesServicesImportantLinks,
        ],
      ),
      AdminPanelEntrySection(
        title: 'إبراز الواجهة العامة',
        icon: Icons.auto_awesome_rounded,
        routes: [
          AppRoutes.adminSurfacesServicesFeatureHighlights,
          AppRoutes.adminSurfacesServicesStatistics,
          AppRoutes.adminSurfacesServicesMiniMapTeaser,
        ],
      ),
      AdminPanelEntrySection(
        title: 'خدمات ومراجع رسمية',
        icon: Icons.gavel_rounded,
        routes: [
          AppRoutes.adminZakat,
          AppRoutes.adminPrayerTimes,
          AppRoutes.adminQuran,
          AppRoutes.adminSurfacesServicesLegalReferences,
        ],
      ),
    ],
    'media_center': [
      AdminPanelEntrySection(
        title: 'النشر الإعلامي الرسمي',
        icon: Icons.article_rounded,
        routes: [
          AppRoutes.adminMediaCenterNews,
          AppRoutes.adminMediaCenterAnnouncements,
          AppRoutes.adminMediaCenterPressReleases,
          AppRoutes.adminMediaCenterOfficialStatements,
          AppRoutes.adminMediaCenterBreakingNews,
        ],
      ),
      AdminPanelEntrySection(
        title: 'الأنشطة والفعاليات',
        icon: Icons.event_available_rounded,
        routes: [
          AppRoutes.adminMediaCenterActivities,
          AppRoutes.adminMediaCenterEvents,
          AppRoutes.adminMediaCenterEditorialCalendar,
          AppRoutes.adminMediaCenterSocialPosts,
        ],
      ),
      AdminPanelEntrySection(
        title: 'الوسائط والحملات',
        icon: Icons.photo_library_rounded,
        routes: [
          AppRoutes.adminMediaCenterPhotos,
          AppRoutes.adminMediaCenterVideos,
          AppRoutes.adminMediaCenterHeroSlider,
          AppRoutes.adminMediaCenterAwarenessCampaigns,
          AppRoutes.adminMediaCenterMediaLibrary,
        ],
      ),
      AdminPanelEntrySection(
        title: 'الرصد والتوثيق',
        icon: Icons.shield_rounded,
        routes: [
          AppRoutes.adminMediaCenterSanctitiesObservatory,
          AppRoutes.adminMediaCenterMediaReports,
          AppRoutes.adminMediaCenterMediaCoverage,
          AppRoutes.adminMediaCenterWaqfImpactStories,
          AppRoutes.adminMediaCenterFridaySermons,
        ],
      ),
    ],
    'public_pages': [
      AdminPanelEntrySection(
        title: 'تعريف الوزارة',
        icon: Icons.account_balance_rounded,
        routes: [
          AppRoutes.adminAboutPage,
          AppRoutes.adminMinisterPage,
          AppRoutes.adminVisionMissionPage,
          AppRoutes.adminStructurePage,
          AppRoutes.adminFormerMinistersPage,
        ],
      ),
      AdminPanelEntrySection(
        title: 'مراجع الموقع العامة',
        icon: Icons.public_rounded,
        routes: [
          AppRoutes.adminProjectsPage,
          AppRoutes.adminContactPage,
          AppRoutes.adminPrivacyPage,
          AppRoutes.adminTermsPage,
          AppRoutes.adminSitemapPage,
        ],
      ),
    ],
    'platform': [
      AdminPanelEntrySection(
        title: 'الهوية والهيكل المؤسسي',
        icon: Icons.people_alt_rounded,
        routes: [
          AppRoutes.adminUsers,
          AppRoutes.adminOrgUnits,
          AppRoutes.adminUnitOperationalActivation,
          AppRoutes.adminProfile,
        ],
      ),
      AdminPanelEntrySection(
        title: 'تشغيل المنصة وصيانتها',
        icon: Icons.settings_rounded,
        routes: [
          AppRoutes.adminTechnicalServices,
          AppRoutes.adminTechnicalServicesBackup,
          AppRoutes.adminTechnicalServicesMaintenance,
          AppRoutes.adminTechnicalServicesHealth,
          AppRoutes.adminTechnicalServicesDeployment,
          AppRoutes.adminTechnicalServicesAudit,
        ],
      ),
      AdminPanelEntrySection(
        title: 'سجل الأنظمة والتصميم',
        icon: Icons.account_tree_rounded,
        routes: [
          AppRoutes.adminDynamicSystemRegistry,
          AppRoutes.adminSystemOperations,
          AppRoutes.adminDesignSystem,
          AppRoutes.adminDesignSystemRolloutEvidence,
          AppRoutes.adminDesignSystemWave2Scope,
          AppRoutes.adminDesignSystemWave2MediaInventory,
          AppRoutes.adminDatabaseMigration,
        ],
      ),
      AdminPanelEntrySection(
        title: 'البيانات والتكامل والتقارير',
        icon: Icons.hub_rounded,
        routes: [
          AppRoutes.adminData,
          AppRoutes.adminWaqfAssetsIntegrationIntake,
          AppRoutes.adminCrossSystemContracts,
          AppRoutes.adminReports,
          AppRoutes.adminDocumentIntelligence,
          AppRoutes.adminDocumentIntelligenceReviewQueue,
        ],
      ),
    ],
    'systems': [
      AdminPanelEntrySection(
        title: 'الأصول والوقف',
        icon: Icons.landscape_rounded,
        routes: [
          AppRoutes.adminWaqfLands,
          AppRoutes.adminWaqfAssetsIntegrationIntake,
        ],
      ),
      AdminPanelEntrySection(
        title: 'الأنظمة القطاعية',
        icon: Icons.widgets_rounded,
        routes: [
          AppRoutes.adminMosques,
          AppRoutes.adminCases,
          AppRoutes.adminTasks,
          AppRoutes.adminDocuments,
        ],
      ),
      AdminPanelEntrySection(
        title: 'التكامل بين الأنظمة',
        icon: Icons.account_tree_outlined,
        routes: [AppRoutes.adminCrossSystemContracts],
      ),
    ],
    'governance': [
      AdminPanelEntrySection(
        title: 'التدقيق والجاهزية',
        icon: Icons.verified_user_rounded,
        routes: [
          AppRoutes.adminReports,
          AppRoutes.adminUsageGuide,
          AppRoutes.adminMediaCenterGovernance,
          AppRoutes.adminDocumentIntelligenceReviewQueue,
          AppRoutes.adminWaqfAssetsIntegrationIntake,
          AppRoutes.adminCrossSystemContracts,
        ],
      ),
      AdminPanelEntrySection(
        title: 'الصيانة والتشخيص',
        icon: Icons.developer_mode_rounded,
        routes: [
          AppRoutes.adminTechnicalServices,
          AppRoutes.adminTechnicalServicesBackup,
          AppRoutes.adminTechnicalServicesMaintenance,
          AppRoutes.adminTechnicalServicesHealth,
          AppRoutes.adminTechnicalServicesDeployment,
          AppRoutes.adminTechnicalServicesAudit,
        ],
      ),
    ],
  };

  static List<AdminPanelEntrySection> entrySectionsForGroup(String groupId) =>
      groupEntrySections[groupId] ?? const <AdminPanelEntrySection>[];

  static AdminPanelTabItem tabForRoute(String? route) {
    final value = route ?? '';
    if (_surfacesServicesRoutes.any((prefix) => value.startsWith(prefix)))
      return tabs[2];
    if (_publicRoutes.any((prefix) => value.startsWith(prefix))) return tabs[1];
    if (_mediaRoutes.any((prefix) => value.startsWith(prefix))) return tabs[3];
    if (_systemRoutes.any((prefix) => value.startsWith(prefix))) return tabs[4];
    if (_governanceRoutes.any((prefix) => value.startsWith(prefix)))
      return tabs[6];
    if (_platformRoutes.any((prefix) => value.startsWith(prefix)))
      return tabs[5];
    if (_developerRoutes.any((prefix) => value.startsWith(prefix)))
      return tabs[7];
    return tabs[0];
  }

  static List<AdminPanelGroup> groupsForTab(String tabKey) {
    switch (tabKey) {
      case 'public':
        return const [publicGroup, publicPagesGroup];
      case 'surfaces_services':
        return const [surfacesServicesGroup];
      case 'media':
        return const [mediaCenterGroup];
      case 'platform':
        return const [platformGroup];
      case 'systems':
        return const [systemsGroup];
      case 'governance':
        return const [governanceAuditGroup];
      case 'developer':
        return const [developerGroup];
      case 'main':
      default:
        return const [mainGroup];
    }
  }

  static String defaultRouteForTab(String tabKey) {
    final groups = groupsForTab(tabKey);
    for (final group in groups) {
      if (group.items.isNotEmpty) return group.items.first.route;
    }
    return AppRoutes.adminDashboard;
  }

  static List<AdminPanelEntry> quickAccessForPlatformPages() {
    return const [
      AdminPanelEntry(
        label: 'بوابة إدارة المنصة',
        description: 'العودة إلى تنظيم الحوكمة والإعدادات العامة.',
        route: AppRoutes.adminSettings,
        icon: Icons.settings_suggest_outlined,
      ),
      AdminPanelEntry(
        label: 'المستخدمون',
        description: 'التنقل السريع إلى إدارة المستخدمين والصلاحيات.',
        route: AppRoutes.adminUsers,
        icon: Icons.people,
      ),
      AdminPanelEntry(
        label: 'المؤسسات والوحدات',
        description: 'التنقل السريع إلى إدارة الوحدات والتنظيم المؤسسي.',
        route: AppRoutes.adminOrgUnits,
        icon: Icons.apartment,
      ),
      AdminPanelEntry(
        label: 'الشكاوى',
        description: 'الوصول السريع إلى الخدمة السيادية للشكاوى داخل المنصة.',
        route: AppRoutes.adminComplaints,
        icon: Icons.report_gmailerrorred_rounded,
      ),
      AdminPanelEntry(
        label: 'لوحة التحكم',
        description: 'العودة إلى لوحة التحكم الرئيسية.',
        route: AppRoutes.adminDashboard,
        icon: Icons.dashboard_customize_outlined,
      ),
      AdminPanelEntry(
        label: 'أدوات المطور',
        description: 'إظهار أسماء الصفحات ومساراتها وتشخيص التنقل الإداري.',
        route: AppRoutes.adminDeveloper,
        icon: Icons.developer_mode_rounded,
      ),
    ];
  }

  static List<AdminPanelEntry> get allEntries => [
    for (final group in orderedGroups) ...group.items,
  ];

  static List<AdminPanelEntry> quickAccessForSystemPages({
    String? excludeRoute,
  }) {
    return systemsGroup.items
        .where((item) => excludeRoute == null || item.route != excludeRoute)
        .toList(growable: false);
  }

  static AdminPanelEntry? entryForRoute(String? route) {
    final normalized = _normalizeRoute(route);
    for (final group in orderedGroups) {
      for (final item in group.items) {
        if (_normalizeRoute(item.route) == normalized) return item;
      }
    }
    return null;
  }

  static String _normalizeRoute(String? route) {
    final value = (route ?? '').trim();
    if (value.isEmpty) return '';
    final noQuery = value.split('?').first;
    if (noQuery.length > 1 && noQuery.endsWith('/')) {
      return noQuery.substring(0, noQuery.length - 1);
    }
    return noQuery;
  }

  static AdminGovernedSystem? governedSystemByName(String value) {
    final key = value.trim();
    for (final system in governedSystems) {
      if (system.systemKey.name == key) return system;
    }
    return null;
  }

  static const _publicRoutes = <String>[
    '/admin/home-management',
    '/admin/unit-surfaces-management',
    '/admin/system-surfaces-management',
    '/admin/unit-pages-execution',
    '/admin/shared-content',
    '/admin/public-pages/about',
    '/admin/public-pages/minister',
    '/admin/public-pages/vision-mission',
    '/admin/public-pages/structure',
    '/admin/public-pages/former-ministers',
    '/admin/public-pages/projects',
    '/admin/public-pages/contact',
    '/admin/public-pages/privacy',
    '/admin/public-pages/terms',
    '/admin/public-pages/sitemap',
    '/admin/public-pages',
  ];

  static const _surfacesServicesRoutes = <String>[
    '/admin/surfaces-services',
    '/admin/public-pages/services',
    '/admin/public-pages/eservices',
    '/admin/complaints',
    '/admin/zakat',
    '/admin/prayer-times',
    '/admin/quran',
    '/admin/surfaces-services/quick-links',
    '/admin/surfaces-services/important-links',
    '/admin/surfaces-services/quick-services',
    '/admin/surfaces-services/statistics',
    '/admin/surfaces-services/eservices-portal',
    '/admin/surfaces-services/request-queue',
    '/admin/surfaces-services/feature-highlights',
    '/admin/surfaces-services/mini-map-teaser',
    '/admin/surfaces-services/legal-references',
  ];

  static const _mediaRoutes = <String>[
    '/admin/media-center',
    '/admin/hero-slider',
    '/admin/breaking-news',
    '/admin/activities-management',
    '/admin/friday-sermons',
  ];

  static const _platformRoutes = <String>[
    '/admin/users',
    '/admin/org-units',
    '/admin/unit-operations',
    '/admin/profile',
    '/admin/settings',
    '/admin/platform/system-registry',
    '/admin/platform/technical-services',
    '/admin/platform/design-system',
    '/admin/platform/design-system/visual-identity-bridge',
    '/admin/platform/design-system/awqaf-pilot',
    '/admin/platform/design-system/rollout-evidence',
    '/admin/platform/design-system/closure-review',
    '/admin/platform/design-system/wave-2-scope',
    '/admin/platform/design-system/wave-2-media-inventory',
    '/admin/reports',
    '/admin/document-intelligence',
    '/admin-data',
  ];

  static const _systemRoutes = <String>[
    '/admin/systems',
    '/admin/waqf-lands',
    '/admin/awqaf-system/waqf-assets-intake',
    '/admin/platform/cross-system-contracts',
    '/admin/mosques',
    '/admin/cases',
    '/admin/tasks',
    '/admin/documents',
  ];

  static const _governanceRoutes = <String>[
    '/admin/reports',
    '/admin/usage-guide',
    '/admin/document-intelligence/review-queue',
    '/admin/platform/cross-system-contracts',
  ];

  static const _developerRoutes = <String>['/admin/developer'];
}
