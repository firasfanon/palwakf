import 'dart:async';

import 'package:flutter/foundation.dart';
import '../enums/enums.dart';
import '../../data/services/supabase_service.dart';
import 'access_profile.dart';

class AccessRepository {
  final SupabaseService _supabaseService;

  AccessRepository(this._supabaseService);

  final Map<String, AccessProfile> _cache = {};

  static const String _userSystemRolesReadSurface =
      'v_platform_user_system_roles_compat_v1';
  static const String _userSystemPermissionsReadSurface =
      'v_platform_user_system_permissions_compat_v1';
  static const String _coreAdminUsersReadSurface =
      'v_core_admin_users_compat_v1';

  AccessProfile? getCached(String userId) => _cache[userId];

  void clearCache() => _cache.clear();

  Future<AccessProfile?> load(String userId) async {
    if (_cache.containsKey(userId)) return _cache[userId];

    try {
      final client = _supabaseService.client;

      // Core/admin profile is read through the public compatibility
      // wrapper. auth.users remains the Supabase Auth identity source.
      final adminUser = await client
          .from(_coreAdminUsersReadSurface)
          .select('id,is_active,is_superuser,role')
          .eq('id', userId)
          .maybeSingle();

      if (adminUser == null) {
        return null;
      }

      final isActive = (adminUser['is_active'] as bool?) ?? true;
      // Platform root authority must be explicit.
      // Do not treat legacy admin_users.role = super_admin as root by itself;
      // several scoped/unit actors may carry historical labels while their
      // effective grants remain unit-bound.
      var isSuperuser = (adminUser['is_superuser'] as bool?) == true;

      // Roles per system are read through the public compatibility wrapper.
      // Do not call legacy/direct PostgREST tables here; the dashboard must remain
      // console-clean even when optional platform dynamic tables are absent or have
      // a different historical shape.
      final rolesRows = await client
          .from(_userSystemRolesReadSurface)
          .select('system_key,role')
          .eq('user_id', userId);

      final roles = <SystemKey, UserRole>{};
      final dynamicRoles = <String, String>{};
      for (final row in rolesRows as List) {
        final sk = (row['system_key'] as String?) ?? '';
        final rk = (row['role'] as String?) ?? '';
        final sys = _parseSystemKey(sk);
        final role = _parseUserRole(rk);
        if (sys != null) roles[sys] = role;

        final dynamicSystemKey = _normalizeDynamicSystemKey(sk);
        final dynamicRoleKey = rk.trim();
        if (dynamicSystemKey.isNotEmpty && dynamicRoleKey.isNotEmpty) {
          dynamicRoles[dynamicSystemKey] = dynamicRoleKey;
        }
      }

      // Permissions per system are also read through the compatibility wrapper.
      final permissions = <SystemKey, Set<Permission>>{};
      final dynamicPermissions = <String, Set<String>>{};
      try {
        final permsRows = await client
            .from(_userSystemPermissionsReadSurface)
            .select('system_key,permission_key,allow')
            .eq('user_id', userId);

        for (final row in permsRows as List) {
          final rawSystemKey = (row['system_key'] as String?) ?? '';
          final rawPermissionKey = (row['permission_key'] as String?) ?? '';
          final sys = _parseSystemKey(rawSystemKey);
          final perm = _parsePermission(rawPermissionKey);
          final allowed = (row['allow'] as bool?) ?? true;
          if (sys != null && perm != null && allowed) {
            permissions.putIfAbsent(sys, () => <Permission>{}).add(perm);
          }

          final dynamicSystemKey = _normalizeDynamicSystemKey(rawSystemKey);
          final dynamicPermissionKey =
              _normalizePermissionAlias(rawPermissionKey);
          if (dynamicSystemKey.isNotEmpty &&
              dynamicPermissionKey.isNotEmpty &&
              allowed) {
            dynamicPermissions
                .putIfAbsent(dynamicSystemKey, () => <String>{})
                .add(dynamicPermissionKey);
          }
        }
      } catch (_) {
        // Compatibility surface may not exist yet in very early environments;
        // keep fail-closed by relying on roles only.
      }

      // If permissions are empty, infer minimal perms from role (still fail-closed for unknown actions)
      for (final entry in roles.entries) {
        permissions.putIfAbsent(
            entry.key, () => _inferRolePermissions(entry.value));
      }

      if (roles[SystemKey.platformAdmin] == UserRole.superuser ||
          _isRootRoleAlias(dynamicRoles['platformAdmin'] ?? '') ||
          _isRootRoleAlias(dynamicRoles['admin'] ?? '') ||
          _isRootRoleAlias(dynamicRoles['platform_admin'] ?? '')) {
        isSuperuser = true;
      }

      final profile = AccessProfile(
        userId: userId,
        isActive: isActive,
        isSuperuser: isSuperuser,
        roles: roles,
        permissions: permissions,
        dynamicRoles: dynamicRoles,
        dynamicPermissions: dynamicPermissions,
      );

      _cache[userId] = profile;
      return profile;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AccessRepository.load failed: $e');
      }
      return null;
    }
  }

  Set<Permission> _inferRolePermissions(UserRole role) {
    // conservative defaults
    switch (role) {
      case UserRole.superuser:
        return Permission.values.toSet();
      case UserRole.admin:
        return {
          Permission.read,
          Permission.create,
          Permission.update,
          Permission.delete,
          Permission.viewReports
        };
      case UserRole.user:
        return {Permission.read, Permission.create, Permission.update};
      case UserRole.viewer:
        return {Permission.read};
    }
  }

  SystemKey? _parseSystemKey(String value) {
    final v = value.trim();
    final normalized = _normalizeDynamicSystemKey(v);

    // 1) DB enum values usually match Dart enum names (e.g. 'platformAdmin')
    for (final k in SystemKey.values) {
      if (k.name == v || k.name == normalized) return k;
    }

    // 2) Accept slugs used in routes (e.g. 'admin')
    for (final k in SystemKey.values) {
      if (k.slug == v || k.slug == normalized) return k;
    }

    // 3) Legacy aliases
    return switch (v) {
      'platform_admin' => SystemKey.platformAdmin,
      'platform-admin' => SystemKey.platformAdmin,
      'admin_data' => SystemKey.adminData,
      'admin-data' => SystemKey.adminData,
      'awqaf_system' => SystemKey.awqafSystem,
      'awqaf-system' => SystemKey.awqafSystem,
      'awqafSystem' => SystemKey.awqafSystem,
      'awqaf' => SystemKey.awqafSystem,
      _ => null,
    };
  }

  UserRole _parseUserRole(String value) {
    return switch (value.trim().toLowerCase()) {
      'superuser' => UserRole.superuser,
      'super_admin' => UserRole.superuser,
      'super-user' => UserRole.superuser,
      'super_user' => UserRole.superuser,
      'super-admin' => UserRole.superuser,
      'platform_super_admin' => UserRole.superuser,
      'platform-super-admin' => UserRole.superuser,
      'root' => UserRole.superuser,
      'owner' => UserRole.superuser,
      'admin' => UserRole.admin,
      'manager' => UserRole.admin,
      'employee' => UserRole.user,
      'user' => UserRole.user,
      'viewer' => UserRole.viewer,
      _ => UserRole.viewer,
    };
  }

  Permission? _parsePermission(String value) {
    final v = value.trim();

    final normalized = _normalizePermissionAlias(v);

    // DB sometimes uses 'view' for read.
    if (normalized == 'view') return Permission.read;

    for (final p in Permission.values) {
      if (p.name == normalized || p.name == v) return p;
    }
    return null;
  }

  bool _isRootRoleAlias(String value) {
    return switch (value.trim().toLowerCase().replaceAll('-', '_')) {
      'superuser' => true,
      'super_user' => true,
      'super_admin' => true,
      'platform_super_admin' => true,
      'platform_root' => true,
      'root' => true,
      'owner' => true,
      _ => false,
    };
  }

  String _normalizeDynamicSystemKey(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return '';
    final normalized = raw.toLowerCase().replaceAll('-', '_');
    return switch (normalized) {
      'awqafsystem' => 'awqaf_system',
      'awqaf' => 'awqaf_system',
      'awqaf_system' => 'awqaf_system',
      'platform_admin' => 'platformAdmin',
      'platformadmin' => 'platformAdmin',
      'admin' => 'platformAdmin',
      'admin_data' => 'adminData',
      'admindata' => 'adminData',
      'tasks_system' => 'tasks',
      'cases_system' => 'cases',
      'billing_system' => 'billing',
      _ => raw,
    };
  }

  String _normalizePermissionAlias(String value) {
    final normalized = value.trim().replaceAll('-', '_');
    return switch (normalized) {
      'view' => 'read',
      'manage_users' => 'manageUsers',
      'manage_systems' => 'manageSystems',
      'manage_site' => 'manageSite',
      'manage_home' => 'manageHome',
      'view_reports' => 'viewReports',
      'manage_zakat' => 'manageZakat',
      'manage_prayer_times' => 'managePrayerTimes',
      'manage_quran' => 'manageQuran',
      'manage_map_layers' => 'manageMapLayers',
      'manage_lands_crud' => 'manageLandsCrud',
      _ => value.trim(),
    };
  }
}
