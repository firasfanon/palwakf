/// Home New (HTML-exact) Widget Tree Contract
/// Generated from palwak_homepage_extraction_map.json on 2026-01-02
///
/// NOTE: This is a naming/structure contract only. It intentionally contains no UI styling.
class PwfHomeComponentKeys {
  static const List<String> all = <String>[
    'ThemeToggle',
    'ScrollToTop',
    'TopBar',
    'MainHeader',
    'MainNav',
    'HeroSliderSection',
    'StatsSection',
    'EServicesPortalSection',
    'MinisterWordSection',
    'QuickServicesSection',
    'NewsSection',
    'MediaGallerySection',
    'AnnouncementsSection',
    'ActivitiesSection',
    'FridaySermonsSection',
    'ImportantLinksSection',
    'PrayerTimesWidget',
    'FooterSection',
    'LoginModal',
  ];
}

class PwfLocalStorageKeys {
  static const theme = 'pwf_theme';
  static const fontSize = 'pwf_fontSize';
  static const highContrast = 'pwf_highContrast';
  static const readMode = 'pwf_readMode';
}

class PwfRoutes {
  static const underConstruction = '/under-construction';
  static const home = '/home';
  static const unitHome = '/:unitSlug';
  static const newsList = '/:unitSlug/news';
  static const announcementsList = '/:unitSlug/announcements';
  static const activitiesList = '/:unitSlug/activities';
  static const gallery = '/:unitSlug/gallery';
  static const sermons = '/:unitSlug/sermons';
  static const prayerTimes = '/:unitSlug/prayer-times';
}

class PwfHomeLimits {
  static const newsSide = 4;
  static const announcements = 4;
  static const activities = 4;
  static const sermons = 3;
  static const gallery = 12;
}
