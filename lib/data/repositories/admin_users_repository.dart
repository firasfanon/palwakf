import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUsersRepository {
  final SupabaseClient _client;

  AdminUsersRepository(this._client);

  Future<List<Map<String, dynamic>>> fetchAdminUsers({
    String? search,
    bool? isActive,
  }) async {
    final q = _client.from('admin_users').select();

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
    await _client
        .from('admin_users')
        .update({'is_active': isActive})
        .eq('id', userId);
  }

  Future<void> setSuperuser({
    required String userId,
    required bool isSuperuser,
  }) async {
    await _client
        .from('admin_users')
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
    await _client.from('admin_users').insert(payload);
  }

}
