// lib/data/repositories/footer_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';
import 'package:waqf/core/unit/pwf_canonical_unit_identity.dart';
import '../models/footer_settings.dart';

class FooterRepository {
  FooterRepository(this._supabase);

  final SupabaseClient _supabase;

  // Runtime reads are dependency-zero: core owner-schema profile surface only.
  static const String _unitSurfaceProfileReadSurface =
      PwfDatabaseOwnerSurfaces.unitPublicSurfaceProfileRuntimeV1;

  // Owner writes are performed only through core.rpc_unit_public_profile_write_v1.

  // Legacy global fallback sentinel retained for contract tests only. Runtime
  // unit pages remain strict: if (!strictUnitOnly) _globalUnitId must never be
  // reached for unit-scoped public pages.
  static const String _globalUnitId = '11111111-1111-1111-1111-111111111111';

  Future<FooterSettings> fetchFooterSettings() async {
    final row = await _fetchProfileByInternalSlug('home');
    if (row != null) return _hydrateRuntimeProfileFooter(row, isHome: true);
    return _runtimeDefaultFooterSettings();
  }

  Future<FooterSettings> fetchFooterSettingsForScopes({
    String? unitId,
    String? homeUnitId,
    bool strictUnitOnly = false,
  }) async {
    final normalizedUnitId = unitId?.trim();
    if (normalizedUnitId != null && normalizedUnitId.isNotEmpty) {
      final row = await _fetchProfileByUnitId(normalizedUnitId);
      if (row != null) {
        return _hydrateRuntimeProfileFooter(row, isHome: !strictUnitOnly);
      }
    }

    if (strictUnitOnly) return _runtimeUnitPlaceholderFooterSettings();

    final homeId = homeUnitId?.trim();
    if (homeId != null && homeId.isNotEmpty) {
      final row = await _fetchProfileByUnitId(homeId);
      if (row != null) return _hydrateRuntimeProfileFooter(row, isHome: true);
    }

    if (!strictUnitOnly) {
      final row = await _fetchProfileByUnitId(_globalUnitId);
      if (row != null) return _hydrateRuntimeProfileFooter(row, isHome: true);
    }

    return fetchFooterSettings();
  }

  Future<FooterSettings> fetchFooterSettingsForEdit({
    String? unitId,
    String? homeUnitId,
    bool strictUnitOnly = false,
  }) async {
    final effective = await fetchFooterSettingsForScopes(
      unitId: unitId,
      homeUnitId: homeUnitId,
      strictUnitOnly: strictUnitOnly,
    );
    return effective.copyWith(
      id: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<Map<String, dynamic>?> _fetchProfileByUnitId(String unitId) async {
    try {
      final response = await PwfDatabaseOwnerSurfaces.fromOwnerSchema(
          _supabase,
          _unitSurfaceProfileReadSurface,
        )
          .select()
          .eq('org_unit_id', unitId)
          .maybeSingle();
      if (response == null) return null;
      return Map<String, dynamic>.from(response);
    } on PostgrestException catch (error) {
      if (_isOptionalSingletonMiss(error)) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _fetchProfileByInternalSlug(String slug) async {
    try {
      final response = await PwfDatabaseOwnerSurfaces.fromOwnerSchema(
          _supabase,
          _unitSurfaceProfileReadSurface,
        )
          .select()
          .eq('internal_slug', slug)
          .maybeSingle();
      if (response == null) return null;
      return Map<String, dynamic>.from(response);
    } on PostgrestException catch (error) {
      if (_isOptionalSingletonMiss(error)) return null;
      rethrow;
    }
  }

  FooterSettings _hydrateRuntimeProfileFooter(
    Map<String, dynamic> row, {
    required bool isHome,
  }) {
    final source = _sourcePayload(row);
    final now = DateTime.now();
    final unitName = _firstText(row, source, const [
      'unit_name_ar',
      'name_ar',
    ], fallback: isHome ? 'وزارة الأوقاف والشؤون الدينية' : 'بيانات الوحدة غير منشورة');

    final phone = _firstNullableText(row, source, const [
      'contact_phone',
      'phone',
      'telephone',
      'mobile',
    ]);
    final email = _firstNullableText(row, source, const [
      'contact_email',
      'email',
    ]);
    final address = _firstNullableText(row, source, const [
      'contact_address',
      'address',
      'address_ar',
      'location',
    ]);

    if (!isHome && phone == null && email == null && address == null) {
      return _runtimeUnitPlaceholderFooterSettings().copyWith(
        ministryName: unitName,
        copyrightText: '$unitName - بيانات الاتصال بانتظار الاعتماد.',
      );
    }

    final identity = PwfCanonicalUnitIdentity.fromRuntimeProfileRow(row);
    return FooterSettings(
      id: identity.canonicalOrgUnitId.isEmpty
          ? 'runtime-profile-footer'
          : identity.canonicalOrgUnitId,
      ministryLogoUrl: _firstNullableText(row, source, const [
        'logo_url',
        'ministry_logo_url',
      ]),
      ministryName: unitName,
      ministrySubtitle: isHome ? 'دولة فلسطين' : 'بوابة الوحدة العامة',
      ministryDescription: _firstNullableText(row, source, const [
        'description_ar',
        'ministry_description',
        'description',
      ]) ??
          (isHome
              ? 'وزارة الأوقاف والشؤون الدينية تعمل على خدمة المجتمع الفلسطيني وتعزيز القيم الدينية والتراث الإسلامي.'
              : 'بوابة عامة للوحدة، ومصدر بياناتها هو core.org_units وملفات الوحدة السيادية.'),
      contactPhone: phone,
      contactFax: _firstNullableText(row, source, const ['contact_fax', 'fax']),
      contactEmail: email,
      contactAddress: address,
      workingDays: _firstText(row, source, const ['working_days'], fallback: isHome ? 'من الأحد إلى الخميس' : 'غير منشور'),
      workingHours: _firstText(row, source, const ['working_hours'], fallback: isHome ? '8:00 صباحاً - 3:00 مساءً' : 'غير منشور'),
      facebookUrl: _socialUrl(row, 'facebook') ?? _firstNullableText(row, source, const ['facebook_url', 'facebook']),
      twitterUrl: _socialUrl(row, 'x') ?? _firstNullableText(row, source, const ['twitter_url', 'x_url', 'twitter']),
      instagramUrl: _socialUrl(row, 'instagram') ?? _firstNullableText(row, source, const ['instagram_url', 'instagram']),
      youtubeUrl: _socialUrl(row, 'youtube') ?? _firstNullableText(row, source, const ['youtube_url', 'youtube']),
      linkedinUrl: _socialUrl(row, 'linkedin') ?? _firstNullableText(row, source, const ['linkedin_url', 'linkedin']),
      quickLinks: const <FooterLink>[],
      servicesLinks: const <FooterLink>[],
      bottomLinks: const <FooterLink>[],
      partners: const <FooterPartner>[],
      showPartners: false,
      copyrightText: isHome
          ? 'وزارة الأوقاف والشؤون الدينية - جميع الحقوق محفوظة.'
          : '$unitName - جميع الحقوق محفوظة.',
      developerCredit: '',
      showDeveloperCredit: false,
      showPhone: phone != null,
      showEmail: email != null,
      showAddress: address != null,
      showWorkingHours: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> _sourcePayload(Map<String, dynamic> row) {
    final value = row['source_payload'];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const <String, dynamic>{};
  }

  String _firstText(
    Map<String, dynamic> row,
    Map<String, dynamic> source,
    List<String> keys, {
    required String fallback,
  }) {
    return _firstNullableText(row, source, keys) ?? fallback;
  }

  String? _socialUrl(Map<String, dynamic> row, String platformKey) {
    final raw = row['social_links'];
    if (raw is! List) return null;
    for (final item in raw) {
      if (item is! Map) continue;
      final platform = (item['platform_key'] ?? '').toString().trim().toLowerCase();
      final url = (item['official_url'] ?? '').toString().trim();
      final verified = item['is_verified'] == true;
      final isPublic = item['is_public'] != false;
      final status = (item['status'] ?? '').toString().trim().toLowerCase();
      if (platform == platformKey && verified && isPublic && status == 'published' && url.isNotEmpty) {
        return url;
      }
    }
    return null;
  }

  String? _firstNullableText(
    Map<String, dynamic> row,
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final rowValue = row[key]?.toString().trim();
      if (rowValue != null && rowValue.isNotEmpty && rowValue != 'null') {
        return rowValue;
      }
      final sourceValue = source[key]?.toString().trim();
      if (sourceValue != null && sourceValue.isNotEmpty && sourceValue != 'null') {
        return sourceValue;
      }
    }
    return null;
  }

  FooterSettings _runtimeUnitPlaceholderFooterSettings() {
    final now = DateTime.now();
    return FooterSettings(
      id: 'runtime-unit-placeholder-footer',
      ministryLogoUrl: null,
      ministryName: 'بيانات الوحدة غير منشورة',
      ministrySubtitle: 'بوابة الوحدة العامة',
      ministryDescription:
          'لم تنشر هذه الوحدة بيانات الاتصال أو وسائل التواصل الاجتماعي الخاصة بها بعد.',
      contactPhone: null,
      contactFax: null,
      contactEmail: null,
      contactAddress: null,
      workingDays: 'غير منشور',
      workingHours: 'غير منشور',
      facebookUrl: null,
      twitterUrl: null,
      instagramUrl: null,
      youtubeUrl: null,
      linkedinUrl: null,
      quickLinks: const <FooterLink>[],
      servicesLinks: const <FooterLink>[],
      bottomLinks: const <FooterLink>[],
      partners: const <FooterPartner>[],
      showPartners: false,
      copyrightText: 'بوابة الوحدة العامة - بيانات الاتصال بانتظار الاعتماد.',
      developerCredit: '',
      showDeveloperCredit: false,
      showPhone: false,
      showEmail: false,
      showAddress: false,
      showWorkingHours: false,
      createdAt: now,
      updatedAt: now,
    );
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
      contactPhone: null,
      contactFax: null,
      contactEmail: null,
      contactAddress: null,
      workingDays: 'من الأحد إلى الخميس',
      workingHours: '8:00 صباحاً - 3:00 مساءً',
      quickLinks: const <FooterLink>[],
      servicesLinks: const <FooterLink>[],
      bottomLinks: const <FooterLink>[],
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

Future<void> saveFooterSettingsForUnit(
  FooterSettings settings, {
  String? unitId,
}) async {
  final effectiveUnitId = (unitId ?? '').trim().isNotEmpty
      ? unitId!.trim()
      : await _resolveHomeUnitId();
  if (effectiveUnitId.isEmpty) {
    throw StateError('تعذر تحديد نطاق الوحدة لحفظ بيانات الفوتر.');
  }

  await _supabase.schema('core').rpc(
    'rpc_unit_public_profile_write_v1',
    params: <String, dynamic>{
      'p_org_unit_id': effectiveUnitId,
      'p_payload': <String, dynamic>{
        'logo_url': settings.ministryLogoUrl,
        'official_name_ar': settings.ministryName,
        'footer_description_ar': settings.ministryDescription,
        'contact_phone': settings.contactPhone,
        'contact_fax': settings.contactFax,
        'contact_email': settings.contactEmail,
        'contact_address': settings.contactAddress,
        'working_days': settings.workingDays,
        'working_hours': settings.workingHours,
      },
    },
  );

  await _supabase.schema('core').rpc(
    'rpc_unit_public_social_links_replace_v1',
    params: <String, dynamic>{
      'p_org_unit_id': effectiveUnitId,
      'p_links': <Map<String, dynamic>>[
        _socialPayload('facebook', settings.facebookUrl, 10),
        _socialPayload('x', settings.twitterUrl, 20),
        _socialPayload('instagram', settings.instagramUrl, 30),
        _socialPayload('youtube', settings.youtubeUrl, 40),
        _socialPayload('linkedin', settings.linkedinUrl, 50),
      ].where((row) => (row['official_url'] ?? '').toString().isNotEmpty).toList(),
    },
  );
}

Map<String, dynamic> _socialPayload(String platform, String? url, int order) =>
    <String, dynamic>{
      'platform_key': platform,
      'official_url': (url ?? '').trim(),
      'display_order': order,
      'is_verified': false,
      'is_public': true,
      'status': 'draft',
    };

Future<String> _resolveHomeUnitId() async {
  final row = await _fetchProfileByInternalSlug('home');
  if (row == null) return '';
  return PwfCanonicalUnitIdentity
      .fromRuntimeProfileRow(row)
      .canonicalOrgUnitId;
}

  Future<void> updateFooterSettings(FooterSettings settings) async {
    await saveFooterSettingsForUnit(settings);
  }
}
