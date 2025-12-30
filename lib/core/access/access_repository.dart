import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../enums/enums.dart';
import '../../data/services/supabase_service.dart';
import 'access_profile.dart';

class AccessRepository {
  final SupabaseService _supabaseService;

  AccessRepository(this._supabaseService);

  final Map<String, AccessProfile> _cache = {};

  AccessProfile? getCached(String userId) => _cache[userId];

  void clearCache() => _cache.clear();

  Future<AccessProfile?> load(String userId) async {
    if (_cache.containsKey(userId)) return _cache[userId];

    try {
      final client = _supabaseService.client;

      // admin_users is the single identity source
      // admin_users.id == auth.users.id
      final adminUser = await client
          .from('admin_users')
          .select('id,is_active,is_superuser,role')
          .eq('id', userId)
          .maybeSingle();

      final isActive = (adminUser?['is_active'] as bool?) ?? true;
      final isSuperuser = (adminUser?['is_superuser'] as bool?) == true ||
          ((adminUser?['role'] as String?)?.toLowerCase() == 'super_admin');

      // roles per system
      final rolesRows = await client
          .from('user_system_roles')
          .select('system_key,role')
          .eq('user_id', userId);

      final roles = <SystemKey, UserRole>{};
      for (final row in rolesRows as List) {
        final sk = (row['system_key'] as String?) ?? '';
        final rk = (row['role'] as String?) ?? '';
        final sys = _parseSystemKey(sk);
        final role = _parseUserRole(rk);
        if (sys != null) roles[sys] = role;
      }

      // permissions per system
      final permissions = <SystemKey, Set<Permission>>{};
      try {
        final permsRows = await client
            .from('user_system_permissions')
            .select('system_key,permission_key')
            .eq('user_id', userId);

        for (final row in permsRows as List) {
          final sys = _parseSystemKey((row['system_key'] as String?) ?? '');
          final perm = _parsePermission((row['permission_key'] as String?) ?? '');
          if (sys == null || perm == null) continue;
          permissions.putIfAbsent(sys, () => <Permission>{}).add(perm);
        }
      } catch (_) {
        // table may not exist; ignore (fail-closed by relying on roles only)
      }

      // If permissions are empty, infer minimal perms from role (still fail-closed for unknown actions)
      for (final entry in roles.entries) {
        permissions.putIfAbsent(entry.key, () => _inferRolePermissions(entry.value));
      }

      final profile = AccessProfile(
        userId: userId,
        isActive: isActive,
        isSuperuser: isSuperuser,
        roles: roles,
        permissions: permissions,
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
        return {Permission.read, Permission.create, Permission.update, Permission.delete, Permission.viewReports};
      case UserRole.user:
        return {Permission.read, Permission.create, Permission.update};
      case UserRole.viewer:
        return {Permission.read};
    }
  }

  SystemKey? _parseSystemKey(String value) {
    final v = value.trim();

    // 1) DB enum values usually match Dart enum names (e.g. 'platformAdmin')
    for (final k in SystemKey.values) {
      if (k.name == v) return k;
    }

    // 2) Accept slugs used in routes (e.g. 'admin')
    for (final k in SystemKey.values) {
      if (k.slug == v) return k;
    }

    // 3) Legacy aliases
    return switch (v) {
      'platform_admin' => SystemKey.platformAdmin,
      'platform-admin' => SystemKey.platformAdmin,
      'admin_data' => SystemKey.adminData,
      'admin-data' => SystemKey.adminData,
      _ => null,
    };
  }

  UserRole _parseUserRole(String value) {
    return switch (value) {
      'superuser' => UserRole.superuser,
      'admin' => UserRole.admin,
      'user' => UserRole.user,
      'viewer' => UserRole.viewer,
      _ => UserRole.viewer,
    };
  }

  Permission? _parsePermission(String value) {
    final v = value.trim();

    // DB sometimes uses 'view' for read.
    if (v == 'view') return Permission.read;

    for (final p in Permission.values) {
      if (p.name == v) return p;
    }
    return null;
  }
}
