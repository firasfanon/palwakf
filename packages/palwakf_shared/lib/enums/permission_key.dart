/// Canonical permission keys for PalWakf modules.
///
/// Stored as strings in DB (platform_permissions / user_system_permissions).
enum PermissionKey {
  manageUsers,
  manageHome,
  manageSite,
  manageMapLayers,
  manageLandsCrud,
  viewReports,
}

extension PermissionKeyX on PermissionKey {
  String get key => switch (this) {
    PermissionKey.manageUsers => 'manageUsers',
    PermissionKey.manageHome => 'manageHome',
    PermissionKey.manageSite => 'manageSite',
    PermissionKey.manageMapLayers => 'manageMapLayers',
    PermissionKey.manageLandsCrud => 'manageLandsCrud',
    PermissionKey.viewReports => 'viewReports',
  };

  static PermissionKey? tryParse(String? value) {
    if (value == null) return null;
    for (final p in PermissionKey.values) {
      if (p.key == value) return p;
    }
    return null;
  }
}
