// lib/data/repositories/footer_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/footer_settings.dart';

class FooterRepository {
  FooterRepository(this._supabase);

  final SupabaseClient _supabase;
  static const String _globalUnitId = '11111111-1111-1111-1111-111111111111';

  // Phase 1 public-schema remediation:
  // Runtime reads use the public compatibility wrapper. Admin writes remain on
  // the preserved legacy public table until owner-write RPCs are approved.
  static const String _footerSettingsReadSurface =
      'v_platform_footer_settings_compat_v1';
  static const String _footerSettingsLegacyWriteTable = 'footer_settings';

  Future<FooterSettings> fetchFooterSettings() async {
    try {
      final response = await _supabase
          .from(_footerSettingsReadSurface)
          .select()
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (response != null) return _hydrateFooter(response);
    } on PostgrestException catch (error) {
      if (!_isOptionalSingletonMiss(error)) rethrow;
    }

    return _runtimeDefaultFooterSettings();
  }

  Future<FooterSettings> fetchFooterSettingsForScopes({
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

    return fetchFooterSettings();
  }

  Future<FooterSettings> fetchFooterSettingsForEdit({
    String? unitId,
    String? homeUnitId,
  }) async {
    final normalizedUnitId = unitId?.trim().isEmpty ?? true
        ? null
        : unitId!.trim();

    final exact = normalizedUnitId == null
        ? await _fetchGlobalNull()
        : await _fetchByUnitId(normalizedUnitId);
    if (exact != null) return exact;

    final effective = await fetchFooterSettingsForScopes(
      unitId: normalizedUnitId,
      homeUnitId: homeUnitId,
    );

    return effective.copyWith(
      id: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> saveFooterSettingsForUnit(
    FooterSettings settings, {
    String? unitId,
  }) async {
    final normalizedUnitId = unitId?.trim().isEmpty ?? true
        ? null
        : unitId!.trim();
    final userId = _supabase.auth.currentUser?.id;
    final payload = {
      'ministry_logo_url': settings.ministryLogoUrl,
      'ministry_name': settings.ministryName,
      'ministry_subtitle': settings.ministrySubtitle,
      'ministry_description': settings.ministryDescription,
      'contact_phone': settings.contactPhone,
      'contact_fax': settings.contactFax,
      'contact_email': settings.contactEmail,
      'contact_address': settings.contactAddress,
      'working_days': settings.workingDays,
      'working_hours': settings.workingHours,
      'facebook_url': settings.facebookUrl,
      'twitter_url': settings.twitterUrl,
      'instagram_url': settings.instagramUrl,
      'youtube_url': settings.youtubeUrl,
      'linkedin_url': settings.linkedinUrl,
      'quick_links': settings.quickLinks.map((e) => e.toJson()).toList(),
      'services_links': settings.servicesLinks.map((e) => e.toJson()).toList(),
      'bottom_links': settings.bottomLinks.map((e) => e.toJson()).toList(),
      'partners': settings.partners.map((e) => e.toJson()).toList(),
      'show_partners': settings.showPartners,
      'copyright_text': settings.copyrightText,
      'developer_credit': settings.developerCredit,
      'show_developer_credit': settings.showDeveloperCredit,
      'show_phone': settings.showPhone,
      'show_email': settings.showEmail,
      'show_address': settings.showAddress,
      'show_working_hours': settings.showWorkingHours,
      'updated_at': DateTime.now().toIso8601String(),
      'updated_by': userId,
      'unit_id': normalizedUnitId,
    };

    final existing = normalizedUnitId == null
        ? await _supabase
              .from(_footerSettingsReadSurface)
              .select('id')
              .isFilter('unit_id', null)
              .maybeSingle()
        : await _supabase
              .from(_footerSettingsReadSurface)
              .select('id')
              .eq('unit_id', normalizedUnitId)
              .maybeSingle();

    final existingId = (existing?['id'] ?? '').toString();
    if (settings.id.trim().isNotEmpty) {
      await _supabase
          .from(_footerSettingsLegacyWriteTable)
          .update(payload)
          .eq('id', settings.id);
    } else if (existingId.isNotEmpty) {
      await _supabase
          .from(_footerSettingsLegacyWriteTable)
          .update(payload)
          .eq('id', existingId);
    } else {
      await _supabase.from(_footerSettingsLegacyWriteTable).insert(payload);
    }
  }

  Future<FooterSettings?> _fetchByUnitId(String? unitId) async {
    if (unitId == null || unitId.isEmpty) return null;
    try {
      final response = await _supabase
          .from(_footerSettingsReadSurface)
          .select()
          .eq('unit_id', unitId)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (response == null) return null;
      return _hydrateFooter(response);
    } on PostgrestException catch (error) {
      if (_isOptionalSingletonMiss(error)) return null;
      rethrow;
    }
  }

  Future<FooterSettings?> _fetchGlobalNull() async {
    try {
      final response = await _supabase
          .from(_footerSettingsReadSurface)
          .select()
          .isFilter('unit_id', null)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (response == null) return null;
      return _hydrateFooter(response);
    } on PostgrestException catch (error) {
      if (_isOptionalSingletonMiss(error)) return null;
      rethrow;
    }
  }

  FooterSettings _hydrateFooter(dynamic response) {
    final data = Map<String, dynamic>.from(response as Map);

    data['quick_links'] = _normalizeFooterLinks(data['quick_links']);
    data['services_links'] = _normalizeFooterLinks(data['services_links']);
    data['bottom_links'] = _normalizeFooterLinks(data['bottom_links']);
    data['partners'] = _normalizePartners(data['partners']);

    return FooterSettings.fromJson(data);
  }

  List<Map<String, dynamic>> _normalizeFooterLinks(dynamic raw) {
    if (raw is! List) return const <Map<String, dynamic>>[];
    return raw
        .map<Map<String, dynamic>>((e) {
          if (e is FooterLink) return e.toJson();
          if (e is Map<String, dynamic>) return Map<String, dynamic>.from(e);
          if (e is Map) return Map<String, dynamic>.from(e);
          return <String, dynamic>{};
        })
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _normalizePartners(dynamic raw) {
    if (raw is! List) return const <Map<String, dynamic>>[];
    return raw
        .map<Map<String, dynamic>>((e) {
          if (e is FooterPartner) return e.toJson();
          if (e is Map<String, dynamic>) return Map<String, dynamic>.from(e);
          if (e is Map) return Map<String, dynamic>.from(e);
          return <String, dynamic>{};
        })
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  FooterSettings _runtimeDefaultFooterSettings() {
    final now = DateTime.now();
    return FooterSettings(
      id: 'runtime-default-footer',
      ministryLogoUrl: null,
      ministryName: 'وزارة الأوقاف والشؤون الدينية',
      ministrySubtitle: 'دولة فلسطين',
      ministryDescription:
          'وزارة الأوقاف والشؤون الدينية تعمل على خدمة المجتمع الفلسطيني وتعزيز القيم الدينية والتراث الإسلامي.',
      contactPhone: '02-2411937/8/9',
      contactFax: null,
      contactEmail: 'info@awqaf.ps',
      contactAddress: 'القدس - مدينة البيرة - حي الجنان - شارع النور',
      workingDays: 'من الأحد إلى الخميس',
      workingHours: '8:00 صباحاً - 3:00 مساءً',
      quickLinks: const <FooterLink>[
        FooterLink(label: 'عن الوزارة', route: '/about'),
        FooterLink(label: 'الخدمات الإلكترونية', route: '/home/services'),
        FooterLink(label: 'المساجد', route: '/mosques'),
      ],
      servicesLinks: const <FooterLink>[],
      bottomLinks: const <FooterLink>[
        FooterLink(label: 'سياسة الخصوصية', route: '/privacy'),
        FooterLink(label: 'شروط الاستخدام', route: '/terms'),
        FooterLink(label: 'خريطة الموقع', route: '/sitemap'),
      ],
      partners: const <FooterPartner>[],
      showPartners: false,
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

  Future<void> updateFooterSettings(FooterSettings settings) async {
    await _supabase
        .from(_footerSettingsLegacyWriteTable)
        .update({
          'ministry_logo_url': settings.ministryLogoUrl,
          'ministry_name': settings.ministryName,
          'ministry_subtitle': settings.ministrySubtitle,
          'ministry_description': settings.ministryDescription,
          'contact_phone': settings.contactPhone,
          'contact_fax': settings.contactFax,
          'contact_email': settings.contactEmail,
          'contact_address': settings.contactAddress,
          'working_days': settings.workingDays,
          'working_hours': settings.workingHours,
          'facebook_url': settings.facebookUrl,
          'twitter_url': settings.twitterUrl,
          'instagram_url': settings.instagramUrl,
          'youtube_url': settings.youtubeUrl,
          'linkedin_url': settings.linkedinUrl,
          'quick_links': settings.quickLinks.map((e) => e.toJson()).toList(),
          'services_links': settings.servicesLinks
              .map((e) => e.toJson())
              .toList(),
          'bottom_links': settings.bottomLinks.map((e) => e.toJson()).toList(),
          'partners': settings.partners.map((e) => e.toJson()).toList(),
          'show_partners': settings.showPartners,
          'copyright_text': settings.copyrightText,
          'developer_credit': settings.developerCredit,
          'show_developer_credit': settings.showDeveloperCredit,
          'show_phone': settings.showPhone,
          'show_email': settings.showEmail,
          'show_address': settings.showAddress,
          'show_working_hours': settings.showWorkingHours,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', settings.id);
  }
}
