/// Platform-level roles used by RBAC/RLS.
///
/// The platform stores role values as strings. Use [key] when reading/writing DB.
enum PlatformRole { superuser, admin, user, viewer }

extension PlatformRoleX on PlatformRole {
  String get key => switch (this) {
    PlatformRole.superuser => 'superuser',
    PlatformRole.admin => 'admin',
    PlatformRole.user => 'user',
    PlatformRole.viewer => 'viewer',
  };

  static PlatformRole? tryParse(String? value) {
    if (value == null) return null;
    for (final r in PlatformRole.values) {
      if (r.key == value) return r;
    }
    return null;
  }
}
