import 'package:flutter/foundation.dart';

import '../enums/enums.dart';
import '../../data/services/supabase_service.dart';
import 'access_profile.dart';
import 'platform_effective_authority.dart';

class AccessRepository {
  AccessRepository(this._supabaseService);

  final SupabaseService _supabaseService;
  final Map<String, AccessProfile> _cache = {};

  static const String _userSystemRolesReadSurface =
      'v_platform_user_system_roles_compat_v1';
  static const String _userSystemPermissionsReadSurface =
      'v_platform_user_system_permissions_compat_v1';
  static const String _coreAdminUsersReadSurface =
      'v_core_admin_users_compat_v1';
  static const String _effectiveAuthorityRpc =
      'rpc_platform_effective_authority_v1';

  AccessProfile? getCached(String userId) => _cache[userId];

  void clearCache() => _cache.clear();

  void invalidate(String userId) => _cache.remove(userId);

  Future<AccessProfile?> refresh(String userId) =>
      load(userId, forceRefresh: true);

  Future<AccessProfile?> load(
    String userId, {
    bool forceRefresh = false,
  }) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) return null;
    if (forceRefresh) invalidate(normalizedUserId);
    if (_cache.containsKey(normalizedUserId)) return _cache[normalizedUserId];

    try {
      final client = _supabaseService.client;

      // The owner-side contract is self-scoped by auth.uid(). It is always
      // evaluated before legacy compatibility views. A verified universal
      // Super Admin must not depend on optional system-role rows or unit scope
      // assignments merely to access route, sidebar, and system UI guards.
      final effectiveAuthority =
          await _loadEffectiveAuthority(client, normalizedUserId);
      if (effectiveAuthority?.isUniversalSuperAdmin == true) {
        final profile = _buildUniversalSuperAdminProfile(normalizedUserId);
        _cache[normalizedUserId] = profile;
        return profile;
      }

      // Compatibility data remains the ordinary-user fallback only.
      final adminUser = await client
          .from(_coreAdminUsersReadSurface)
          .select('id,is_active,is_superuser,role')
          .eq('id', normalizedUserId)
          .maybeSingle();

      if (adminUser == null && effectiveAuthority == null) return null;

      final isActive = effectiveAuthority?.isActive ??
          ((adminUser?['is_active'] as bool?) ?? false);

      final rolesRows = await client
          .from(_userSystemRolesReadSurface)
          .select('system_key,role')
          .eq('user_id', normalizedUserId);

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

      final permissions = <SystemKey, Set<Permission>>{};
      final dynamicPermissions = <String, Set<String>>{};
      try {
        final permsRows = await client
            .from(_userSystemPermissionsReadSurface)
            .select('system_key,permission_key,allow')
            .eq('user_id', normalizedUserId);

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
        // Compatibility permissions are optional for ordinary legacy accounts.
        // The profile remains fail-closed through explicit roles only.
      }

      for (final entry in roles.entries) {
        permissions.putIfAbsent(
          entry.key,
          () => _inferRolePermissions(entry.value),
        );
      }

      // Compatibility rows may represent elevated roles inside one system,
      // but they never establish universal platform authority. Only the
      // owner-side self-authority RPC above can produce isSuperuser=true.

      final profile = AccessProfile(
        userId: normalizedUserId,
        isActive: isActive,
        isSuperuser: false,
        roles: roles,
        permissions: permissions,
        dynamicRoles: dynamicRoles,
        dynamicPermissions: dynamicPermissions,
      );
      _cache[normalizedUserId] = profile;
      return profile;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AccessRepository.load failed: $error');
      }
      return null;
    }
  }

  Future<PlatformEffectiveAuthority?> _loadEffectiveAuthority(
    dynamic client,
    String expectedUserId,
  ) async {
    try {
      // Do not pass a user id. The SQL function has no parameters and derives
      // its actor exclusively from auth.uid().
      final response = await client.rpc(_effectiveAuthorityRpc);
      final rows = response is List
          ? response
          : response is Map
              ? <dynamic>[response]
              : const <dynamic>[];
      if (rows.isEmpty || rows.first is! Map) return null;

      final authority = PlatformEffectiveAuthority.fromJson(
        Map<String, dynamic>.from(rows.first as Map),
      );
      return authority.belongsTo(expectedUserId) ? authority : null;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AccessRepository effective authority fallback: $error');
      }
      return null;
    }
  }

  AccessProfile _buildUniversalSuperAdminProfile(String userId) {
    final roles = <SystemKey, UserRole>{
      for (final system in SystemKey.values) system: UserRole.superuser,
    };
    final permissions = <SystemKey, Set<Permission>>{
      for (final system in SystemKey.values) system: Permission.values.toSet(),
    };
    return AccessProfile(
      userId: userId,
      isActive: true,
      isSuperuser: true,
      roles: roles,
      permissions: permissions,
      dynamicRoles: const <String, String>{'*': 'super_admin'},
      dynamicPermissions: <String, Set<String>>{
        '*': <String>{
          'read',
          'create',
          'update',
          'delete',
          'manage',
          'manageSystems',
          'manageUsers',
          'manageSite',
          'manageHome',
          'publish',
          'activate',
        },
      },
    );
  }

  Set<Permission> _inferRolePermissions(UserRole role) {
    switch (role) {
      case UserRole.superuser:
        return Permission.values.toSet();
      case UserRole.admin:
        return {
          Permission.read,
          Permission.create,
          Permission.update,
          Permission.delete,
          Permission.viewReports,
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

    for (final k in SystemKey.values) {
      if (k.name == v || k.name == normalized) return k;
    }
    for (final k in SystemKey.values) {
      if (k.slug == v || k.slug == normalized) return k;
    }
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
    if (normalized == 'view') return Permission.read;
    for (final p in Permission.values) {
      if (p.name == normalized || p.name == v) return p;
    }
    return null;
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
