enum UserRole {
  superuser,
  admin,
  user,
  viewer,
}

extension UserRoleX on UserRole {
  bool get canWrite => this == UserRole.superuser || this == UserRole.admin || this == UserRole.user;
  bool get isAdmin => this == UserRole.superuser || this == UserRole.admin;
}
