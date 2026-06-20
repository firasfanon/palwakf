import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';
import 'package:waqf/core/unit/pwf_canonical_unit_identity.dart';

import '../models/header_settings.dart';

/// Header/tool-bar read/write repository.
///
/// Public reads are direct owner-schema reads from
/// `core.v_unit_public_surface_profile_runtime_v1`. Unit pages remain strict:
/// they never borrow the ministry header identity when their profile is absent.
class HeaderRepository {
  HeaderRepository(this._supabase);

  final SupabaseClient _supabase;

  static const String _unitSurfaceProfileReadSurface =
      PwfDatabaseOwnerSurfaces.unitPublicSurfaceProfileRuntimeV1;

  Future<HeaderSettings> fetchHeaderSettings() async {
    final settings = await _fetchByInternalSlug('home');
    return settings ?? _runtimeDefaultHeaderSettings();
  }

  Future<HeaderSettings> fetchHeaderSettingsForScopes({
    String? unitId,
    String? homeUnitId,
    bool strictUnitOnly = false,
  }) async {
    final normalizedUnitId = unitId?.trim() ?? '';
    if (normalizedUnitId.isNotEmpty) {
      final settings = await _fetchByUnitId(normalizedUnitId);
      if (settings != null) return settings;
    }

    if (strictUnitOnly) {
      return _runtimeUnitPlaceholderHeaderSettings();
    }

    final normalizedHomeId = homeUnitId?.trim() ?? '';
    if (normalizedHomeId.isNotEmpty) {
      final settings = await _fetchByUnitId(normalizedHomeId);
      if (settings != null) return settings;
    }
    return fetchHeaderSettings();
  }

  Future<HeaderSettings?> _fetchByUnitId(String unitId) async {
    try {
      final response = await PwfDatabaseOwnerSurfaces.fromOwnerSchema(
        _supabase,
        _unitSurfaceProfileReadSurface,
      ).select().eq('org_unit_id', unitId).maybeSingle();
      return response == null ? null : _map(response);
    } on PostgrestException catch (error) {
      if (_isOptionalSingletonMiss(error)) return null;
      rethrow;
    }
  }

  Future<HeaderSettings?> _fetchByInternalSlug(String slug) async {
    try {
      final response = await PwfDatabaseOwnerSurfaces.fromOwnerSchema(
        _supabase,
        _unitSurfaceProfileReadSurface,
      ).select().eq('internal_slug', slug).maybeSingle();
      return response == null ? null : _map(response);
    } on PostgrestException catch (error) {
      if (_isOptionalSingletonMiss(error)) return null;
      rethrow;
    }
  }

  HeaderSettings _map(dynamic row) =>
      _fromRuntimeProfile(Map<String, dynamic>.from(row as Map));

  HeaderSettings _fromRuntimeProfile(Map<String, dynamic> row) {
    final source = row['source_payload'] is Map
        ? Map<String, dynamic>.from(row['source_payload'] as Map)
        : const <String, dynamic>{};
    String text(String key, {String fallback = ''}) {
      final direct = (row[key] ?? '').toString().trim();
      if (direct.isNotEmpty && direct != 'null') return direct;
      final nested = (source[key] ?? '').toString().trim();
      if (nested.isNotEmpty && nested != 'null') return nested;
      return fallback;
    }
    bool boolValue(String key, {bool fallback = true}) {
      final value = row[key] ?? source[key];
      if (value is bool) return value;
      return value?.toString().toLowerCase() == 'false' ? false : fallback;
    }

    final identity = PwfCanonicalUnitIdentity.fromRuntimeProfileRow(row);
    final now = DateTime.now();
    final unitName = text('unit_name_ar', fallback: 'بوابة الوحدة العامة');
    final isHome = text('internal_slug') == 'home';
    return HeaderSettings(
      id: identity.canonicalOrgUnitId.isEmpty
          ? 'runtime-profile-header'
          : identity.canonicalOrgUnitId,
      logoUrl: text('logo_url'),
      logoAlt: unitName,
      siteName: unitName,
      siteTagline: isHome ? 'دولة فلسطين' : 'بوابة الوحدة العامة',
      faviconUrl: null,
      showBreakingNews: boolValue('show_breaking_news'),
      breakingNewsText: text('breaking_news_text').isEmpty
          ? null
          : text('breaking_news_text'),
      createdAt: now,
      updatedAt: now,
    );
  }

  HeaderSettings _runtimeUnitPlaceholderHeaderSettings() {
    final now = DateTime.now();
    return HeaderSettings(
      id: 'runtime-unit-placeholder-header',
      logoUrl: '',
      logoAlt: 'بيانات الوحدة غير منشورة',
      siteName: 'بيانات الوحدة غير منشورة',
      siteTagline: 'بوابة الوحدة العامة',
      faviconUrl: null,
      showBreakingNews: false,
      breakingNewsText: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  HeaderSettings _runtimeDefaultHeaderSettings() {
    final now = DateTime.now();
    return HeaderSettings(
      id: 'runtime-default-header',
      logoUrl: '',
      logoAlt: 'وزارة الأوقاف والشؤون الدينية',
      siteName: 'وزارة الأوقاف والشؤون الدينية',
      siteTagline: 'دولة فلسطين',
      faviconUrl: null,
      showBreakingNews: true,
      breakingNewsText: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  bool _isOptionalSingletonMiss(PostgrestException error) {
    final message = error.message.toLowerCase();
    final code = (error.code ?? '').toLowerCase();
    return code == 'pgrst116' ||
        message.contains('json object requested') ||
        message.contains('multiple') ||
        message.contains('no rows') ||
        message.contains('not acceptable');
  }

  Future<void> updateHeaderSettings(HeaderSettings settings) async {
    final home = await _fetchByInternalSlug('home');
    final homeId = home?.id.trim() ?? '';
    if (homeId.isEmpty) {
      throw StateError('تعذر تحديد نطاق الوزارة لحفظ إعدادات الشريط العلوي.');
    }
    await _supabase.schema('core').rpc(
      'rpc_unit_public_profile_write_v1',
      params: <String, dynamic>{
        'p_org_unit_id': homeId,
        'p_payload': <String, dynamic>{
          'official_name_ar': settings.siteName,
          'logo_url': settings.logoUrl,
          'show_breaking_news': settings.showBreakingNews,
          'breaking_news_text': settings.breakingNewsText,
        },
      },
    );
  }
}
