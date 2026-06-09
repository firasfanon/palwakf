import '../enums/enums.dart';

class AccessProfile {
  final String userId;
  final bool isActive;
  final bool isSuperuser;
  final Map<SystemKey, UserRole> roles;
  final Map<SystemKey, Set<Permission>> permissions;
  final Map<String, String> dynamicRoles;
  final Map<String, Set<String>> dynamicPermissions;

  const AccessProfile({
    required this.userId,
    required this.isActive,
    required this.isSuperuser,
    required this.roles,
    required this.permissions,
    this.dynamicRoles = const <String, String>{},
    this.dynamicPermissions = const <String, Set<String>>{},
  });

  UserRole roleFor(SystemKey key) => roles[key] ?? UserRole.viewer;

  bool hasRoleAtLeast(SystemKey key, UserRole minRole) {
    if (isSuperuser) return true;
    // Fail-closed: if the user has no explicit role (and no permissions) on this system, deny.
    final hasAnyGrant =
        roles.containsKey(key) || ((permissions[key]?.isNotEmpty ?? false));
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

  bool canManagePlatformAdmin() {
    if (isSuperuser) return true;
    return can(SystemKey.platformAdmin, Permission.manageUsers) ||
        can(SystemKey.platformAdmin, Permission.manageSystems) ||
        can(SystemKey.platformAdmin, Permission.manageSite) ||
        can(SystemKey.platformAdmin, Permission.manageHome);
  }

  bool canAccessSystem(SystemKey key) {
    if (!isActive) return false;
    if (hasPlatformRootAuthority) return true;
    if (canManagePlatformAdmin()) return true;
    return hasRoleAtLeast(key, UserRole.viewer);
  }

  bool canAccessSystemByAlias(String systemKey) {
    if (!isActive) return false;
    if (hasPlatformRootAuthority) return true;
    if (canManagePlatformAdmin()) return true;
    final normalized = normalizeSystemKeyAlias(systemKey);
    if (normalized == 'awqaf_system') {
      return canAccessSystem(SystemKey.awqafSystem) ||
          canAccessDynamicSystem('awqaf_system');
    }
    for (final key in SystemKey.values) {
      if (key.name == normalized || key.slug == normalized) {
        return canAccessSystem(key);
      }
    }
    return canAccessDynamicSystem(normalized);
  }

  static String normalizeSystemKeyAlias(String systemKey) {
    final raw = systemKey.trim();
    if (raw.isEmpty) return '';
    final lower = raw.toLowerCase().replaceAll('_', '-');
    return switch (lower) {
      'awqaf-system' => 'awqaf_system',
      'awqafsystem' => 'awqaf_system',
      'awqaf' => 'awqaf_system',
      'admin-data' => 'adminData',
      'admin-data-system' => 'adminData',
      'platform-admin' => 'platformAdmin',
      'platform-admin-system' => 'platformAdmin',
      'admin' => 'platformAdmin',
      'tasks-system' => 'tasks',
      'cases-system' => 'cases',
      'billing-system' => 'billing',
      _ => raw,
    };
  }

  String? dynamicRoleFor(String systemKey) {
    final key = normalizeSystemKeyAlias(systemKey);
    if (key.isEmpty) return null;
    return dynamicRoles[key] ??
        dynamicRoles[key.replaceAll('_', '-')] ??
        dynamicRoles[key.replaceAll('-', '_')];
  }

  Set<String> dynamicPermissionSetFor(String systemKey) {
    final key = normalizeSystemKeyAlias(systemKey);
    if (key.isEmpty) return const <String>{};
    return dynamicPermissions[key] ??
        dynamicPermissions[key.replaceAll('_', '-')] ??
        dynamicPermissions[key.replaceAll('-', '_')] ??
        const <String>{};
  }

  bool get hasPlatformRootAuthority => isActive && isSuperuser;

  bool canAccessDynamicSystem(String systemKey) {
    if (!isActive) return false;
    if (hasPlatformRootAuthority) return true;
    if (canManagePlatformAdmin()) return true;
    final key = normalizeSystemKeyAlias(systemKey);
    if (key.isEmpty) return false;
    return dynamicRoleFor(key) != null ||
        dynamicPermissionSetFor(key).isNotEmpty;
  }

  bool canManageDynamicSystem(String systemKey) {
    if (!isActive) return false;
    if (hasPlatformRootAuthority) return true;
    if (canManagePlatformAdmin()) return true;
    final role = (dynamicRoleFor(systemKey) ?? '').toLowerCase();
    if (role == 'owner' ||
        role == 'admin' ||
        role == 'manager' ||
        role == 'superuser' ||
        role == 'super_admin' ||
        role == 'platform_super_admin') {
      return true;
    }
    final perms = dynamicPermissionSetFor(systemKey);
    return perms.contains('manage') ||
        perms.contains('manage_system') ||
        perms.contains('manageSystems') ||
        perms.contains('update') ||
        perms.contains('delete');
  }

  bool canAccessDynamicSection(
    String systemKey, {
    String requiredPermissionKey = 'read',
  }) {
    if (isSuperuser || canManagePlatformAdmin()) return true;
    final key = normalizeSystemKeyAlias(systemKey);
    if (!canAccessDynamicSystem(key)) return false;
    final required = requiredPermissionKey.trim().isEmpty
        ? 'read'
        : requiredPermissionKey.trim();
    final role = (dynamicRoleFor(key) ?? '').toLowerCase();
    if (role == 'owner' || role == 'admin' || role == 'manager') return true;
    if (role.isNotEmpty && required == 'read') return true;
    final perms = dynamicPermissionSetFor(key);
    return perms.contains(required) ||
        perms.contains(required.replaceAll('_', '-')) ||
        perms.contains(required.replaceAll('-', '_')) ||
        perms.contains('manage') ||
        perms.contains('read');
  }

  bool canManageSystem(SystemKey key) {
    if (isSuperuser) return true;
    if (canManagePlatformAdmin()) return true;
    if (hasRoleAtLeast(key, UserRole.admin)) return true;
    final perms = permissions[key] ?? const <Permission>{};
    return perms.contains(Permission.update) ||
        perms.contains(Permission.delete);
  }

  bool canWriteSystem(SystemKey key) {
    if (canManageSystem(key)) return true;
    final perms = permissions[key] ?? const <Permission>{};
    return perms.contains(Permission.create) ||
        perms.contains(Permission.update) ||
        hasRoleAtLeast(key, UserRole.user);
  }
}
