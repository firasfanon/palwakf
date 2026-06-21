import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';
import 'pwf_public_runtime_read_exception.dart';

class PwfPublicMediaRuntimeGateway {
  final SupabaseClient _client;

  const PwfPublicMediaRuntimeGateway(this._client);

  Future<List<Map<String, dynamic>>> fetchFeed({
    required String unitRef,
    required String familyKey,
    required int limit,
    int offset = 0,
  }) async {
    try {
      final response = await _client.rpc(
        PwfDatabaseOwnerSurfaces.publicMediaRuntimeFeedRpcV2,
        params: <String, dynamic>{
          'p_unit_ref': unitRef,
          'p_family_key': familyKey,
          'p_limit': limit,
        },
      );
      return _normalizeRows(response);
    } on Object catch (error) {
      throw PwfPublicRuntimeReadException.fromError(
        error,
        surface: PwfDatabaseOwnerSurfaces.publicMediaRuntimeFeedRpcV2,
        operation: 'fetchFeed',
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchDetail({
    required String unitRef,
    required String contentId,
    required String familyKey,
  }) async {
    try {
      final response = await _client.rpc(
        PwfDatabaseOwnerSurfaces.publicMediaRuntimeDetailRpcV2,
        params: <String, dynamic>{
          'p_unit_ref': unitRef,
          'p_content_id': contentId,
          'p_family_key': familyKey,
        },
      );
      return _normalizeRows(response);
    } on Object catch (error) {
      throw PwfPublicRuntimeReadException.fromError(
        error,
        surface: PwfDatabaseOwnerSurfaces.publicMediaRuntimeDetailRpcV2,
        operation: 'fetchDetail',
      );
    }
  }

  static List<Map<String, dynamic>> _normalizeRows(dynamic response) {
    if (response is List) {
      return response
          .whereType<Map>()
          .map((row) => row.map((key, value) => MapEntry(key.toString(), value)))
          .toList(growable: false);
    }
    if (response is Map) {
      final data = response['data'] ?? response['rows'] ?? response['items'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (row) => row.map((key, value) => MapEntry(key.toString(), value)),
            )
            .toList(growable: false);
      }
    }
    return const <Map<String, dynamic>>[];
  }
}
