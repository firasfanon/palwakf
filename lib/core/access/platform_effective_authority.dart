class PlatformEffectiveAuthority {
  final String userId;
  final bool isUniversalSuperAdmin;
  final bool isActive;

  const PlatformEffectiveAuthority({
    required this.userId,
    required this.isUniversalSuperAdmin,
    required this.isActive,
  });

  factory PlatformEffectiveAuthority.fromJson(Map<String, dynamic> json) {
    return PlatformEffectiveAuthority(
      userId: (json['user_id'] ?? json['id'] ?? '').toString().trim(),
      isUniversalSuperAdmin:
          (json['is_universal_super_admin'] ?? json['is_superuser'] ?? false)
              == true,
      isActive: (json['is_active'] ?? true) == true,
    );
  }

  bool belongsTo(String expectedUserId) =>
      userId.isNotEmpty && userId == expectedUserId.trim();
}
