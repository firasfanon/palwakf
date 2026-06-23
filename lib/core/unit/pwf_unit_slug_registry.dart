class PwfUnitSlugRegistry {
  const PwfUnitSlugRegistry._();

  static const Map<String, String> _legacyAliases = <String, String>{
    'الوزارة': 'home',
    'ministry': 'home',
    'وزارة-الأوقاف': 'home',
  };

  static String internalSlugFor(String slug) {
    final normalized = slug.trim().toLowerCase();
    if (normalized.isEmpty) return 'home';
    return _legacyAliases[normalized] ?? normalized;
  }

  static String publicSlugFor(String slug) {
    final internal = internalSlugFor(slug);
    if (internal == 'home') return '';
    return internal;
  }

  static List<String> compatibilityAliasesFor(String slug) {
    final internal = internalSlugFor(slug);
    return _legacyAliases.entries
        .where((e) => e.value == internal)
        .map((e) => e.key)
        .toList(growable: false);
  }

  static String publicBasePathFor(String slug) {
    final pub = publicSlugFor(slug);
    if (pub.isEmpty) return '/';
    return '/$pub';
  }

  static String? redirectLegacyPath(String location, {String? query}) {
    final segments = Uri.parse(location).pathSegments;
    if (segments.isEmpty) return null;
    final first = segments.first.trim().toLowerCase();
    final alias = _legacyAliases[first];
    if (alias == null) return null;
    final remaining = segments.skip(1).join('/');
    final basePath = alias == 'home' ? '' : '/$alias';
    final path = remaining.isEmpty ? basePath : '$basePath/$remaining';
    final q = (query ?? '').trim();
    return q.isEmpty ? (path.isEmpty ? '/' : path) : '$path?$q';
  }
}
