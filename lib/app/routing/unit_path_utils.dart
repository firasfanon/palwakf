class UnitPathUtils {
  UnitPathUtils._();

    static const _reservedFirstSegments = <String>{
    'admin',
    'login',
    'forbidden',
    'switch',
    'systems',
    'news',
    'announcements',
    'activities',
    'projects',
    'eservices',
    'vision',
    'minister-speech',
    'previous-ministers',
    'friday-sermon',
    'contact',
    'search',
    'not-found',
  };

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
    if (_reservedFirstSegments.contains(first)) return 'home';
    return first;
  }
}
