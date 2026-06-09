import '../enums/permission.dart';
import '../enums/system_key.dart';

/// Runtime access profile for the current signed-in user.
///
/// This is intentionally DB-agnostic so it can be reused across modules.
class AccessProfile {
  const AccessProfile({
    required this.userId,
    required this.email,
    required this.systemKeys,
    required this.permissions,
    this.isSuperUser = false,
  });

  final String userId;
  final String email;

  /// Systems enabled for the user (e.g. awqaf_system, mustakshif).
  final Set<SystemKey> systemKeys;

  /// Flat permission set aggregated from platform + system permissions.
  final Set<Permission> permissions;

  final bool isSuperUser;

  bool hasPermission(Permission permission) =>
      isSuperUser || permissions.contains(permission);

  bool hasAnyPermission(Iterable<Permission> perms) =>
      isSuperUser || perms.any(permissions.contains);

  bool canAccessSystem(SystemKey systemKey) =>
      isSuperUser || systemKeys.contains(systemKey);

  bool canAccessSystemKey(String rawSystemKey) {
    if (isSuperUser) return true;
    final normalized = rawSystemKey.trim().toLowerCase().replaceAll('_', '-');
    for (final key in systemKeys) {
      if (key.name.toLowerCase() == normalized ||
          key.slug.toLowerCase() == normalized ||
          key.name.toLowerCase().replaceAll('_', '-') == normalized) {
        return true;
      }
    }
    return normalized == 'awqaf-system' &&
        systemKeys.contains(SystemKey.awqafSystem);
  }
}
