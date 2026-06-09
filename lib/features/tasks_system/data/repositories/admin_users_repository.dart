import 'package:supabase_flutter/supabase_flutter.dart';
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
    final q = _client.from(_coreAdminUsersReadSurface).select();

    // فلترة نشط/غير نشط (اختياري)
    if (isActive != null) {
      q.eq('is_active', isActive);
    }

    // بحث بسيط (اسم/بريد)
    if (search != null && search.trim().isNotEmpty) {
      final s = search.trim();
      // ilike on two columns
      q.or('name.ilike.%$s%,email.ilike.%$s%');
    }

    final res = await q.order('created_at', ascending: false);
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
          'p_patch': {'is_active': isActive, 'operation': 'tasks_set_active'},
        },
      );
      return;
    }
    await _client
        .from(PwfDatabaseOwnerSurfaces.adminUsers)
        .update({'is_active': isActive})
        .eq('id', userId);
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
            'operation': 'tasks_set_superuser',
          },
        },
      );
      return;
    }
    await _client
        .from(PwfDatabaseOwnerSurfaces.adminUsers)
        .update({'is_superuser': isSuperuser})
        .eq('id', userId);
  }

  Future<void> createAdminUser({
    required String id,
    required String email,
    required String name,
    required String role,
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
          'p_patch': {
            ...payload,
            'operation': 'tasks_create_or_link_admin_user',
          },
        },
      );
      return;
    }
    await _client.from(PwfDatabaseOwnerSurfaces.adminUsers).insert(payload);
  }
}
