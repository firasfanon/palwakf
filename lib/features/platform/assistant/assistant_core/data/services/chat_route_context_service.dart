import 'package:flutter/foundation.dart';

@immutable
class ChatRouteContext {
  const ChatRouteContext({
    required this.route,
    required this.systemKey,
    required this.pageLabelAr,
    required this.pageLabelEn,
    required this.unitSlug,
    required this.queryParameters,
    this.waqfAssetId,
    this.nationalAssetCode,
  });

  final String route;
  final String systemKey;
  final String pageLabelAr;
  final String pageLabelEn;
  final String unitSlug;
  final Map<String, String> queryParameters;
  final String? waqfAssetId;
  final String? nationalAssetCode;
}

class ChatRouteContextService {
  const ChatRouteContextService._();

  static const Set<String> _reservedPublicRoots = <String>{
    'home',
    'news',
    'announcements',
    'activities',
    'services',
    'eservices',
    'social-services',
    'complaints',
    'zakat',
    'prayer-times',
    'quran',
    'mosques',
    'projects',
    'about',
    'minister',
    'vision-mission',
    'structure',
    'former-ministers',
    'contact',
    'search',
    'under-construction',
    'switch',
    'login',
    'not-found',
    'chat',
  };

  static const List<String> _assetIdKeys = <String>[
    'waqf_asset_id',
    'waqfassetid',
    'asset_id',
    'assetid',
    'waqf_asset',
    'waqfasset',
  ];

  static const List<String> _assetCodeKeys = <String>[
    'national_asset_code',
    'nationalassetcode',
    'asset_code',
    'assetcode',
    'national_code',
    'nationalcode',
  ];

  static ChatRouteContext resolve(
    String? rawRoute, {
    String fallbackUnitSlug = 'home',
  }) {
    final route = _normalizedRoute(rawRoute);
    final uri = Uri.parse(route);
    final path = uri.path.toLowerCase();
    final segments = uri.pathSegments
        .map((e) => e.toLowerCase())
        .toList(growable: false);
    final queryParameters = <String, String>{
      for (final entry in uri.queryParameters.entries)
        entry.key.toLowerCase(): entry.value,
    };
    final unitSlug = _unitSlugFromSegments(
      segments,
      queryParameters: queryParameters,
      fallbackUnitSlug: fallbackUnitSlug,
    );
    final waqfAssetId =
        _firstQueryValue(queryParameters, _assetIdKeys) ??
        _extractAssetIdFromPath(segments);
    final nationalAssetCode =
        _firstQueryValue(queryParameters, _assetCodeKeys) ??
        _extractNationalAssetCodeFromPath(segments);

    if (path.startsWith('/mustakshif')) {
      return ChatRouteContext(
        route: route,
        systemKey: 'mustakshif',
        pageLabelAr: _pageLabelForMustakshif(path),
        pageLabelEn: _pageLabelForMustakshif(path, arabic: false),
        unitSlug: unitSlug,
        queryParameters: Map<String, String>.unmodifiable(queryParameters),
        waqfAssetId: waqfAssetId,
        nationalAssetCode: nationalAssetCode,
      );
    }

    if (path.startsWith('/admin/cases') || path.startsWith('/cases')) {
      return ChatRouteContext(
        route: route,
        systemKey: 'waqf_cases_system',
        pageLabelAr: 'القضايا الوقفية',
        pageLabelEn: 'Waqf cases',
        unitSlug: unitSlug,
        queryParameters: Map<String, String>.unmodifiable(queryParameters),
        waqfAssetId: waqfAssetId,
        nationalAssetCode: nationalAssetCode,
      );
    }

    if (path.startsWith('/admin/billing') || path.startsWith('/billing')) {
      return ChatRouteContext(
        route: route,
        systemKey: 'billing_system',
        pageLabelAr: 'الفوترة',
        pageLabelEn: 'Billing',
        unitSlug: unitSlug,
        queryParameters: Map<String, String>.unmodifiable(queryParameters),
        waqfAssetId: waqfAssetId,
        nationalAssetCode: nationalAssetCode,
      );
    }

    if (path.startsWith('/admin/tasks') || path.startsWith('/tasks')) {
      return ChatRouteContext(
        route: route,
        systemKey: 'tasks_system',
        pageLabelAr: 'المهام',
        pageLabelEn: 'Tasks',
        unitSlug: unitSlug,
        queryParameters: Map<String, String>.unmodifiable(queryParameters),
        waqfAssetId: waqfAssetId,
        nationalAssetCode: nationalAssetCode,
      );
    }

    if (path.startsWith('/admin')) {
      return ChatRouteContext(
        route: route,
        systemKey: 'awqaf_system',
        pageLabelAr: _pageLabelForAdmin(path),
        pageLabelEn: _pageLabelForAdmin(path, arabic: false),
        unitSlug: unitSlug,
        queryParameters: Map<String, String>.unmodifiable(queryParameters),
        waqfAssetId: waqfAssetId,
        nationalAssetCode: nationalAssetCode,
      );
    }

    return ChatRouteContext(
      route: route,
      systemKey: 'public_site',
      pageLabelAr: _pageLabelForPublic(path),
      pageLabelEn: _pageLabelForPublic(path, arabic: false),
      unitSlug: unitSlug,
      queryParameters: Map<String, String>.unmodifiable(queryParameters),
      waqfAssetId: waqfAssetId,
      nationalAssetCode: nationalAssetCode,
    );
  }

  static String _normalizedRoute(String? rawRoute) {
    final value = (rawRoute ?? '/home').trim();
    if (value.isEmpty) return '/home';
    return value.startsWith('/') ? value : '/$value';
  }

  static String _unitSlugFromSegments(
    List<String> segments, {
    required Map<String, String> queryParameters,
    required String fallbackUnitSlug,
  }) {
    final queryUnit =
        queryParameters['unit'] ??
        queryParameters['unitslug'] ??
        queryParameters['slug'];
    if (queryUnit != null && queryUnit.trim().isNotEmpty)
      return queryUnit.trim();
    if (segments.isEmpty) return fallbackUnitSlug;
    final first = segments.first;
    if (first == 'admin' || _reservedPublicRoots.contains(first)) {
      return fallbackUnitSlug;
    }
    return first;
  }

  static String? _firstQueryValue(
    Map<String, String> queryParameters,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = queryParameters[key];
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  static final RegExp _uuidLikeRegExp = RegExp(
    r'^[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}$',
  );

  static final RegExp _nationalAssetCodeRegExp = RegExp(
    r'^(PW|PWF)[\-_]?[A-Z0-9]{1,6}[\-_]?[A-Z0-9]{1,8}[\-_]?[A-Z0-9]{1,12}([\-_]?[A-Z0-9]{1,8})?$',
    caseSensitive: false,
  );

  static const Set<String> _assetPathMarkers = <String>{
    'waqf-asset',
    'waqf_asset',
    'asset',
    'assets',
    'property',
    'properties',
    'waqf-property',
    'waqf_property',
    'property-detail',
    'property-detail-screen',
    'property-form',
  };

  static String? _extractAssetIdFromPath(List<String> segments) {
    for (var i = 0; i < segments.length; i++) {
      final current = segments[i];
      if (_assetPathMarkers.contains(current) && i + 1 < segments.length) {
        final candidate = segments[i + 1].trim();
        if (_uuidLikeRegExp.hasMatch(candidate)) return candidate;
      }
      if (_uuidLikeRegExp.hasMatch(current.trim())) {
        return current.trim();
      }
    }
    return null;
  }

  static String? _extractNationalAssetCodeFromPath(List<String> segments) {
    for (var i = 0; i < segments.length; i++) {
      final current = segments[i].trim();
      if (_nationalAssetCodeRegExp.hasMatch(current)) {
        return current.toUpperCase();
      }
      if (_assetPathMarkers.contains(current) && i + 1 < segments.length) {
        final candidate = segments[i + 1].trim();
        if (_nationalAssetCodeRegExp.hasMatch(candidate)) {
          return candidate.toUpperCase();
        }
      }
    }
    return null;
  }

  static String _pageLabelForAdmin(String path, {bool arabic = true}) {
    if (path.contains('/dashboard'))
      return arabic ? 'لوحة التحكم' : 'Dashboard';
    if (path.contains('/home-management'))
      return arabic ? 'إدارة الصفحة الرئيسية' : 'Home management';
    if (path.contains('/media-center'))
      return arabic ? 'المركز الإعلامي' : 'Media center';
    if (path.contains('/hero-slider'))
      return arabic ? 'إدارة الهيرو' : 'Hero slider';
    if (path.contains('/breaking-news'))
      return arabic ? 'إدارة الأخبار العاجلة' : 'Breaking news';
    if (path.contains('/activities'))
      return arabic ? 'إدارة الأنشطة' : 'Activities management';
    if (path.contains('/users'))
      return arabic ? 'إدارة المستخدمين' : 'Users management';
    if (path.contains('/mosques'))
      return arabic ? 'إدارة المساجد' : 'Mosques management';
    if (path.contains('/org-units'))
      return arabic ? 'الوحدات التنظيمية' : 'Org units';
    if (path.contains('/assistant'))
      return arabic ? 'المساعد الداخلي' : 'Internal assistant';
    if (path.contains('/chatbot'))
      return arabic ? 'معاينة شات الجمهور' : 'Public chatbot preview';
    return arabic ? 'لوحة الإدارة' : 'Platform admin';
  }

  static String _pageLabelForMustakshif(String path, {bool arabic = true}) {
    if (path.contains('/history'))
      return arabic ? 'مرحلة التاريخ' : 'History phase';
    if (path.contains('/map')) return arabic ? 'الخريطة الوقفية' : 'Waqf map';
    if (path.contains('/layers')) return arabic ? 'الطبقات' : 'Layers';
    return arabic ? 'مستكشف الوقف' : 'Mustakshif';
  }

  static String _pageLabelForPublic(String path, {bool arabic = true}) {
    if (path == '/chat' || path.endsWith('/chat'))
      return arabic ? 'اسألنا' : 'Ask us';
    if (path.contains('/services')) return arabic ? 'الخدمات' : 'Services';
    if (path.contains('/eservices'))
      return arabic ? 'الخدمات الإلكترونية' : 'E-services';
    if (path.contains('/complaints'))
      return arabic ? 'الشكاوى والمقترحات' : 'Complaints';
    if (path.contains('/contact')) return arabic ? 'اتصل بنا' : 'Contact us';
    if (path.contains('/about'))
      return arabic ? 'عن الوزارة' : 'About the ministry';
    if (path.contains('/news')) return arabic ? 'الأخبار' : 'News';
    if (path.contains('/announcements'))
      return arabic ? 'الإعلانات' : 'Announcements';
    if (path.contains('/activities')) return arabic ? 'الأنشطة' : 'Activities';
    return arabic ? 'الموقع العام' : 'Public site';
  }
}
