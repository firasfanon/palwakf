import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

/// OrgUnitsRepository (Sovereign-friendly)
///
/// Why:
/// - In PalWakf, org units live in `core.org_units` + `core.org_unit_profiles`.
/// - Many clients cannot read/write `core` schema directly through PostgREST.
///
/// Approach:
/// - Read via RPCs in `public` that proxy core tables.
/// - Write (create/update/delete) via admin RPCs (security definer + superuser check).
/// - Fallback to legacy public tables if RPCs are missing (to avoid runtime crashes).
class OrgUnitsRepository {
  final SupabaseClient _client;
  OrgUnitsRepository(this._client);

  /// Returns rows shaped similarly to PostgREST embedded profiles:
  /// { ..., org_unit_profiles: [ { ...profile } ] }
  Future<List<Map<String, dynamic>>> fetchUnitsWithProfiles({
    bool onlyActive = true,
  }) async {
    try {
      final res = await _client.rpc(
        'pwf_list_units_with_profiles',
        params: <String, dynamic>{'p_only_active': onlyActive},
      );

      if (res is! List) return <Map<String, dynamic>>[];
      final list = res
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);

      // If the RPC is present but returns only a tiny subset (e.g. demo units),
      // fall back to the `public.org_units` VIEW (synced from core) to show all units.
      if (list.length >= 10) return list;

      final fallback = await _fetchUnitsFromPublicView(onlyActive: onlyActive);
      if (fallback.isNotEmpty) return fallback;

      return list;
    } on PostgrestException {
      // Fallback (legacy/demo): public.org_units + public.org_unit_profiles
      final res = await _client
          .from(PwfDatabaseOwnerSurfaces.orgUnits)
          .select(
            'id,unit_type,parent_id,governorate_id,code,slug,name_ar,name_en,is_active,sort_order,created_at,updated_at,org_unit_profiles(*)',
          )
          .order('sort_order', ascending: true)
          .order('name_ar', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUnitsFromPublicView({
    required bool onlyActive,
  }) async {
    // Reads from `public.org_units` (VIEW). No profiles are embedded here.
    try {
      var q = _client
          .from(PwfDatabaseOwnerSurfaces.orgUnits)
          .select(
            'id,unit_type,parent_id,governorate_id,code,slug,name_ar,name_en,is_active,sort_order,created_at,updated_at',
          );
      if (onlyActive) {
        q = q.eq('is_active', true);
      }
      final res = await q
          .order('sort_order', ascending: true)
          .order('name_ar', ascending: true);

      final rows = List<Map<String, dynamic>>.from(res);
      // Shape compatibility: some screens expect `org_unit_profiles` list.
      return rows
          .map(
            (e) => <String, dynamic>{
              ...e,
              'org_unit_profiles': const <Map<String, dynamic>>[],
            },
          )
          .toList(growable: false);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<Map<String, dynamic>?> fetchUnitBySlug(String slug) async {
    final s = slug.trim().toLowerCase();
    try {
      final res = await _client.rpc(
        'pwf_get_unit_with_profile_by_slug',
        params: <String, dynamic>{'p_slug': s},
      );
      if (res == null) return null;
      if (res is Map) return Map<String, dynamic>.from(res);
      return null;
    } on PostgrestException {
      final res = await _client
          .from(PwfDatabaseOwnerSurfaces.orgUnits)
          .select(
            'id,unit_type,parent_id,governorate_id,code,slug,name_ar,name_en,is_active,sort_order,created_at,updated_at,org_unit_profiles(*)',
          )
          .eq('slug', s)
          .maybeSingle();
      if (res == null) return null;
      return Map<String, dynamic>.from(res);
    }
  }

  /// Resolve org unit id by slug.
  ///
  /// Web first-load can occasionally fail on RPC fetches with `ClientException`.
  /// To keep the public shell fail-open, try the public view first, then RPC.
  Future<String?> fetchUnitIdBySlug(String slug) async {
    final s = slug.trim().toLowerCase();

    try {
      final res = await _client
          .from(PwfDatabaseOwnerSurfaces.orgUnits)
          .select('id')
          .eq('slug', s)
          .maybeSingle();
      final id = (res?['id'] ?? '').toString();
      if (id.isNotEmpty) return id;
    } catch (_) {
      // Ignore and continue to RPC fallback.
    }

    try {
      final res = await _client.rpc(
        'pwf_resolve_unit_id',
        params: <String, dynamic>{'p_unit_slug': s},
      );
      final id = (res ?? '').toString();
      if (id.isNotEmpty) return id;
    } catch (_) {
      // Ignore and fail-open below.
    }

    return null;
  }

  Future<Map<String, dynamic>?> fetchUnitProfile(String unitId) async {
    try {
      final res = await _client.rpc(
        'pwf_get_org_unit_profile',
        params: <String, dynamic>{'p_unit_id': unitId},
      );
      if (res == null) return null;
      if (res is Map) return Map<String, dynamic>.from(res);
      return null;
    } on PostgrestException {
      final res = await _client
          .from(PwfDatabaseOwnerSurfaces.orgUnitProfiles)
          .select('*')
          .eq('unit_id', unitId)
          .maybeSingle();
      if (res == null) return null;
      return Map<String, dynamic>.from(res);
    }
  }

  /// Admin: create org unit + ensure profile exists.
  /// Returns the new unit_id.
  Future<String> createUnitWithProfile({
    required Map<String, dynamic> unit,
    required Map<String, dynamic> profile,
  }) async {
    try {
      final res = await _client.rpc(
        'pwf_admin_create_unit_with_profile',
        params: <String, dynamic>{'p_unit': unit, 'p_profile': profile},
      );
      return res.toString();
    } on PostgrestException {
      // Fallback to legacy public tables
      final inserted = await _client
          .from(PwfDatabaseOwnerSurfaces.orgUnits)
          .insert(unit)
          .select('id')
          .single();
      final unitId = (inserted['id'] ?? '').toString();
      await _client.from(PwfDatabaseOwnerSurfaces.orgUnitProfiles).upsert({
        ...profile,
        'unit_id': unitId,
      }, onConflict: 'unit_id');
      return unitId;
    }
  }

  /// Admin: update org unit + upsert profile.
  Future<void> updateUnitWithProfile({
    required String unitId,
    required Map<String, dynamic> unitPatch,
    required Map<String, dynamic> profilePatch,
  }) async {
    try {
      await _client.rpc(
        'pwf_admin_update_unit_with_profile',
        params: <String, dynamic>{
          'p_unit_id': unitId,
          'p_unit_patch': unitPatch,
          'p_profile_patch': profilePatch,
        },
      );
    } on PostgrestException {
      await _client
          .from(PwfDatabaseOwnerSurfaces.orgUnits)
          .update(unitPatch)
          .eq('id', unitId);
      await _client.from(PwfDatabaseOwnerSurfaces.orgUnitProfiles).upsert({
        ...profilePatch,
        'unit_id': unitId,
      }, onConflict: 'unit_id');
    }
  }

  /// Admin: delete unit.
  Future<void> deleteUnit(String unitId) async {
    try {
      await _client.rpc(
        'pwf_admin_delete_unit',
        params: <String, dynamic>{'p_unit_id': unitId},
      );
    } on PostgrestException {
      await _client
          .from(PwfDatabaseOwnerSurfaces.orgUnits)
          .delete()
          .eq('id', unitId);
    }
  }
}
