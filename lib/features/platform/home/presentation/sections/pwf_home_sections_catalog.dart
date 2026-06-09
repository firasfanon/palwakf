// PalWakf - Home Sections Catalog (DB-controlled)
//
// Single source of truth for homepage/system-home controllable sections.
//
// IMPORTANT
// - Keys MUST match `public.homepage_sections.section_name`.
// - TopBar + MainNav are pinned to the top (non-draggable).
// - Footer is pinned to the bottom (always last, non-draggable).

enum PwfHomeSectionPin { none, top, bottom }

class PwfHomeSectionDef {
  final String key;
  final String titleAr;
  final String titleEn;
  final PwfHomeSectionPin pin;

  const PwfHomeSectionDef(
    this.key, {
    required this.titleAr,
    required this.titleEn,
    this.pin = PwfHomeSectionPin.none,
  });

  bool get isPinned => pin != PwfHomeSectionPin.none;
}

/// Official catalog list (used by admin manager + preview).
///
/// NOTE: This list does NOT force runtime rendering.
/// Runtime rendering MUST follow DB (active + display_order).
const List<PwfHomeSectionDef> kPwfHomeSections = <PwfHomeSectionDef>[
  // Pinned header
  PwfHomeSectionDef(
    'pwf_top_bar',
    titleAr: 'الشريط العلوي',
    titleEn: 'Top Bar',
    pin: PwfHomeSectionPin.top,
  ),
  PwfHomeSectionDef(
    'pwf_main_nav',
    titleAr: 'شريط التنقل الرئيسي',
    titleEn: 'Main Navigation',
    pin: PwfHomeSectionPin.top,
  ),

  // Sovereign landing sequence (adopted)
  PwfHomeSectionDef(
    'pwf_hero_slider',
    titleAr: 'السلايدر الرئيسي',
    titleEn: 'Hero Slider',
  ),
  PwfHomeSectionDef(
    'pwf_breaking_news_marquee',
    titleAr: 'شريط الأخبار العاجلة',
    titleEn: 'Breaking News Marquee',
  ),
  PwfHomeSectionDef(
    'pwf_minister_word',
    titleAr: 'كلمة الوزير',
    titleEn: 'Minister Word',
  ),
  PwfHomeSectionDef(
    'pwf_stats_grid',
    titleAr: 'إحصائيات',
    titleEn: 'Statistics',
  ),
  PwfHomeSectionDef(
    'pwf_feature_highlights',
    titleAr: 'بطاقات مميّزة',
    titleEn: 'Feature Highlights',
  ),

  // Sovereign/public service block
  PwfHomeSectionDef(
    'pwf_eservices_portal',
    titleAr: 'بوابة الخدمات الإلكترونية',
    titleEn: 'E‑Services Portal',
  ),
  PwfHomeSectionDef(
    'pwf_public_services_catalog',
    titleAr: 'كتالوج خدمات الجمهور المعتمد',
    titleEn: 'Approved Public Services Catalog',
  ),
  PwfHomeSectionDef(
    'pwf_quick_services',
    titleAr: 'خدمات سريعة',
    titleEn: 'Quick Services',
  ),

  // Editorial/public information block
  PwfHomeSectionDef(
    'pwf_news_tabs',
    titleAr: 'الأخبار (تبويبات)',
    titleEn: 'News Tabs',
  ),
  PwfHomeSectionDef('pwf_news', titleAr: 'الأخبار', titleEn: 'News'),
  PwfHomeSectionDef(
    'pwf_announcements',
    titleAr: 'إعلانات',
    titleEn: 'Announcements',
  ),
  PwfHomeSectionDef(
    'pwf_activities',
    titleAr: 'الأنشطة',
    titleEn: 'Activities',
  ),
  PwfHomeSectionDef(
    'pwf_friday_sermons',
    titleAr: 'خطب الجمعة',
    titleEn: 'Friday Sermons',
  ),

  // Media/context block
  PwfHomeSectionDef(
    'pwf_media_gallery',
    titleAr: 'المعرض الإعلامي (موحّد)',
    titleEn: 'Media Gallery (Unified)',
  ),
  PwfHomeSectionDef(
    'pwf_media_gallery_images',
    titleAr: 'معرض الصور',
    titleEn: 'Images Gallery',
  ),
  PwfHomeSectionDef(
    'pwf_media_gallery_videos',
    titleAr: 'معرض الفيديو',
    titleEn: 'Videos Gallery',
  ),

  // Platform centers completion block
  PwfHomeSectionDef(
    'pwf_media_center_highlights',
    titleAr: 'مختارات المركز الإعلامي',
    titleEn: 'Media Center Highlights',
  ),
  PwfHomeSectionDef(
    'pwf_services_center_highlights',
    titleAr: 'مختارات مركز الخدمات',
    titleEn: 'Services Center Highlights',
  ),
  PwfHomeSectionDef(
    'pwf_social_posts_section',
    titleAr: 'الاجتماعيات',
    titleEn: 'Social Posts',
  ),
  PwfHomeSectionDef(
    'pwf_press_releases_section',
    titleAr: 'البيانات الصحفية',
    titleEn: 'Press Releases',
  ),
  PwfHomeSectionDef(
    'pwf_official_statements_section',
    titleAr: 'التصريحات الرسمية',
    titleEn: 'Official Statements',
  ),
  PwfHomeSectionDef(
    'pwf_awareness_campaigns_section',
    titleAr: 'الحملات التوعوية',
    titleEn: 'Awareness Campaigns',
  ),
  PwfHomeSectionDef(
    'pwf_sanctities_observatory_section',
    titleAr: 'مرصد حماية المقدسات',
    titleEn: 'Sanctities Observatory',
  ),
  PwfHomeSectionDef(
    'pwf_legal_references_section',
    titleAr: 'الأنظمة والقوانين والتعليمات',
    titleEn: 'Legal References',
  ),
  PwfHomeSectionDef(
    'pwf_events_section',
    titleAr: 'الفعاليات',
    titleEn: 'Events',
  ),

  // Utility block near footer (adopted)
  PwfHomeSectionDef(
    'pwf_important_links',
    titleAr: 'روابط مهمة',
    titleEn: 'Important Links',
  ),
  PwfHomeSectionDef(
    'pwf_quick_links_grid',
    titleAr: 'روابط سريعة',
    titleEn: 'Quick Links',
  ),
  PwfHomeSectionDef(
    'pwf_mini_map_teaser',
    titleAr: 'مُصغّر الخريطة',
    titleEn: 'Mini Map Teaser',
  ),
  PwfHomeSectionDef(
    'pwf_prayer_times',
    titleAr: 'مواقيت الصلاة',
    titleEn: 'Prayer Times',
  ),

  // Pinned footer
  PwfHomeSectionDef(
    'pwf_footer',
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
