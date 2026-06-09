import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pwf_former_minister.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

class PwfFormerMinistersRepository {
  PwfFormerMinistersRepository(this._supabase);

  final SupabaseClient _supabase;
  static const String _globalUnitId = '11111111-1111-1111-1111-111111111111';

  Future<List<PwfFormerMinister>> fetchForScopes({
    String? unitId,
    String? homeUnitId,
    bool includeInactive = false,
  }) async {
    for (final candidate in <String?>[
      unitId,
      if (homeUnitId != unitId) homeUnitId,
      _globalUnitId,
      null,
    ]) {
      final list = await _fetchByUnitId(
        candidate,
        includeInactive: includeInactive,
      );
      if (list.isNotEmpty) return list;
    }
    return const <PwfFormerMinister>[];
  }

  Future<List<PwfFormerMinister>> fetchForEdit({
    String? unitId,
    String? homeUnitId,
  }) async {
    final normalizedUnitId = unitId?.trim().isEmpty ?? true
        ? null
        : unitId!.trim();
    final exact = await _fetchByUnitId(normalizedUnitId, includeInactive: true);
    if (exact.isNotEmpty) return exact;
    return fetchForScopes(
      unitId: normalizedUnitId,
      homeUnitId: homeUnitId,
      includeInactive: true,
    );
  }

  Future<void> upsertMinister(
    PwfFormerMinister minister, {
    String? unitId,
  }) async {
    final normalizedUnitId = unitId?.trim().isEmpty ?? true
        ? null
        : unitId!.trim();
    final payload = minister.toPayload(scopedUnitId: normalizedUnitId);
    if (minister.id.trim().isNotEmpty) {
      await _supabase
          .from(PwfDatabaseOwnerSurfaces.formerMinisters)
          .update(payload)
          .eq('id', minister.id);
    } else {
      payload['created_at'] = DateTime.now().toIso8601String();
      await _supabase
          .from(PwfDatabaseOwnerSurfaces.formerMinisters)
          .insert(payload);
    }
  }

  Future<void> deleteMinister(String id) async {
    await _supabase
        .from(PwfDatabaseOwnerSurfaces.formerMinisters)
        .delete()
        .eq('id', id);
  }

  Future<List<PwfFormerMinister>> _fetchByUnitId(
    String? unitId, {
    required bool includeInactive,
  }) async {
    var query = _supabase
        .from(PwfDatabaseOwnerSurfaces.formerMinisters)
        .select();
    query = unitId == null
        ? query.isFilter('unit_id', null)
        : query.eq('unit_id', unitId);
    if (!includeInactive) {
      query = query.eq('is_active', true);
    }
    final response = await query
        .order('sort_order', ascending: true)
        .order('start_date', ascending: false);
    return (response as List)
        .map(
          (e) => PwfFormerMinister.fromMap(Map<String, dynamic>.from(e as Map)),
        )
        .toList(growable: false);
  }
}
