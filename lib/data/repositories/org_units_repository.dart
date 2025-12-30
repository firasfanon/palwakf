import 'package:supabase_flutter/supabase_flutter.dart';

class OrgUnitsRepository {
  final SupabaseClient _client;
  OrgUnitsRepository(this._client);

  Future<List<Map<String, dynamic>>> fetchUnitsWithProfiles() async {
    final res = await _client
        .from('org_units')
        .select('id,unit_type,parent_id,governorate_id,code,slug,name_ar,name_en,is_active,sort_order,created_at,updated_at,org_unit_profiles(*)')
        .order('sort_order', ascending: true)
        .order('name_ar', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<Map<String, dynamic>?> fetchUnitProfile(String unitId) async {
    final res = await _client
        .from('org_unit_profiles')
        .select('*')
        .eq('unit_id', unitId)
        .maybeSingle();
    if (res == null) return null;
    return Map<String, dynamic>.from(res);
  }


  Future<Map<String, dynamic>?> fetchUnitBySlug(String slug) async {
    final s = slug.trim().toLowerCase();
    final res = await _client
        .from('org_units')
        .select('id,unit_type,parent_id,governorate_id,code,slug,name_ar,name_en,is_active,sort_order,created_at,updated_at,org_unit_profiles(*)')
        .eq('slug', s)
        .maybeSingle();
    if (res == null) return null;
    return Map<String, dynamic>.from(res);
  }

  Future<String?> fetchUnitIdBySlug(String slug) async {
    final s = slug.trim().toLowerCase();
    final res = await _client
        .from('org_units')
        .select('id')
        .eq('slug', s)
        .maybeSingle();
    if (res == null) return null;
    return (res['id'] ?? '').toString();
  }

  Future<String> createUnitWithProfile({
    required Map<String, dynamic> unit,
    required Map<String, dynamic> profile,
  }) async {
    final inserted = await _client.from('org_units').insert(unit).select('id').single();
    final unitId = (inserted['id'] ?? '').toString();

    // Ensure profile row exists
    final prof = {...profile, 'unit_id': unitId};
    await _client.from('org_unit_profiles').upsert(prof, onConflict: 'unit_id');

    return unitId;
  }

  Future<void> updateUnitWithProfile({
    required String unitId,
    required Map<String, dynamic> unitPatch,
    required Map<String, dynamic> profilePatch,
  }) async {
    await _client.from('org_units').update(unitPatch).eq('id', unitId);

    // Upsert profile (1:1)
    final prof = {...profilePatch, 'unit_id': unitId};
    await _client.from('org_unit_profiles').upsert(prof, onConflict: 'unit_id');
  }

  Future<void> deleteUnit(String unitId) async {
    await _client.from('org_units').delete().eq('id', unitId);
  }
}
