import 'access_profile.dart';

/// Platform contract for access/RBAC resolution.
///
/// In the platform app, this is implemented using Supabase + RLS-backed tables:
/// - admin_users (identity)
/// - user_system_roles / user_system_permissions
/// - platform_permissions / platform_systems
abstract class AccessRepository {
  /// Return the current signed-in user's resolved access profile.
  Future<AccessProfile?> getCurrentAccessProfile();

  /// Force refresh (e.g. after role updates).
  Future<AccessProfile?> refreshCurrentAccessProfile();
}
