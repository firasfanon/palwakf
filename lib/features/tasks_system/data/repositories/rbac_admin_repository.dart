import 'package:supabase_flutter/supabase_flutter.dart';

class RbacAdminRepository {
  final SupabaseClient _client;
  RbacAdminRepository(this._client);

  static const String _platformSystemsReadSurface =
      'v_platform_systems_compat_v1';
  static const String _platformPermissionsReadSurface =
      'v_platform_permissions_compat_v1';
  static const String _userSystemRolesReadSurface =
      'v_platform_user_system_roles_compat_v1';
  static const String _userSystemPermissionsReadSurface =
      'v_platform_user_system_permissions_compat_v1';

  static const String _userSystemRolesLegacyWriteTable = 'user_system_roles';
  static const String _userSystemPermissionsLegacyWriteTable =
      'user_system_permissions';

  Future<List<Map<String, dynamic>>> fetchSystems() async {
    final res = await _client
        .from(_platformSystemsReadSurface)
        .select('*') // بدل system_key,...
        .order('name_ar', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchPermissionsCatalog() async {
    final res = await _client
        .from(_platformPermissionsReadSurface)
        .select('*') // بدل permission_key,...
        .order('name_ar', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchUserRoles(String userId) async {
    final res = await _client
        .from(_userSystemRolesReadSurface)
        .select('system_key,role,created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchUserPermissions(String userId) async {
    final res = await _client
        .from(_userSystemPermissionsReadSurface)
        .select('system_key,permission_key,created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> upsertUserRole({
    required String userId,
    required String systemKey,
    required String role,
  }) async {
    // Safe upsert without relying on a UNIQUE constraint.
    final existing = await _client
        .from(_userSystemRolesReadSurface)
        .select('user_id,system_key')
        .eq('user_id', userId)
        .eq('system_key', systemKey)
        .maybeSingle();

    if (existing == null) {
      await _client.from(_userSystemRolesLegacyWriteTable).insert({
        'user_id': userId,
        'system_key': systemKey,
        'role': role,
      });
    } else {
      await _client
          .from(_userSystemRolesLegacyWriteTable)
          .update({'role': role})
          .eq('user_id', userId)
          .eq('system_key', systemKey);
    }
  }

  Future<void> deleteUserRole({
    required String userId,
    required String systemKey,
  }) async {
    await _client
        .from(_userSystemRolesLegacyWriteTable)
        .delete()
        .eq('user_id', userId)
        .eq('system_key', systemKey);
  }

  Future<void> upsertUserPermission({
    required String userId,
    required String systemKey,
    required String permissionKey,
  }) async {
    // Safe insert without relying on a UNIQUE constraint.
    final existing = await _client
        .from(_userSystemPermissionsReadSurface)
        .select('user_id,system_key,permission_key')
        .eq('user_id', userId)
        .eq('system_key', systemKey)
        .eq('permission_key', permissionKey)
        .maybeSingle();

    if (existing != null) return;

    await _client.from(_userSystemPermissionsLegacyWriteTable).insert({
      'user_id': userId,
      'system_key': systemKey,
      'permission_key': permissionKey,
    });
  }

  Future<void> deleteUserPermission({
    required String userId,
    required String systemKey,
    required String permissionKey,
  }) async {
    await _client
        .from(_userSystemPermissionsLegacyWriteTable)
        .delete()
        .eq('user_id', userId)
        .eq('system_key', systemKey)
        .eq('permission_key', permissionKey);
  }
}
