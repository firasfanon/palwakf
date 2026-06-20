import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_scope_assignment.dart';

/// Scope assignments are an administrative security surface. They are read and
/// written through governed RPCs only: no client-side table/view fallback and
/// no direct DML path are permitted.
class UserScopeAssignmentsRepository {
  final SupabaseClient _client;

  UserScopeAssignmentsRepository(this._client);

  Future<List<UserScopeAssignment>> fetchUserAssignments(String userId) async {
    try {
      final rows = await _client.rpc(
        'rpc_user_scope_assignments_list_v1',
        params: {'p_user_id': userId},
      );
      return _normalizeRows(rows).map(UserScopeAssignment.fromJson).toList();
    } catch (_) {
      // The caller deliberately receives an empty safe state. Raw database
      // diagnostics are never surfaced through the administrative UI.
      return const <UserScopeAssignment>[];
    }
  }

  Future<Map<String, List<UserScopeAssignment>>> fetchAssignmentsForUsers(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return const {};
    try {
      final rows = await _client.rpc('rpc_user_scope_assignments_list_v1');
      final assignments = _normalizeRows(rows)
          .where((row) => userIds.contains((row['user_id'] ?? '').toString()))
          .map(UserScopeAssignment.fromJson)
          .toList();
      final result = <String, List<UserScopeAssignment>>{};
      for (final assignment in assignments) {
        result.putIfAbsent(assignment.userId, () => <UserScopeAssignment>[])
            .add(assignment);
      }
      return result;
    } catch (_) {
      return const {};
    }
  }

  List<Map<String, dynamic>> _normalizeRows(dynamic rawRows) {
    if (rawRows is! List) return const <Map<String, dynamic>>[];
    return rawRows.map((raw) {
      final row = Map<String, dynamic>.from(raw as Map);
      return {
        ...row,
        'linked_unit_ids': _stringList(row['linked_unit_ids']),
        'linked_unit_names_ar': _stringList(row['linked_unit_names_ar']),
      };
    }).toList();
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) return const <String>[];
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> upsertAssignment({
    String? id,
    required String userId,
    required String scopeRoleKey,
    String? systemKey,
    String? unitId,
    required List<String> linkedUnitIds,
    String? notes,
    bool isActive = true,
    DateTime? startsAt,
    DateTime? expiresAt,
  }) async {
    final normalizedSystemKey = systemKey?.trim();
    final normalizedUnits = linkedUnitIds
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();

    if (normalizedSystemKey == 'site') {
      await _client.rpc(
        'rpc_site_unit_scope_assignment_upsert_v1',
        params: {
          'p_id': _nullableId(id),
          'p_user_id': userId,
          'p_scope_role_key': scopeRoleKey.trim(),
          'p_unit_id': _nullableId(unitId),
          'p_notes': _nullableText(notes),
          'p_is_active': isActive,
          'p_linked_unit_ids': normalizedUnits,
          'p_starts_at': startsAt?.toUtc().toIso8601String(),
          'p_expires_at': expiresAt?.toUtc().toIso8601String(),
        },
      );
      return;
    }

    await _client.rpc(
      'rpc_user_scope_assignment_upsert_v1',
      params: {
        'p_id': _nullableId(id),
        'p_user_id': userId,
        'p_scope_role_key': scopeRoleKey.trim(),
        'p_system_key':
            (normalizedSystemKey == null || normalizedSystemKey.isEmpty)
                ? null
                : normalizedSystemKey,
        'p_unit_id': _nullableId(unitId),
        'p_notes': _nullableText(notes),
        'p_is_active': isActive,
        'p_linked_unit_ids': normalizedUnits,
      },
    );
  }

  Future<void> deleteAssignment(
    String assignmentId, {
    String? systemKey,
  }) async {
    final rpcName = systemKey?.trim() == 'site'
        ? 'rpc_site_unit_scope_assignment_delete_v1'
        : 'rpc_user_scope_assignment_delete_v1';
    await _client.rpc(
      rpcName,
      params: {'p_assignment_id': assignmentId},
    );
  }

  String? _nullableId(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String? _nullableText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
