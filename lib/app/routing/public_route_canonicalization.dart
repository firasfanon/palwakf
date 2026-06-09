/// Canonical public-route contract for PalWakf.
///
/// Public runtime pages must live under `/home/*`. Root-level public paths are
/// preserved only as legacy aliases so old links, search results, and previous
/// navigation cards do not break. This class is deliberately pure Dart: it does
/// not touch Supabase, RBAC, media ownership, or runtime data.
class PwfPublicRouteCanonicalization {
  const PwfPublicRouteCanonicalization._();

  static const String canonicalNamespace = '/home';
  static const String legacyAliasMode = 'redirect-only';
  static const String publicServicesRouteAliasRepairPatchKey =
      'public-services-route-alias-canonicalization-repair-2026-05-30';

  static const String publicServicesRootCutoverPatchKey =
      'public-services-runtime-source-root-cutover-2026-05-30';

  static const Map<String, String> rootAliases = <String, String>{
    '/news': '/home/news',
    '/news/detail': '/home/news',
    '/announcements': '/home/announcements',
    '/activities': '/home/activities',
    '/events': '/home/events',
    '/services': '/home/services',
    '/service': '/home/services',
    '/eservices': '/home/eservices',
    '/e-services': '/home/eservices',
    '/social-services': '/home/social-services',
    '/media': '/home/gallery',
    '/gallery': '/home/gallery',
    '/media-center': '/home/media-center',
    '/social-posts': '/home/social-posts',
    '/press-releases': '/home/press-releases',
    '/official-statements': '/home/official-statements',
    '/awareness-campaigns': '/home/awareness-campaigns',
    '/legal-references': '/home/legal-references',
    '/sanctities-observatory': '/home/sanctities-observatory',
    '/mosques': '/home/mosques',
    '/projects': '/home/projects',
    '/about': '/home/about',
    '/minister': '/home/minister',
    '/vision-mission': '/home/vision-mission',
    '/structure': '/home/structure',
    '/former-ministers': '/home/former-ministers',
    '/contact': '/home/contact',
    '/privacy': '/home/privacy',
    '/terms': '/home/terms',
    '/sitemap': '/home/sitemap',
    '/search': '/home/search',
    '/chat': '/home/chat',
    '/public-chat': '/home/chat',
    '/ask': '/home/chat',
    '/friday-sermon': '/home/friday-sermons',
    '/complaints': '/home/complaints',
    '/services/complaints': '/home/complaints',
    '/services/request': '/home/services/request',
    '/services/track': '/home/services/track',
    '/complaints-system': '/home/complaints',
    '/zakat': '/home/zakat',
    '/zakat-system': '/home/zakat',
    '/prayer-times': '/home/prayer-times',
    '/prayer-times-system': '/home/prayer-times',
    '/services/prayer-times': '/home/prayer-times',
    '/quran': '/home/quran',
    '/quran-system': '/home/quran',
    '/donations': '/home/zakat',
    '/donate': '/home/zakat',
    '/services/donations': '/home/zakat',
    '/request-service': '/home/services/request',
    '/service-request': '/home/services/request',
    '/track-request': '/home/services/track',
    '/request-tracking': '/home/services/track',
    '/service-request-tracking': '/home/services/track',
    // Defensive alias for the common missing-c typo observed during UAT.
    '/service-request-traking': '/home/services/track',
  };

  static const Map<String, String> canonicalAliases = <String, String>{
    '/home/media': '/home/gallery',
    '/home/friday-sermon': '/home/friday-sermons',
    '/home/service': '/home/services',
    '/home/e-service': '/home/eservices',
    '/home/e-services': '/home/eservices',
    '/home/request-service': '/home/services/request',
    '/home/service-request': '/home/services/request',
    '/home/track-request': '/home/services/track',
    '/home/request-tracking': '/home/services/track',
    '/home/service-request-tracking': '/home/services/track',
    // Defensive alias for the common missing-c typo observed during UAT.
    '/home/service-request-traking': '/home/services/track',
  };

  static String? redirectFor(String location, {String query = ''}) {
    final path = _normalizePath(location);
    final rootTarget = rootAliases[path];
    if (rootTarget != null) return _withQuery(rootTarget, query);

    final canonicalTarget = canonicalAliases[path];
    if (canonicalTarget != null) return _withQuery(canonicalTarget, query);

    final rootDetailTarget = _rootDetailRedirect(path);
    if (rootDetailTarget != null) return _withQuery(rootDetailTarget, query);

    return null;
  }

  static String _normalizePath(String location) {
    final clean = location.split('?').first.trim();
    if (clean.isEmpty) return '/';
    if (clean.length > 1 && clean.endsWith('/')) {
      return clean.substring(0, clean.length - 1);
    }
    return clean;
  }

  static String _withQuery(String path, String query) {
    if (query.trim().isEmpty) return path;
    return '$path?$query';
  }

  static String? _rootDetailRedirect(String path) {
    final detailFamilies = <String, String>{
      '/events': '/home/events',
      '/social-posts': '/home/social-posts',
      '/press-releases': '/home/press-releases',
      '/official-statements': '/home/official-statements',
      '/awareness-campaigns': '/home/awareness-campaigns',
      '/legal-references': '/home/legal-references',
      '/sanctities-observatory': '/home/sanctities-observatory',
    };

    for (final entry in detailFamilies.entries) {
      final prefix = '${entry.key}/';
      if (path.startsWith(prefix) && path.length > prefix.length) {
        return '${entry.value}/${path.substring(prefix.length)}';
      }
    }
    return null;
  }
}
