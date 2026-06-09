import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_scope_assignment.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

class UserScopeAssignmentsRepository {
  final SupabaseClient _client;

  /// Browser-UAT safe default: the list RPC currently returns PostgREST 400
  /// in the supplied access-gateway evidence. Keep reads on the existing
  /// governed table/view fallback until the RPC signature is verified and
  /// re-enabled by an explicit backend contract.
  static const bool _useUserScopeAssignmentsRpc = false;

  UserScopeAssignmentsRepository(this._client);

  Future<List<UserScopeAssignment>> fetchUserAssignments(String userId) async {
    if (_useUserScopeAssignmentsRpc) {
      try {
        final rpcRows = await _client.rpc(
          'rpc_user_scope_assignments_list_v1',
          params: {'p_user_id': userId},
        );
        final assignments = _normalizeRows(rpcRows);
        if (assignments.isNotEmpty) {
          return assignments.map(UserScopeAssignment.fromJson).toList();
        }
      } catch (_) {
        // Fallback to governed table/view surface when RPC layer is not
        // activated or has a signature mismatch.
      }
    }

    try {
      final rows = await _client
          .from(PwfDatabaseOwnerSurfaces.userScopeAssignments)
          .select(
            'id,user_id,scope_role_key,system_key,unit_id,is_active,notes,starts_at,expires_at,created_at,updated_at,granted_by',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final assignments = (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      return _enrichAssignments(assignments);
    } catch (_) {
      return const <UserScopeAssignment>[];
    }
  }

  Future<Map<String, List<UserScopeAssignment>>> fetchAssignmentsForUsers(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return const {};

    if (_useUserScopeAssignmentsRpc) {
      try {
        final rpcRows = await _client.rpc('rpc_user_scope_assignments_list_v1');
        final assignments = _normalizeRows(rpcRows)
            .where((row) => userIds.contains((row['user_id'] ?? '').toString()))
            .map(UserScopeAssignment.fromJson)
            .toList();
        if (assignments.isNotEmpty) {
          final map = <String, List<UserScopeAssignment>>{};
          for (final item in assignments) {
            map
                .putIfAbsent(item.userId, () => <UserScopeAssignment>[])
                .add(item);
          }
          return map;
        }
      } catch (_) {
        // Fallback to governed table/view surface when RPC layer is not
        // activated or has a signature mismatch.
      }
    }

    try {
      final rows = await _client
          .from(PwfDatabaseOwnerSurfaces.userScopeAssignments)
          .select(
            'id,user_id,scope_role_key,system_key,unit_id,is_active,notes,starts_at,expires_at,created_at,updated_at,granted_by',
          )
          .inFilter('user_id', userIds)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final assignments = (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final enriched = await _enrichAssignments(assignments);
      final map = <String, List<UserScopeAssignment>>{};
      for (final item in enriched) {
        map.putIfAbsent(item.userId, () => <UserScopeAssignment>[]).add(item);
      }
      return map;
    } catch (_) {
      return const {};
    }
  }

  List<Map<String, dynamic>> _normalizeRows(dynamic rawRows) {
    if (rawRows is! List) return const <Map<String, dynamic>>[];
    return rawRows.map((e) => Map<String, dynamic>.from(e as Map)).map((row) {
      final linkedIds =
          (row['linked_unit_ids'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .toList() ??
          const <String>[];
      final linkedNames =
          (row['linked_unit_names_ar'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .toList() ??
          const <String>[];
      return {
        ...row,
        'linked_unit_ids': linkedIds,
        'linked_unit_names_ar': linkedNames,
      };
    }).toList();
  }

  Future<List<UserScopeAssignment>> _enrichAssignments(
    List<Map<String, dynamic>> assignments,
  ) async {
    if (assignments.isEmpty) return const <UserScopeAssignment>[];

    final assignmentIds = assignments
        .map((row) => (row['id'] ?? '').toString())
        .where((id) => id.trim().isNotEmpty)
        .toList();

    final unitIds = <String>{
      ...assignments
          .map((row) => (row['unit_id'] ?? '').toString())
          .where((id) => id.trim().isNotEmpty),
    };

    final childUnitIdsByAssignment = <String, List<String>>{};
    try {
      if (assignmentIds.isNotEmpty) {
        final childRows = await _client
            .from(PwfDatabaseOwnerSurfaces.userScopeAssignmentUnits)
            .select('assignment_id,unit_id')
            .inFilter('assignment_id', assignmentIds);
        for (final raw in childRows as List) {
          final row = Map<String, dynamic>.from(raw as Map);
          final assignmentId = (row['assignment_id'] ?? '').toString();
          final unitId = (row['unit_id'] ?? '').toString();
          if (assignmentId.trim().isEmpty || unitId.trim().isEmpty) continue;
          childUnitIdsByAssignment
              .putIfAbsent(assignmentId, () => <String>[])
              .add(unitId);
          unitIds.add(unitId);
        }
      }
    } catch (_) {
      // table may not exist yet
    }

    final unitsById = <String, Map<String, dynamic>>{};
    if (unitIds.isNotEmpty) {
      try {
        final units = await _client
            .schema('core')
            .from(PwfDatabaseOwnerSurfaces.orgUnits)
            .select('id,slug,name_ar')
            .inFilter('id', unitIds.toList());
        for (final raw in units as List) {
          final row = Map<String, dynamic>.from(raw as Map);
          final id = (row['id'] ?? '').toString();
          if (id.trim().isNotEmpty) unitsById[id] = row;
        }
      } catch (_) {
        // ignore
      }
    }

    return assignments.map((row) {
      final assignmentId = (row['id'] ?? '').toString();
      final linkedIds =
          childUnitIdsByAssignment[assignmentId] ?? const <String>[];
      final names = linkedIds
          .map(
            (id) => (unitsById[id]?['name_ar'] ?? unitsById[id]?['slug'] ?? '')
                .toString(),
          )
          .where((e) => e.trim().isNotEmpty)
          .toList();
      if ((row['unit_id'] ?? '').toString().trim().isNotEmpty) {
        final primaryId = row['unit_id'].toString();
        if (!linkedIds.contains(primaryId)) {
          final primaryName =
              (unitsById[primaryId]?['name_ar'] ??
                      unitsById[primaryId]?['slug'] ??
                      '')
                  .toString();
          if (primaryName.trim().isNotEmpty && !names.contains(primaryName)) {
            names.insert(0, primaryName);
          }
        }
      }
      return UserScopeAssignment.fromJson({
        ...row,
        'linked_unit_ids': linkedIds,
        'linked_unit_names_ar': names,
      });
    }).toList();
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
  }) async {
    final payload = <String, dynamic>{
      'user_id': userId,
      'scope_role_key': scopeRoleKey,
      'system_key': (systemKey == null || systemKey.trim().isEmpty)
          ? null
          : systemKey.trim(),
      'unit_id': (unitId == null || unitId.trim().isEmpty)
          ? null
          : unitId.trim(),
      'notes': (notes == null || notes.trim().isEmpty) ? null : notes.trim(),
      'is_active': isActive,
    };

    final validUnits = linkedUnitIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    try {
      await _client.rpc(
        'rpc_user_scope_assignment_upsert_v1',
        params: {
          'p_id': (id == null || id.trim().isEmpty) ? null : id.trim(),
          'p_user_id': userId,
          'p_scope_role_key': scopeRoleKey,
          'p_system_key': payload['system_key'],
          'p_unit_id': payload['unit_id'],
          'p_notes': payload['notes'],
          'p_is_active': isActive,
          'p_linked_unit_ids': validUnits,
        },
      );
      return;
    } catch (_) {
      // Fallback to direct tables when RPC layer is not activated yet.
    }

    final scopeId = await (() async {
      if (id == null || id.trim().isEmpty) {
        final inserted = await _client
            .from(PwfDatabaseOwnerSurfaces.userScopeAssignments)
            .insert(payload)
            .select('id')
            .single();
        return (inserted['id'] ?? '').toString();
      }
      await _client
          .from(PwfDatabaseOwnerSurfaces.userScopeAssignments)
          .update(payload)
          .eq('id', id);
      return id;
    })();

    if (scopeId.trim().isEmpty) {
      throw Exception('تعذر حفظ النطاق.');
    }

    try {
      await _client
          .from(PwfDatabaseOwnerSurfaces.userScopeAssignmentUnits)
          .delete()
          .eq('assignment_id', scopeId);
      if (validUnits.isNotEmpty) {
        await _client
            .from(PwfDatabaseOwnerSurfaces.userScopeAssignmentUnits)
            .insert(
              validUnits
                  .map(
                    (unitId) => {'assignment_id': scopeId, 'unit_id': unitId},
                  )
                  .toList(),
            );
      }
    } catch (e) {
      throw Exception(
        'تم حفظ بيانات النطاق الأساسية لكن جدول الوحدات المتعددة غير مفعّل بعد: $e',
      );
    }
  }

  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await _client.rpc(
        'rpc_user_scope_assignment_delete_v1',
        params: {'p_assignment_id': assignmentId},
      );
      return;
    } catch (_) {
      // Fallback to direct tables when RPC layer is not activated yet.
    }

    try {
      await _client
          .from(PwfDatabaseOwnerSurfaces.userScopeAssignmentUnits)
          .delete()
          .eq('assignment_id', assignmentId);
    } catch (_) {}
    await _client
        .from(PwfDatabaseOwnerSurfaces.userScopeAssignments)
        .delete()
        .eq('id', assignmentId);
  }
}
