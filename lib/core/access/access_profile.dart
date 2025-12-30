import '../enums/enums.dart';

class AccessProfile {
  final String userId;
  final bool isActive;
  final bool isSuperuser;
  final Map<SystemKey, UserRole> roles;
  final Map<SystemKey, Set<Permission>> permissions;

  const AccessProfile({
    required this.userId,
    required this.isActive,
    required this.isSuperuser,
    required this.roles,
    required this.permissions,
  });

  UserRole roleFor(SystemKey key) => roles[key] ?? UserRole.viewer;

  bool hasRoleAtLeast(SystemKey key, UserRole minRole) {
    if (isSuperuser) return true;
    // Fail-closed: if the user has no explicit role (and no permissions) on this system, deny.
    final hasAnyGrant = roles.containsKey(key) || ((permissions[key]?.isNotEmpty ?? false));
    if (!hasAnyGrant) return false;
    final role = roleFor(key);
    const order = {
      UserRole.viewer: 0,
      UserRole.user: 1,
      UserRole.admin: 2,
      UserRole.superuser: 3,
    };
    return (order[role] ?? 0) >= (order[minRole] ?? 0);
  }

  bool can(SystemKey key, Permission permission) {
    if (isSuperuser) return true;
    final perms = permissions[key] ?? const <Permission>{};
    return perms.contains(permission);
  }
}
