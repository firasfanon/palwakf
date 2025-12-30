import '../models/user.dart';
import '../services/supabase_service.dart';

class UserRepository {
  final SupabaseService _supabaseService;

  UserRepository(this._supabaseService);

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) return null;

      final response = await _supabaseService.client
          .from('users')
          .select()
          .eq('id', currentUser.id)
          .single();

      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  // Get user by ID
  Future<User?> getUserById(int id) async {
    try {
      final response = await _supabaseService.client
          .from('users')
          .select()
          .eq('id', id)
          .single();

      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _supabaseService.client
          .from('users')
          .select()
          .order('name');

      return (response as List<dynamic>)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  // Get users by role
  Future<List<User>> getUsersByRole(UserRole role) async {
    try {
      final response = await _supabaseService.client
          .from('users')
          .select()
          .eq('role', role.name)
          .order('name');

      return (response as List<dynamic>)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load users by role: $e');
    }
  }

  // Get users by governorate
  Future<List<User>> getUsersByGovernorate(String governorate) async {
    try {
      final response = await _supabaseService.client
          .from('users')
          .select()
          .eq('governorate', governorate)
          .order('name');

      return (response as List<dynamic>)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load users by governorate: $e');
    }
  }

  // Update user
  Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    try {
      final response = await _supabaseService.client
          .from('users')
          .update({...updates, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .select()
          .single();

      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Update user permissions
  Future<User> updateUserPermissions(
      int id,
      UserPermissions permissions,
      ) async {
    try {
      return await updateUser(id, {
        'permissions': permissions.toJson(),
      });
    } catch (e) {
      throw Exception('Failed to update user permissions: $e');
    }
  }

  // Deactivate user
  Future<User> deactivateUser(int id) async {
    try {
      return await updateUser(id, {'is_active': false});
    } catch (e) {
      throw Exception('Failed to deactivate user: $e');
    }
  }

  // Activate user
  Future<User> activateUser(int id) async {
    try {
      return await updateUser(id, {'is_active': true});
    } catch (e) {
      throw Exception('Failed to activate user: $e');
    }
  }

  // Update last login
  Future<void> updateLastLogin(int id) async {
    try {
      await _supabaseService.client.from('users').update({
        'last_login': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      // Fail silently
    }
  }

  // Search users
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _supabaseService.client
          .from('users')
          .select()
          .or('name.ilike.%$query%,email.ilike.%$query%')
          .order('name');

      return (response as List<dynamic>)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final allUsers = await getAllUsers();

      return {
        'total': allUsers.length,
        'active': allUsers.where((u) => u.isActive).length,
        'by_role': {
          for (var role in UserRole.values)
            role.name: allUsers.where((u) => u.role == role).length,
        },
        'by_governorate': {
          for (var gov in allUsers.map((u) => u.governorate).toSet())
            gov: allUsers.where((u) => u.governorate == gov).length,
        },
      };
    } catch (e) {
      throw Exception('Failed to load user statistics: $e');
    }
  }

  // Check user permission
  Future<bool> checkPermission(
      int userId,
      SystemModule module,
      String permission,
      ) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return false;

      return user.permissions.hasPermission(module, permission);
    } catch (e) {
      return false;
    }
  }
}