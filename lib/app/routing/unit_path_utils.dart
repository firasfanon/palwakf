class UnitPathUtils {
  UnitPathUtils._();

  static const _reservedFirstSegments = <String>{
    // Platform/auth/admin/system roots.
    'admin',
    'admin-data',
    'billing',
    'cases',
    'documents',
    'forbidden',
    'lands',
    'login',
    'mustakshif',
    'systems',
    'tasks',

    // Public global routes that must never be interpreted as unit slugs.
    'about',
    'activities',
    'announcements',
    'awareness-campaigns',
    'chat',
    'complaints',
    'complaints-system',
    'contact',
    'donate',
    'donations',
    'e-services',
    'eservices',
    'events',
    'friday-sermon',
    'legal-references',
    'gallery',
    'media',
    'media-center',
    'minister-speech',
    'mosques',
    'news',
    'not-found',
    'prayer-times',
    'press-releases',
    'previous-ministers',
    'privacy',
    'properties',
    'projects',
    'quran',
    'request-service',
    'sanctities-observatory',
    'search',
    'services',
    'sitemap',
    'social-posts',
    'social-services',
    'structure',
    'switch',
    'terms',
    'track-request',
    'under-construction',
    'vision',
    'vision-mission',
    'zakat',
    'zakat-system',
  };

  static bool isReservedFirstSegment(String segment) {
    return _reservedFirstSegments.contains(segment.trim().toLowerCase());
  }

  /// Returns the unit slug from a path, defaulting to 'home' if none is found.
  /// Examples:
  /// - '/bth/news' -> 'bth'
  /// - '/home' -> 'home'
  /// - '/news' -> 'home' (reserved)
  static String resolveUnitSlugFromPath(String path) {
    final clean = path.split('?').first;
    final parts = clean.split('/').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'home';
    final first = parts.first.toLowerCase();
    if (isReservedFirstSegment(first)) return 'home';
    return first;
  }
}
