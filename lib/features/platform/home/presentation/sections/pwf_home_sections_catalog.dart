// PalWakf - Home Sections Catalog (DB-controlled)
//
// Single source of truth for homepage/system-home controllable sections.
//
// IMPORTANT
// - Keys MUST match `public.homepage_sections.section_name`.
// - TopBar + MainNav are pinned to the top (non-draggable).
// - Footer is pinned to the bottom (always last, non-draggable).

enum PwfHomeSectionPin { none, top, bottom }

enum PwfHomeSectionFamilyMode { allowMany, preferOne, preferUnifiedIfPresent }

enum PwfHomeSectionSourceKind {
  shell,
  sovereignContent,
  mediaCenter,
  platformServices,
  platformNavigation,
  religiousContent,
  gisContext,
  externalService,
  staticContract,
}

class PwfHomeSectionDef {
  final String key;
  final String titleAr;
  final String titleEn;
  final PwfHomeSectionPin pin;
  final String familyKey;
  final int familyPriority;
  final String? rendererKey;
  final PwfHomeSectionSourceKind sourceKind;
  final bool canRenderEmptyState;
  final bool adminVisible;
  final bool runtimeVisible;
  final String ownerAr;
  final String contractNoteAr;

  const PwfHomeSectionDef(
    this.key, {
    required this.titleAr,
    required this.titleEn,
    this.pin = PwfHomeSectionPin.none,
    this.familyKey = 'other',
    this.familyPriority = 100,
    this.rendererKey,
    this.sourceKind = PwfHomeSectionSourceKind.staticContract,
    this.canRenderEmptyState = false,
    this.adminVisible = true,
    this.runtimeVisible = true,
    this.ownerAr = 'الصفحة الرئيسية',
    this.contractNoteAr = 'قسم قابل للرسم ضمن عقد الصفحة الرئيسية.',
  });

  bool get isPinned => pin != PwfHomeSectionPin.none;
  String get effectiveRendererKey => rendererKey ?? key;
  bool get isRenderable => runtimeVisible && effectiveRendererKey.trim().isNotEmpty;
}


/// Official catalog list (used by admin manager + preview).
///
/// NOTE: This list does NOT force runtime rendering.
/// Runtime rendering MUST follow DB (active + display_order).
const List<PwfHomeSectionDef> kPwfHomeSections = <PwfHomeSectionDef>[
  // Pinned header
  PwfHomeSectionDef(
    'pwf_top_bar',
    familyKey: 'shell',
    familyPriority: 10,
    sourceKind: PwfHomeSectionSourceKind.shell,
    ownerAr: 'Shell المنصة',
    contractNoteAr: 'مكوّن بنيوي مثبت؛ لا يُعامل كمحتوى قابل للتكرار.',
    titleAr: 'الشريط العلوي',
    titleEn: 'Top Bar',
    pin: PwfHomeSectionPin.top,
  ),
  PwfHomeSectionDef(
    'pwf_main_nav',
    familyKey: 'shell',
    familyPriority: 20,
    sourceKind: PwfHomeSectionSourceKind.shell,
    ownerAr: 'Shell المنصة',
    contractNoteAr: 'مكوّن تنقل مثبت؛ لا يُرسم كقسم محتوى مكرر.',
    titleAr: 'شريط التنقل الرئيسي',
    titleEn: 'Main Navigation',
    pin: PwfHomeSectionPin.top,
  ),

  // Sovereign landing sequence (adopted)
  PwfHomeSectionDef(
    'pwf_hero_slider',
    familyKey: 'hero',
    familyPriority: 10,
    sourceKind: PwfHomeSectionSourceKind.sovereignContent,
    canRenderEmptyState: true,
    ownerAr: 'المحتوى السيادي',
    titleAr: 'السلايدر الرئيسي',
    titleEn: 'Hero Slider',
  ),
  PwfHomeSectionDef(
    'pwf_breaking_news_marquee',
    familyKey: 'sovereign_alerts',
    familyPriority: 10,
    sourceKind: PwfHomeSectionSourceKind.mediaCenter,
    canRenderEmptyState: true,
    ownerAr: 'الأخبار العاجلة',
    contractNoteAr: 'الأخبار العاجلة لها قسم مستقل ولا تُكرر داخل الأخبار العامة.',
    titleAr: 'شريط الأخبار العاجلة',
    titleEn: 'Breaking News Marquee',
  ),
  PwfHomeSectionDef(
    'pwf_minister_word',
    familyKey: 'sovereign_identity',
    familyPriority: 10,
    titleAr: 'كلمة الوزير',
    titleEn: 'Minister Word',
  ),
  PwfHomeSectionDef(
    'pwf_stats_grid',
    familyKey: 'metrics',
    familyPriority: 10,
    titleAr: 'إحصائيات',
    titleEn: 'Statistics',
  ),
  PwfHomeSectionDef(
    'pwf_feature_highlights',
    familyKey: 'featured_access',
    familyPriority: 10,
    titleAr: 'بطاقات مميّزة',
    titleEn: 'Feature Highlights',
  ),

  // Sovereign/public service block
  PwfHomeSectionDef(
    'pwf_eservices_portal',
    familyKey: 'services_family',
    familyPriority: 10,
    sourceKind: PwfHomeSectionSourceKind.platformServices,
    canRenderEmptyState: true,
    ownerAr: 'مركز الخدمات',
    titleAr: 'بوابة الخدمات الإلكترونية',
    titleEn: 'E‑Services Portal',
  ),
  PwfHomeSectionDef(
    'pwf_public_services_catalog',
    familyKey: 'services_catalog_family',
    familyPriority: 10,
    sourceKind: PwfHomeSectionSourceKind.platformServices,
    canRenderEmptyState: true,
    ownerAr: 'كتالوج الخدمات',
    titleAr: 'كتالوج خدمات الجمهور المعتمد',
    titleEn: 'Approved Public Services Catalog',
  ),
  PwfHomeSectionDef(
    'pwf_quick_services',
    familyKey: 'services_family',
    familyPriority: 20,
    titleAr: 'خدمات سريعة',
    titleEn: 'Quick Services',
  ),

  // Editorial/public information block
  PwfHomeSectionDef(
    'pwf_news_tabs',
    familyKey: 'news_family',
    familyPriority: 10,
    sourceKind: PwfHomeSectionSourceKind.mediaCenter,
    canRenderEmptyState: true,
    ownerAr: 'الأخبار',
    contractNoteAr: 'الأخبار العامة لا تحتوي الأخبار العاجلة ولا الفعاليات ولا عناصر المعرض.',
    titleAr: 'الأخبار (تبويبات)',
    titleEn: 'News Tabs',
  ),
  PwfHomeSectionDef(
    'pwf_news',
    familyKey: 'news_family',
    familyPriority: 20,
    sourceKind: PwfHomeSectionSourceKind.mediaCenter,
    canRenderEmptyState: true,
    ownerAr: 'الأخبار',
    contractNoteAr: 'قسم بديل للأخبار؛ لا يعمل بالتوازي مع تبويبات الأخبار.',
    titleAr: 'الأخبار',
    titleEn: 'News',
  ),
  PwfHomeSectionDef(
    'pwf_announcements',
    familyKey: 'announcements_family',
    familyPriority: 10,
    sourceKind: PwfHomeSectionSourceKind.mediaCenter,
    canRenderEmptyState: true,
    ownerAr: 'الإعلانات',
    titleAr: 'إعلانات',
    titleEn: 'Announcements',
  ),
  PwfHomeSectionDef(
    'pwf_activities',
    familyKey: 'activities_events_family',
    familyPriority: 10,
    sourceKind: PwfHomeSectionSourceKind.mediaCenter,
    canRenderEmptyState: true,
    ownerAr: 'الأنشطة والفعاليات',
    contractNoteAr: 'الفعاليات تبقى ضمن عائلة الأنشطة/الفعاليات ولا تُكرر في المعرض أو الأخبار.',
    titleAr: 'الأنشطة والفعاليات',
    titleEn: 'Activities and Events',
  ),
  PwfHomeSectionDef(
    'pwf_friday_sermons',
    familyKey: 'sermons_family',
    familyPriority: 10,
    sourceKind: PwfHomeSectionSourceKind.religiousContent,
    canRenderEmptyState: true,
    ownerAr: 'المحتوى الديني',
    titleAr: 'خطب الجمعة',
    titleEn: 'Friday Sermons',
  ),

  // Media/context block
  PwfHomeSectionDef(
    'pwf_media_gallery',
    familyKey: 'media_gallery_family',
    familyPriority: 5,
    sourceKind: PwfHomeSectionSourceKind.mediaCenter,
    canRenderEmptyState: true,
    ownerAr: 'المعرض الإعلامي',
    contractNoteAr: 'المعرض الإعلامي يحتوي الصور والفيديوهات فقط ولا يحتوي الفعاليات.',
    titleAr: 'المعرض الإعلامي (موحّد)',
    titleEn: 'Media Gallery (Unified)',
  ),
  PwfHomeSectionDef(
    'pwf_media_gallery_images',
    familyKey: 'media_gallery_family',
    familyPriority: 20,
    sourceKind: PwfHomeSectionSourceKind.mediaCenter,
    canRenderEmptyState: true,
    ownerAr: 'المعرض الإعلامي / الصور',
    contractNoteAr: 'قسم صور فقط؛ لا يحتوي فيديوهات أو فعاليات.',
    titleAr: 'معرض الصور',
    titleEn: 'Images Gallery',
  ),
  PwfHomeSectionDef(
    'pwf_media_gallery_videos',
    familyKey: 'media_gallery_family',
    familyPriority: 30,
    sourceKind: PwfHomeSectionSourceKind.mediaCenter,
    canRenderEmptyState: true,
    ownerAr: 'المعرض الإعلامي / الفيديو',
    contractNoteAr: 'قسم فيديو فقط؛ لا يحتوي صورًا أو فعاليات.',
    titleAr: 'معرض الفيديو',
    titleEn: 'Videos Gallery',
  ),

  // Platform centers completion block
  PwfHomeSectionDef(
    'pwf_media_center_highlights',
    familyKey: 'media_center_family',
    familyPriority: 10,
    titleAr: 'مختارات المركز الإعلامي',
    titleEn: 'Media Center Highlights',
  ),
  PwfHomeSectionDef(
    'pwf_services_center_highlights',
    familyKey: 'services_center_family',
    familyPriority: 10,
    titleAr: 'مختارات مركز الخدمات',
    titleEn: 'Services Center Highlights',
  ),
  PwfHomeSectionDef(
    'pwf_social_posts_section',
    familyKey: 'social_content_family',
    familyPriority: 10,
    titleAr: 'الاجتماعيات',
    titleEn: 'Social Posts',
  ),
  PwfHomeSectionDef(
    'pwf_press_releases_section',
    familyKey: 'official_content_family',
    familyPriority: 10,
    titleAr: 'البيانات الصحفية',
    titleEn: 'Press Releases',
  ),
  PwfHomeSectionDef(
    'pwf_official_statements_section',
    familyKey: 'official_content_family',
    familyPriority: 20,
    titleAr: 'التصريحات الرسمية',
    titleEn: 'Official Statements',
  ),
  PwfHomeSectionDef(
    'pwf_awareness_campaigns_section',
    familyKey: 'awareness_family',
    familyPriority: 10,
    titleAr: 'الحملات التوعوية',
    titleEn: 'Awareness Campaigns',
  ),
  PwfHomeSectionDef(
    'pwf_sanctities_observatory_section',
    familyKey: 'sanctities_family',
    familyPriority: 10,
    titleAr: 'مرصد حماية المقدسات',
    titleEn: 'Sanctities Observatory',
  ),
  PwfHomeSectionDef(
    'pwf_legal_references_section',
    familyKey: 'legal_references_family',
    familyPriority: 10,
    titleAr: 'الأنظمة والقوانين والتعليمات',
    titleEn: 'Legal References',
  ),
  PwfHomeSectionDef(
    'pwf_events_section',
    familyKey: 'activities_events_family',
    familyPriority: 20,
    sourceKind: PwfHomeSectionSourceKind.mediaCenter,
    canRenderEmptyState: true,
    ownerAr: 'الفعاليات',
    contractNoteAr: 'ممثل أضيق للفعاليات؛ لا يعمل بالتوازي مع قسم الأنشطة والفعاليات.',
    titleAr: 'الفعاليات',
    titleEn: 'Events',
  ),

  // Utility block near footer (adopted)
  PwfHomeSectionDef(
    'pwf_important_links',
    familyKey: 'links_family',
    familyPriority: 10,
    sourceKind: PwfHomeSectionSourceKind.platformNavigation,
    ownerAr: 'التنقل والروابط',
    titleAr: 'روابط مهمة',
    titleEn: 'Important Links',
  ),
  PwfHomeSectionDef(
    'pwf_quick_links_grid',
    familyKey: 'links_family',
    familyPriority: 20,
    sourceKind: PwfHomeSectionSourceKind.platformNavigation,
    ownerAr: 'التنقل والروابط',
    titleAr: 'روابط سريعة',
    titleEn: 'Quick Links',
  ),
  PwfHomeSectionDef(
    'pwf_mini_map_teaser',
    familyKey: 'map_teaser_family',
    familyPriority: 10,
    sourceKind: PwfHomeSectionSourceKind.gisContext,
    ownerAr: 'المستكشف / GIS',
    titleAr: 'مُصغّر الخريطة',
    titleEn: 'Mini Map Teaser',
  ),
  PwfHomeSectionDef(
    'pwf_prayer_times',
    familyKey: 'prayer_times_family',
    familyPriority: 10,
    sourceKind: PwfHomeSectionSourceKind.externalService,
    canRenderEmptyState: true,
    ownerAr: 'الخدمات الدينية',
    titleAr: 'مواقيت الصلاة',
    titleEn: 'Prayer Times',
  ),

  // Pinned footer
  PwfHomeSectionDef(
    'pwf_footer',
    familyKey: 'shell',
    familyPriority: 90,
    sourceKind: PwfHomeSectionSourceKind.shell,
    ownerAr: 'Shell المنصة',
    contractNoteAr: 'مكوّن بنيوي مثبت في آخر الصفحة.',
    titleAr: 'التذييل',
    titleEn: 'Footer',
    pin: PwfHomeSectionPin.bottom,
  ),
];

List<String> pwfHomeSectionKeys() =>
    kPwfHomeSections.map((e) => e.key).toList();

PwfHomeSectionDef? findPwfHomeSection(String key) {
  for (final s in kPwfHomeSections) {
    if (s.key == key) return s;
  }
  return null;
}




const Map<PwfHomeSectionSourceKind, String> kPwfHomeSectionSourceKindLabelsAr =
    <PwfHomeSectionSourceKind, String>{
  PwfHomeSectionSourceKind.shell: 'قالب المنصة / Shell',
  PwfHomeSectionSourceKind.sovereignContent: 'محتوى سيادي',
  PwfHomeSectionSourceKind.mediaCenter: 'المركز الإعلامي',
  PwfHomeSectionSourceKind.platformServices: 'الخدمات العامة',
  PwfHomeSectionSourceKind.platformNavigation: 'التنقل والروابط',
  PwfHomeSectionSourceKind.religiousContent: 'المحتوى الديني',
  PwfHomeSectionSourceKind.gisContext: 'السياق المكاني / GIS',
  PwfHomeSectionSourceKind.externalService: 'خدمة خارجية محكومة',
  PwfHomeSectionSourceKind.staticContract: 'عقد ثابت',
};

PwfHomeSectionSourceKind pwfHomeSectionSourceKind(String rawKey) {
  final key = canonicalPwfHomeSectionKey(rawKey);
  return findPwfHomeSection(key)?.sourceKind ??
      PwfHomeSectionSourceKind.staticContract;
}

String pwfHomeSectionSourceKindLabelAr(String rawKey) {
  return kPwfHomeSectionSourceKindLabelsAr[pwfHomeSectionSourceKind(rawKey)] ??
      'مصدر غير مصنف';
}

String pwfHomeSectionRendererKey(String rawKey) {
  final key = canonicalPwfHomeSectionKey(rawKey);
  return findPwfHomeSection(key)?.effectiveRendererKey ?? key;
}

bool pwfHomeSectionCanRenderEmptyState(String rawKey) {
  final key = canonicalPwfHomeSectionKey(rawKey);
  return findPwfHomeSection(key)?.canRenderEmptyState ?? false;
}

bool pwfHomeSectionIsRuntimeVisible(String rawKey) {
  final key = canonicalPwfHomeSectionKey(rawKey);
  return findPwfHomeSection(key)?.runtimeVisible ?? false;
}

bool pwfHomeSectionIsAdminVisible(String rawKey) {
  final key = canonicalPwfHomeSectionKey(rawKey);
  return findPwfHomeSection(key)?.adminVisible ?? false;
}

String pwfHomeSectionOwnerAr(String rawKey) {
  final key = canonicalPwfHomeSectionKey(rawKey);
  return findPwfHomeSection(key)?.ownerAr ?? 'غير مصنف';
}

String pwfHomeSectionContractNoteAr(String rawKey) {
  final key = canonicalPwfHomeSectionKey(rawKey);
  return findPwfHomeSection(key)?.contractNoteAr ??
      'لا توجد ملاحظة عقدية لهذا القسم.';
}

const Map<String, String> kPwfHomeSectionFamilyLabelsAr = <String, String>{
  'shell': 'البنية / القالب العام',
  'hero': 'الواجهة السيادية',
  'sovereign_alerts': 'التنبيهات السيادية',
  'sovereign_identity': 'الهوية والسيادة',
  'metrics': 'الإحصاءات والمؤشرات',
  'featured_access': 'بوابات الوصول المميزة',
  'services_family': 'الخدمات الإلكترونية السريعة',
  'services_catalog_family': 'كتالوج الخدمات المعتمد',
  'news_family': 'الأخبار',
  'announcements_family': 'الإعلانات',
  'activities_events_family': 'الأنشطة والفعاليات',
  'sermons_family': 'خطب الجمعة',
  'media_gallery_family': 'المعرض الإعلامي',
  'media_center_family': 'مختارات المركز الإعلامي',
  'services_center_family': 'مختارات مركز الخدمات',
  'social_content_family': 'الاجتماعيات',
  'official_content_family': 'المحتوى الرسمي',
  'awareness_family': 'الحملات التوعوية',
  'sanctities_family': 'حماية المقدسات',
  'legal_references_family': 'المراجع القانونية',
  'links_family': 'الروابط',
  'map_teaser_family': 'الخرائط والموقع',
  'prayer_times_family': 'مواقيت الصلاة',
  'other': 'أقسام أخرى',
};

const Map<String, PwfHomeSectionFamilyMode> kPwfHomeSectionFamilyModes =
    <String, PwfHomeSectionFamilyMode>{
  // These pairs are close substitutes in runtime and should not both render.
  'news_family': PwfHomeSectionFamilyMode.preferOne,
  'services_family': PwfHomeSectionFamilyMode.preferOne,
  'links_family': PwfHomeSectionFamilyMode.preferOne,

  // Runtime should render one media gallery entry only. Split image/video rows are
  // fallback administrative rows, not parallel homepage sections.
  'media_gallery_family': PwfHomeSectionFamilyMode.preferOne,

  // Activities and standalone events are close substitutes on the homepage.
  // Keep the unified activities/events section and hide the narrower events block.
  'activities_events_family': PwfHomeSectionFamilyMode.preferOne,
};

String pwfHomeSectionFamilyKey(String rawKey) {
  final key = canonicalPwfHomeSectionKey(rawKey);
  return findPwfHomeSection(key)?.familyKey ?? 'other';
}

String pwfHomeSectionFamilyLabelAr(String rawKey) {
  final familyKey = pwfHomeSectionFamilyKey(rawKey);
  return kPwfHomeSectionFamilyLabelsAr[familyKey] ?? 'أقسام أخرى';
}

PwfHomeSectionFamilyMode pwfHomeSectionFamilyMode(String rawKey) {
  final familyKey = pwfHomeSectionFamilyKey(rawKey);
  return kPwfHomeSectionFamilyModes[familyKey] ??
      PwfHomeSectionFamilyMode.allowMany;
}

int pwfHomeSectionFamilyPriority(String rawKey) {
  final key = canonicalPwfHomeSectionKey(rawKey);
  return findPwfHomeSection(key)?.familyPriority ?? 100;
}

String pwfHomeSectionFamilyModeLabelAr(String rawKey) {
  switch (pwfHomeSectionFamilyMode(rawKey)) {
    case PwfHomeSectionFamilyMode.allowMany:
      return 'يسمح بتعدد الأقسام';
    case PwfHomeSectionFamilyMode.preferOne:
      return 'يعرض قسماً واحداً من العائلة';
    case PwfHomeSectionFamilyMode.preferUnifiedIfPresent:
      return 'الموحّد يسبق الأقسام الجزئية';
  }
}

bool pwfShouldSuppressHomeSectionForRuntime({
  required String key,
  required Iterable<String> activeKeys,
}) {
  final canonicalKey = canonicalPwfHomeSectionKey(key);
  final family = pwfHomeSectionFamilyKey(canonicalKey);
  final mode = kPwfHomeSectionFamilyModes[family] ??
      PwfHomeSectionFamilyMode.allowMany;
  if (mode == PwfHomeSectionFamilyMode.allowMany) return false;

  final familyKeys = activeKeys
      .map(canonicalPwfHomeSectionKey)
      .where((candidate) => pwfHomeSectionFamilyKey(candidate) == family)
      .toSet();
  if (familyKeys.length <= 1) return false;

  if (mode == PwfHomeSectionFamilyMode.preferUnifiedIfPresent &&
      family == 'media_gallery_family' &&
      familyKeys.contains('pwf_media_gallery')) {
    return canonicalKey != 'pwf_media_gallery';
  }

  if (mode == PwfHomeSectionFamilyMode.preferOne) {
    final preferred = familyKeys.reduce((a, b) {
      final pa = pwfHomeSectionFamilyPriority(a);
      final pb = pwfHomeSectionFamilyPriority(b);
      if (pa != pb) return pa < pb ? a : b;
      return a.compareTo(b) <= 0 ? a : b;
    });
    return canonicalKey != preferred;
  }

  return false;
}

int pwfTopPinnedCount() =>
    kPwfHomeSections.where((e) => e.pin == PwfHomeSectionPin.top).length;

int pwfBottomPinnedCount() =>
    kPwfHomeSections.where((e) => e.pin == PwfHomeSectionPin.bottom).length;

const Map<String, String> kPwfHomeSectionLegacyAliases = <String, String>{
  'minister': 'pwf_minister_word',
  'statistics': 'pwf_stats_grid',
  'breaking_news': 'pwf_breaking_news_marquee',
  'announcements': 'pwf_announcements',
  'services': 'pwf_quick_services',
  'service_catalog': 'pwf_public_services_catalog',
  'services_catalog': 'pwf_public_services_catalog',
  'public_services_catalog': 'pwf_public_services_catalog',
  'media_center_highlights': 'pwf_media_center_highlights',
  'services_center_highlights': 'pwf_services_center_highlights',
  'social_posts': 'pwf_social_posts_section',
  'press_releases': 'pwf_press_releases_section',
  'official_statements': 'pwf_official_statements_section',
  'awareness_campaigns': 'pwf_awareness_campaigns_section',
  'sanctities_observatory': 'pwf_sanctities_observatory_section',
  'legal_references': 'pwf_legal_references_section',
  'events': 'pwf_events_section',
  'events_section': 'pwf_events_section',
  'home_events': 'pwf_events_section',
  'activities': 'pwf_activities',
  'activity': 'pwf_activities',
  'home_activities': 'pwf_activities',
  'gallery': 'pwf_media_gallery',
  'media_gallery': 'pwf_media_gallery',
  'photo_gallery': 'pwf_media_gallery_images',
  'photos_gallery': 'pwf_media_gallery_images',
  'image_gallery': 'pwf_media_gallery_images',
  'images_gallery': 'pwf_media_gallery_images',
  'video_gallery': 'pwf_media_gallery_videos',
  'videos_gallery': 'pwf_media_gallery_videos',
  'pwf_services_catalog': 'pwf_public_services_catalog',
  'news': 'pwf_news_tabs',
  'top_bar': 'pwf_top_bar',
  'pwf_topbar': 'pwf_top_bar',
  'main_nav': 'pwf_main_nav',
  'pwf_mainnav': 'pwf_main_nav',
  'footer': 'pwf_footer',
};

String normalizePwfHomeSectionKey(String raw) {
  final lower = raw.trim().toLowerCase();
  final a = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  return a.replaceAll(RegExp(r'_+'), '_');
}

String canonicalPwfHomeSectionKey(String raw) {
  final normalized = normalizePwfHomeSectionKey(raw);
  return kPwfHomeSectionLegacyAliases[normalized] ?? normalized;
}

bool isOfficialPwfHomeSectionKey(String raw) {
  final key = canonicalPwfHomeSectionKey(raw);
  for (final item in kPwfHomeSections) {
    if (item.key == key) return true;
  }
  return false;
}
