// lib/data/repositories/header_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/header_settings.dart';

class HeaderRepository {
  HeaderRepository(this._supabase);

  final SupabaseClient _supabase;

  // Phase 1 public-schema remediation: runtime reads use the wrapper.
  // Admin writes remain on preserved legacy public table pending owner-write RPCs.
  static const String _headerSettingsReadSurface =
      'v_platform_header_settings_compat_v1';
  static const String _headerSettingsLegacyWriteTable = 'header_settings';
  static const String _globalUnitId = '11111111-1111-1111-1111-111111111111';

  Future<HeaderSettings> fetchHeaderSettings() async {
    try {
      final response = await _supabase
          .from(_headerSettingsReadSurface)
          .select()
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (response != null) {
        return HeaderSettings.fromJson(Map<String, dynamic>.from(response));
      }
    } on PostgrestException catch (error) {
      if (!_isOptionalSingletonMiss(error)) rethrow;
    }

    return _runtimeDefaultHeaderSettings();
  }

  Future<HeaderSettings> fetchHeaderSettingsForScopes({
    String? unitId,
    String? homeUnitId,
  }) async {
    try {
      for (final candidate in <String?>[
        unitId,
        if (homeUnitId != unitId) homeUnitId,
        _globalUnitId,
      ]) {
        final scoped = await _fetchByUnitId(candidate);
        if (scoped != null) return scoped;
      }

      final global = await _fetchGlobalNull();
      if (global != null) return global;
    } on PostgrestException {
      // fall through to legacy single-row behavior
    }

    return fetchHeaderSettings();
  }

  Future<HeaderSettings?> _fetchByUnitId(String? unitId) async {
    if (unitId == null || unitId.isEmpty) return null;
    try {
      final response = await _supabase
          .from(_headerSettingsReadSurface)
          .select()
          .eq('unit_id', unitId)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (response == null) return null;
      return HeaderSettings.fromJson(Map<String, dynamic>.from(response));
    } on PostgrestException catch (error) {
      if (_isOptionalSingletonMiss(error)) return null;
      rethrow;
    }
  }

  Future<HeaderSettings?> _fetchGlobalNull() async {
    try {
      final response = await _supabase
          .from(_headerSettingsReadSurface)
          .select()
          .isFilter('unit_id', null)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (response == null) return null;
      return HeaderSettings.fromJson(Map<String, dynamic>.from(response));
    } on PostgrestException catch (error) {
      if (_isOptionalSingletonMiss(error)) return null;
      rethrow;
    }
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
    await _supabase
        .from(_headerSettingsLegacyWriteTable)
        .update({
          'logo_url': settings.logoUrl,
          'logo_alt': settings.logoAlt,
          'site_name': settings.siteName,
          'site_tagline': settings.siteTagline,
          'favicon_url': settings.faviconUrl,
          'show_breaking_news': settings.showBreakingNews,
          'breaking_news_text': settings.breakingNewsText,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', settings.id);
  }
}
