import 'package:supabase_flutter/supabase_flutter.dart';

class RbacAdminRepository {
  final SupabaseClient _client;
  RbacAdminRepository(this._client);

  Future<List<Map<String, dynamic>>> fetchSystems() async {
    final res = await _client
        .from('platform_systems')
        .select('*') // بدل system_key,...
        .order('name_ar', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchPermissionsCatalog() async {
    final res = await _client
        .from('platform_permissions')
        .select('*') // بدل permission_key,...
        .order('name_ar', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchUserRoles(String userId) async {
    final res = await _client
        .from('user_system_roles')
        .select('system_key,role,created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }



  Future<List<Map<String, dynamic>>> fetchUserPermissions(String userId) async {
    final res = await _client
        .from('user_system_permissions')
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
        .from('user_system_roles')
        .select('user_id,system_key')
        .eq('user_id', userId)
        .eq('system_key', systemKey)
        .maybeSingle();

    if (existing == null) {
      await _client.from('user_system_roles').insert({
        'user_id': userId,
        'system_key': systemKey,
        'role': role,
      });
    } else {
      await _client
          .from('user_system_roles')
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
        .from('user_system_roles')
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
        .from('user_system_permissions')
        .select('user_id,system_key,permission_key')
        .eq('user_id', userId)
        .eq('system_key', systemKey)
        .eq('permission_key', permissionKey)
        .maybeSingle();

    if (existing != null) return;

    await _client.from('user_system_permissions').insert({
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
        .from('user_system_permissions')
        .delete()
        .eq('user_id', userId)
        .eq('system_key', systemKey)
        .eq('permission_key', permissionKey);
  }
}
