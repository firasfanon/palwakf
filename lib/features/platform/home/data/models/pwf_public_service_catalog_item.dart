class PwfPublicServiceCatalogItem {
  const PwfPublicServiceCatalogItem({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.link,
    required this.isActive,
    required this.orderIndex,
  });

  final String id;
  final String title;
  final String iconKey;
  final String link;
  final bool isActive;
  final int orderIndex;

  factory PwfPublicServiceCatalogItem.fromJson(Map<String, dynamic> json) {
    final rawPayload = _rawPayloadFrom(json['raw_payload']);

    return PwfPublicServiceCatalogItem(
      id: _stringFrom(json, rawPayload, const [
        'id',
        'service_entry_key',
        'home_entry_key',
        'route_entry_key',
        'service_key',
        'home_service_key',
        'service_id',
        'code',
        'slug',
      ]),
      title: _stringFrom(json, rawPayload, const [
        'title',
        'title_ar',
        'name_ar',
        'service_name_ar',
        'name',
        'label_ar',
      ]),
      iconKey: _stringFrom(json, rawPayload, const [
        'icon',
        'icon_key',
        'iconKey',
      ]),
      link: _stringFrom(json, rawPayload, const [
        'link',
        'route_path',
        'path',
        'url',
      ]),
      isActive: _boolFrom(json, rawPayload, const [
        'is_active',
        'active',
        'enabled',
      ], fallback: true),
      orderIndex: _intFrom(json, rawPayload, const [
        'order_index',
        'display_order',
        'sort_order',
        'order',
      ]),
    );
  }

  static Map<String, dynamic> _rawPayloadFrom(Object? value) {
    if (value is! Map) return const <String, dynamic>{};
    return value.map<String, dynamic>(
      (key, dynamic payloadValue) => MapEntry(key.toString(), payloadValue),
    );
  }

  static String _stringFrom(
    Map<String, dynamic> json,
    Map<String, dynamic> rawPayload,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    for (final key in keys) {
      final value = rawPayload[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  static bool _boolFrom(
    Map<String, dynamic> json,
    Map<String, dynamic> rawPayload,
    List<String> keys, {
    required bool fallback,
  }) {
    for (final key in keys) {
      if (json.containsKey(key)) return _parseBool(json[key], fallback);
    }
    for (final key in keys) {
      if (rawPayload.containsKey(key)) {
        return _parseBool(rawPayload[key], fallback);
      }
    }
    return fallback;
  }

  static bool _parseBool(Object? value, bool fallback) {
    if (value is bool) return value;
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return fallback;
    return const {
      'true',
      '1',
      'yes',
      'published',
      'active',
      'enabled',
    }.contains(normalized);
  }

  static int _intFrom(
    Map<String, dynamic> json,
    Map<String, dynamic> rawPayload,
    List<String> keys,
  ) {
    for (final key in keys) {
      final parsed = int.tryParse((json[key] ?? '').toString());
      if (parsed != null) return parsed;
    }
    for (final key in keys) {
      final parsed = int.tryParse((rawPayload[key] ?? '').toString());
      if (parsed != null) return parsed;
    }
    return 0;
  }

  String get normalizedLink => link.trim();

  bool get hasUsableLink => normalizedLink.isNotEmpty && !isRoutePattern;

  bool get isRoutePattern => normalizedLink.contains('/:');

  bool get isExternalLink {
    final normalized = normalizedLink.toLowerCase();
    return normalized.startsWith('http://') ||
        normalized.startsWith('https://');
  }

  bool get isInternalRoute => normalizedLink.startsWith('/');

  bool get isWaqfPropertyLike {
    final haystack = '${title.trim()} ${normalizedLink.toLowerCase()}'
        .toLowerCase();
    return haystack.contains('عقار') ||
        haystack.contains('عقارات') ||
        haystack.contains('أصل وقفي') ||
        haystack.contains('أصول وقفية') ||
        haystack.contains('waqf_asset') ||
        haystack.contains('waqf-assets') ||
        haystack.contains('property') ||
        haystack.contains('properties');
  }

  bool get isPublicCatalogSafe {
    return isActive &&
        title.isNotEmpty &&
        hasUsableLink &&
        !isWaqfPropertyLike &&
        (isExternalLink || isInternalRoute);
  }

  String get routeForGoRouter {
    final target = normalizedLink;
    if (target.isEmpty) return '/home/services';
    final route = target.startsWith('/') ? target : '/$target';
    return _canonicalInternalRoute(route);
  }

  static String _canonicalInternalRoute(String route) {
    final clean = route.trim();
    switch (clean) {
      case '/services':
      case '/service':
      case '/home/service':
        return '/home/services';
      case '/eservices':
      case '/e-services':
      case '/home/e-service':
      case '/home/e-services':
        return '/home/eservices';
      default:
        return clean;
    }
  }
}
