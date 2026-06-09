/// PalWakf - Home Sections Catalog (DB-controlled)
///
/// Single source of truth for homepage/system-home controllable sections.
///
/// IMPORTANT
/// - Keys MUST match `public.homepage_sections.section_name`.
/// - TopBar + MainNav are pinned to the top (non-draggable).
/// - Footer is pinned to the bottom (always last, non-draggable).

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

  // Content
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
    'pwf_quick_links_grid',
    titleAr: 'روابط سريعة',
    titleEn: 'Quick Links',
  ),
  PwfHomeSectionDef(
    'pwf_quick_services',
    titleAr: 'خدمات سريعة',
    titleEn: 'Quick Services',
  ),
  PwfHomeSectionDef(
    'pwf_eservices_portal',
    titleAr: 'بوابة الخدمات الإلكترونية',
    titleEn: 'E‑Services Portal',
  ),
  PwfHomeSectionDef(
    'pwf_stats_grid',
    titleAr: 'إحصائيات',
    titleEn: 'Statistics',
  ),
  PwfHomeSectionDef(
    'pwf_announcements',
    titleAr: 'إعلانات',
    titleEn: 'Announcements',
  ),
  PwfHomeSectionDef(
    'pwf_minister_word',
    titleAr: 'كلمة الوزير',
    titleEn: 'Minister Word',
  ),
  PwfHomeSectionDef(
    'pwf_prayer_times',
    titleAr: 'مواقيت الصلاة',
    titleEn: 'Prayer Times',
  ),
  PwfHomeSectionDef(
    'pwf_important_links',
    titleAr: 'روابط مهمة',
    titleEn: 'Important Links',
  ),
  PwfHomeSectionDef(
    'pwf_news_tabs',
    titleAr: 'الأخبار (تبويبات)',
    titleEn: 'News Tabs',
  ),
  PwfHomeSectionDef('pwf_news', titleAr: 'الأخبار', titleEn: 'News'),
  // Media gallery options (choose one strategy in DB)
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
  PwfHomeSectionDef(
    'pwf_feature_highlights',
    titleAr: 'بطاقات مميّزة',
    titleEn: 'Feature Highlights',
  ),
  PwfHomeSectionDef(
    'pwf_mini_map_teaser',
    titleAr: 'مُصغّر الخريطة',
    titleEn: 'Mini Map Teaser',
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
