import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_user.dart';
import 'user_scope_assignments_repository.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

class AdminUsersRepository {
  final SupabaseClient _client;

  AdminUsersRepository(this._client);

  static const String _coreAdminUsersReadSurface =
      'v_core_admin_users_compat_v1';
  static const bool _ownerWriteRpcWriteRerouteEnabled = bool.fromEnvironment(
    'PWF_OWNER_WRITE_RPC_WRITE_REROUTE',
  );

  Future<List<Map<String, dynamic>>> fetchAdminUsers({
    String? search,
    bool? isActive,
  }) async {
    final rows = await _fetchAdminUsersRaw();

    final unitIds = rows
        .map((row) => (row['unit_id'] ?? '').toString())
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList();

    final unitsById = <String, Map<String, dynamic>>{};
    if (unitIds.isNotEmpty) {
      final units = await PwfDatabaseOwnerSurfaces.fromOwnerSchema(
        _client,
        PwfDatabaseOwnerSurfaces.orgUnits,
      ).select('id,slug,name_ar,name_en,login_key').inFilter('id', unitIds);
      for (final raw in units as List) {
        final row = Map<String, dynamic>.from(raw as Map);
        final id = (row['id'] ?? '').toString();
        if (id.trim().isNotEmpty) {
          unitsById[id] = row;
        }
      }
    }

    final scopeRepo = UserScopeAssignmentsRepository(_client);
    final scopeMap = await scopeRepo.fetchAssignmentsForUsers(
      rows
          .map((row) => (row['id'] ?? '').toString())
          .where((id) => id.trim().isNotEmpty)
          .toList(),
    );

    for (final row in rows) {
      final unitId = (row['unit_id'] ?? '').toString();
      final unit = unitsById[unitId];
      final isCentral = unitId.trim().isEmpty;
      row['is_central'] = isCentral;
      row['unit_slug'] = unit?['slug'];
      row['unit_name_ar'] = unit?['name_ar'];
      row['unit_name_en'] = unit?['name_en'];
      row['unit_login_key'] = unit?['login_key'];

      final userId = (row['id'] ?? '').toString();
      final assignments = scopeMap[userId] ?? const [];
      final scopeRoleKeys = assignments
          .map((e) => e.scopeRoleKey)
          .where((e) => e.trim().isNotEmpty)
          .toSet()
          .toList();
      final systemKeys = assignments
          .map((e) => e.systemKey ?? '')
          .where((e) => e.trim().isNotEmpty)
          .toSet()
          .toList();
      final assignedUnitIds = <String>{
        for (final assignment in assignments) ...assignment.linkedUnitIds,
        for (final assignment in assignments)
          if ((assignment.unitId ?? '').trim().isNotEmpty)
            assignment.unitId!.trim(),
      }.toList();
      final assignedUnitNamesAr = <String>{
        for (final assignment in assignments) ...assignment.linkedUnitNamesAr,
        if ((unit?['name_ar'] ?? '').toString().trim().isNotEmpty)
          (unit?['name_ar'] ?? '').toString().trim(),
      }.toList();
      final primary = assignments.isNotEmpty ? assignments.first : null;

      final adminUser = AdminUser.fromJson({
        ...row,
        'unit_slug': unit?['slug'],
        'unit_name_ar': unit?['name_ar'],
        'unit_name_en': unit?['name_en'],
        'scope_role_keys': scopeRoleKeys,
        'assigned_system_keys': systemKeys,
        'assigned_unit_ids': assignedUnitIds,
        'assigned_unit_names_ar': assignedUnitNamesAr,
        'primary_scope_role_key': primary?.scopeRoleKey,
        'primary_scope_system_key': primary?.systemKey,
      });

      row['scope_label'] = adminUser.scopeLabel;
      row['role_label_ar'] = adminUser.operationalRoleLabelAr;
      row['operational_role_key'] = adminUser.operationalRoleKey;
      row['operational_role_label_ar'] = adminUser.operationalRoleLabelAr;
      row['governance_scope_description'] =
          adminUser.governanceScopeDescription;
      row['display_name'] = adminUser.displayName;
      row['is_delegate_hint'] = adminUser.hasDelegateHint;
      row['scope_role_keys'] = scopeRoleKeys;
      row['assigned_system_keys'] = systemKeys;
      row['assigned_unit_ids'] = assignedUnitIds;
      row['assigned_unit_names_ar'] = assignedUnitNamesAr;
      row['primary_scope_role_key'] = primary?.scopeRoleKey;
      row['primary_scope_system_key'] = primary?.systemKey;
      row['scope_assignments_count'] = assignments.length;
      row['scope_units_summary'] = assignments
          .where((e) => e.unitsSummaryAr.isNotEmpty)
          .map((e) => e.unitsSummaryAr)
          .toSet()
          .join('، ');
    }

    final normalizedSearch = (search ?? '').trim().toLowerCase();
    final filtered = rows.where((row) {
      final matchesActive = isActive == null || row['is_active'] == isActive;
      if (!matchesActive) return false;
      if (normalizedSearch.isEmpty) return true;

      final haystack = [
        row['name'],
        row['display_name'],
        row['username'],
        row['email'],
        row['role'],
        row['role_label_ar'],
        row['scope_label'],
        row['unit_name_ar'],
        row['unit_slug'],
        row['department'],
      ].whereType<Object>().map((e) => e.toString().toLowerCase()).join(' ');

      return haystack.contains(normalizedSearch);
    }).toList();

    filtered.sort((a, b) {
      final aCentral = (a['unit_id'] ?? '').toString().trim().isEmpty;
      final bCentral = (b['unit_id'] ?? '').toString().trim().isEmpty;
      if (aCentral != bCentral) {
        return aCentral ? -1 : 1;
      }
      final aScope = (a['scope_label'] ?? '').toString();
      final bScope = (b['scope_label'] ?? '').toString();
      final scopeCompare = aScope.compareTo(bScope);
      if (scopeCompare != 0) return scopeCompare;
      final aUser = (a['username'] ?? a['email'] ?? '').toString();
      final bUser = (b['username'] ?? b['email'] ?? '').toString();
      return aUser.compareTo(bUser);
    });

    return filtered;
  }

  Future<List<Map<String, dynamic>>> _fetchAdminUsersRaw() async {
    // Development 9D: read admin profiles through the core/admin public
    // compatibility wrapper. Owner-write paths remain blocked until reviewed
    // RPCs are installed and runtime write reroute is explicitly authorized.
    final res = await _client
        .from(_coreAdminUsersReadSurface)
        .select(
          'id,email,name,username,role,department,governorate,phone,avatar_url,is_active,last_login,is_superuser,unit_id,created_at,updated_at',
        );
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchActiveUnits() async {
    final res = await PwfDatabaseOwnerSurfaces.fromOwnerSchema(
      _client,
      PwfDatabaseOwnerSurfaces.orgUnits,
    ).select('id,slug,name_ar,name_en,login_key,is_active')
        .eq('is_active', true)
        .order('name_ar');

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> setActive({
    required String userId,
    required bool isActive,
  }) async {
    if (_ownerWriteRpcWriteRerouteEnabled) {
      await _client.rpc(
        'rpc_core_admin_user_profile_update_v1',
        params: {
          'p_target_user_id': userId,
          'p_patch': {'is_active': isActive, 'operation': 'set_active'},
        },
      );
      return;
    }
    try {
      await _client.rpc(
        'rpc_admin_user_set_flags',
        params: {
          'p_user_id': userId,
          'p_is_active': isActive,
          'p_is_superuser': null,
        },
      );
      return;
    } catch (_) {
      await _client
          .from(PwfDatabaseOwnerSurfaces.adminUsers)
          .update({'is_active': isActive})
          .eq('id', userId);
    }
  }

  Future<void> setSuperuser({
    required String userId,
    required bool isSuperuser,
  }) async {
    if (_ownerWriteRpcWriteRerouteEnabled) {
      await _client.rpc(
        'rpc_core_admin_user_profile_update_v1',
        params: {
          'p_target_user_id': userId,
          'p_patch': {
            'is_superuser': isSuperuser,
            'operation': 'set_superuser',
          },
        },
      );
      return;
    }
    try {
      await _client.rpc(
        'rpc_admin_user_set_flags',
        params: {
          'p_user_id': userId,
          'p_is_active': null,
          'p_is_superuser': isSuperuser,
        },
      );
      return;
    } catch (_) {
      await _client
          .from(PwfDatabaseOwnerSurfaces.adminUsers)
          .update({'is_superuser': isSuperuser})
          .eq('id', userId);
    }
  }

  Future<void> updateAdminUser({
    required String id,
    required String email,
    required String name,
    required String username,
    required String role,
    String? unitId,
    String? department,
    String? governorate,
    String? phone,
    String? avatarUrl,
    bool? isActive,
    bool? isSuperuser,
  }) async {
    final payload = <String, dynamic>{
      'email': email.trim(),
      'name': name.trim(),
      'username': username.trim(),
      'role': role,
      'unit_id': (unitId == null || unitId.trim().isEmpty)
          ? null
          : unitId.trim(),
      'department': (department == null || department.trim().isEmpty)
          ? null
          : department.trim(),
      'governorate': (governorate == null || governorate.trim().isEmpty)
          ? null
          : governorate.trim(),
      'phone': (phone == null || phone.trim().isEmpty) ? null : phone.trim(),
      'avatar_url': (avatarUrl == null || avatarUrl.trim().isEmpty)
          ? null
          : avatarUrl.trim(),
    };
    if (isActive != null) payload['is_active'] = isActive;
    if (isSuperuser != null) payload['is_superuser'] = isSuperuser;
    if (_ownerWriteRpcWriteRerouteEnabled) {
      await _client.rpc(
        'rpc_core_admin_user_profile_update_v1',
        params: {
          'p_target_user_id': id,
          'p_patch': {...payload, 'operation': 'update_admin_user'},
        },
      );
      return;
    }
    await _client
        .from(PwfDatabaseOwnerSurfaces.adminUsers)
        .update(payload)
        .eq('id', id);
  }

  Future<void> createAdminUser({
    required String id,
    required String email,
    required String name,
    required String role,
    String? username,
    String? unitId,
    String? department,
    bool isActive = true,
    bool? isSuperuser,
  }) async {
    final payload = <String, dynamic>{
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'is_active': isActive,
    };
    if (username != null && username.trim().isNotEmpty) {
      payload['username'] = username.trim();
    }
    if (unitId != null && unitId.trim().isNotEmpty) {
      payload['unit_id'] = unitId.trim();
    }
    if (department != null && department.trim().isNotEmpty) {
      payload['department'] = department.trim();
    }
    if (isSuperuser != null) {
      payload['is_superuser'] = isSuperuser;
    }
    if (_ownerWriteRpcWriteRerouteEnabled) {
      await _client.rpc(
        'rpc_core_admin_user_link_v1',
        params: {
          'p_target_user_id': id,
          'p_patch': {...payload, 'operation': 'create_or_link_admin_user'},
        },
      );
      return;
    }
    await _client.from(PwfDatabaseOwnerSurfaces.adminUsers).insert(payload);
  }
}
