import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waqf/core/data/pwf_runtime_payload_normalizer.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';
import 'package:waqf/core/unit/pwf_unit_slug_registry.dart';

/// OrgUnitsRepository — owner-schema direct public runtime.
///
/// Public/unit runtime resolves unit identity directly from
/// `core.v_unit_public_surface_profile_runtime_v1`, which is an
/// owner-schema surface over `core.org_units` and future unit profile tables.
class OrgUnitsRepository {
  final SupabaseClient _client;
  OrgUnitsRepository(this._client);

  Future<List<Map<String, dynamic>>> fetchUnitsWithProfiles({
    bool onlyActive = true,
  }) async {
    final res = await PwfDatabaseOwnerSurfaces.fromOwnerSchema(
        _client,
        PwfDatabaseOwnerSurfaces.unitPublicSurfaceProfileRuntimeV1,
      )
        .select('*')
        .order('unit_name_ar', ascending: true);

    final rows = PwfRuntimePayloadNormalizer.rows(
      res,
      source: 'core.v_unit_public_surface_profile_runtime_v1 list',
    ).map(_shapeRuntimeProfileAsOrgUnit)
        .where((row) {
          if (!onlyActive) return true;
          return _boolLike(row['is_active'], fallback: true);
        })
        .toList(growable: false);
    return rows;
  }

  Future<Map<String, dynamic>?> fetchUnitBySlug(String slug) async {
    final row = await _fetchRuntimeProfileBySlug(slug);
    if (row == null) return null;
    return _shapeRuntimeProfileAsOrgUnit(row);
  }

  Future<String?> fetchUnitIdBySlug(String slug) async {
    final row = await _fetchRuntimeProfileBySlug(slug);
    return (row?['org_unit_id'] ?? row?['id'] ?? '').toString().trim().isEmpty
        ? null
        : (row?['org_unit_id'] ?? row?['id']).toString().trim();
  }

  Future<Map<String, dynamic>?> fetchUnitProfile(String unitId) async {
    final id = unitId.trim();
    if (id.isEmpty) return null;
    final res = await PwfDatabaseOwnerSurfaces.fromOwnerSchema(
        _client,
        PwfDatabaseOwnerSurfaces.unitPublicSurfaceProfileRuntimeV1,
      )
        .select('*')
        .eq('org_unit_id', id)
        .maybeSingle();
    return PwfRuntimePayloadNormalizer.firstRow(
      res,
      source: 'core.v_unit_public_surface_profile_runtime_v1 profile',
    );
  }

  Future<Map<String, dynamic>?> _fetchRuntimeProfileBySlug(String slug) async {
    final internal = PwfUnitSlugRegistry.internalSlugFor(slug);
    final public = PwfUnitSlugRegistry.publicSlugFor(slug);
    final candidates = <String>{
      internal,
      public,
      slug.trim().toLowerCase(),
      ...PwfUnitSlugRegistry.compatibilityAliasesFor(slug)
          .map((value) => value.trim().toLowerCase()),
    }.where((value) => value.isNotEmpty).toList(growable: false);

    for (final candidate in candidates) {
      final byInternal = await PwfDatabaseOwnerSurfaces.fromOwnerSchema(
          _client,
          PwfDatabaseOwnerSurfaces.unitPublicSurfaceProfileRuntimeV1,
        )
          .select('*')
          .eq('internal_slug', candidate)
          .maybeSingle();
      final normalizedInternal = PwfRuntimePayloadNormalizer.firstRow(
        byInternal,
        source: 'core.v_unit_public_surface_profile_runtime_v1 internal_slug',
      );
      if (normalizedInternal != null) return normalizedInternal;

      final byPublic = await PwfDatabaseOwnerSurfaces.fromOwnerSchema(
          _client,
          PwfDatabaseOwnerSurfaces.unitPublicSurfaceProfileRuntimeV1,
        )
          .select('*')
          .eq('public_slug', candidate)
          .maybeSingle();
      final normalizedPublic = PwfRuntimePayloadNormalizer.firstRow(
        byPublic,
        source: 'core.v_unit_public_surface_profile_runtime_v1 public_slug',
      );
      if (normalizedPublic != null) return normalizedPublic;
    }
    return null;
  }

  Map<String, dynamic> _shapeRuntimeProfileAsOrgUnit(Map<String, dynamic> row) {
    final source = _sourcePayload(row);
    final id = (row['org_unit_id'] ?? row['id'] ?? source['id'] ?? '')
        .toString()
        .trim();
    final internalSlug = (row['internal_slug'] ?? source['slug'] ?? '')
        .toString()
        .trim();
    return <String, dynamic>{
      'id': id,
      'unit_type': source['unit_type'] ?? row['unit_type'],
      'parent_id': source['parent_id'] ?? row['parent_id'],
      'governorate_id': source['governorate_id'] ?? row['governorate_id'],
      'code': source['code'] ?? row['code'] ?? internalSlug,
      'slug': internalSlug,
      'public_slug': PwfUnitSlugRegistry.publicSlugFor(internalSlug),
      'name_ar': row['unit_name_ar'] ?? source['name_ar'] ?? internalSlug,
      'name_en': row['unit_name_en'] ?? source['name_en'],
      'is_active': row['is_active'] ?? source['is_active'] ?? source['active'] ?? true,
      'sort_order': source['sort_order'] ?? row['sort_order'] ?? 0,
      'created_at': source['created_at'] ?? row['created_at'],
      'updated_at': source['updated_at'] ?? row['updated_at'],
      'org_unit_profiles': const <Map<String, dynamic>>[],
      'runtime_source': PwfDatabaseOwnerSurfaces.unitPublicSurfaceProfileRuntimeV1,
    };
  }

  Map<String, dynamic> _sourcePayload(Map<String, dynamic> row) {
    final value = row['source_payload'];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const <String, dynamic>{};
  }

  bool _boolLike(dynamic value, {required bool fallback}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    final text = value.toString().trim().toLowerCase();
    if (text.isEmpty) return fallback;
    return text == 'true' || text == '1' || text == 'yes' || text == 'active';
  }

  /// Admin mutations remain explicitly outside this public runtime cutover.
  Future<String> createUnitWithProfile({
    required Map<String, dynamic> unit,
    required Map<String, dynamic> profile,
  }) async {
    final res = await _client.rpc(
      'pwf_admin_create_unit_with_profile',
      params: <String, dynamic>{'p_unit': unit, 'p_profile': profile},
    );
    return res.toString();
  }

  Future<void> updateUnitWithProfile({
    required String unitId,
    required Map<String, dynamic> unitPatch,
    required Map<String, dynamic> profilePatch,
  }) async {
    await _client.rpc(
      'pwf_admin_update_unit_with_profile',
      params: <String, dynamic>{
        'p_unit_id': unitId,
        'p_unit_patch': unitPatch,
        'p_profile_patch': profilePatch,
      },
    );
  }

  Future<void> deleteUnit(String unitId) async {
    await _client.rpc(
      'pwf_admin_delete_unit',
      params: <String, dynamic>{'p_unit_id': unitId},
    );
  }
}
