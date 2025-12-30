import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserRole {
  @JsonValue('super_admin')
  superAdmin,
  @JsonValue('admin')
  admin,
  @JsonValue('manager')
  manager,
  @JsonValue('employee')
  employee,
  @JsonValue('viewer')
  viewer,
}

enum SystemModule {
  @JsonValue('cases_management')
  casesManagement,
  @JsonValue('waqf_lands')
  waqfLands,
  @JsonValue('documents')
  documents,
  @JsonValue('archive')
  archive,
  @JsonValue('gis')
  gis,
  @JsonValue('users')
  users,
  @JsonValue('reports')
  reports,
  @JsonValue('settings')
  settings,
  @JsonValue('appointments')
  appointments,
  @JsonValue('notifications')
  notifications,
}

@JsonSerializable()
class User {
  final int id;
  final String email;
  final String name;
  final UserRole role;
  final String department;
  final String governorate;
  final String? phone;
  final String? avatarUrl;
  final bool isActive;
  final DateTime? lastLogin;
  final UserPermissions permissions;
  final SecuritySettings security;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.department,
    required this.governorate,
    this.phone,
    this.avatarUrl,
    this.isActive = true,
    this.lastLogin,
    required this.permissions,
    required this.security,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? id,
    String? email,
    String? name,
    UserRole? role,
    String? department,
    String? governorate,
    String? phone,
    String? avatarUrl,
    bool? isActive,
    DateTime? lastLogin,
    UserPermissions? permissions,
    SecuritySettings? security,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      department: department ?? this.department,
      governorate: governorate ?? this.governorate,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      permissions: permissions ?? this.permissions,
      security: security ?? this.security,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class UserPermissions {
  final Map<String, ModulePermission> modules;
  final List<String> governorates;
  final bool isActive;

  const UserPermissions({
    required this.modules,
    required this.governorates,
    this.isActive = true,
  });

  factory UserPermissions.fromJson(Map<String, dynamic> json) =>
      _$UserPermissionsFromJson(json);
  Map<String, dynamic> toJson() => _$UserPermissionsToJson(this);

  UserPermissions copyWith({
    Map<String, ModulePermission>? modules,
    List<String>? governorates,
    bool? isActive,
  }) {
    return UserPermissions(
      modules: modules ?? this.modules,
      governorates: governorates ?? this.governorates,
      isActive: isActive ?? this.isActive,
    );
  }

  bool hasPermission(SystemModule module, String permission) {
    final modulePermission = modules[module.name];
    if (modulePermission == null) return false;
    return modulePermission.permissions.contains(permission);
  }

  bool canAccessGovernorate(String governorate) {
    return governorates.contains(governorate) || governorates.contains('all');
  }
}

@JsonSerializable()
class ModulePermission {
  final SystemModule module;
  final List<String> permissions;
  final bool governorateRestricted;
  final List<String> allowedGovernorates;

  const ModulePermission({
    required this.module,
    required this.permissions,
    this.governorateRestricted = false,
    this.allowedGovernorates = const [],
  });

  factory ModulePermission.fromJson(Map<String, dynamic> json) =>
      _$ModulePermissionFromJson(json);
  Map<String, dynamic> toJson() => _$ModulePermissionToJson(this);

  ModulePermission copyWith({
    SystemModule? module,
    List<String>? permissions,
    bool? governorateRestricted,
    List<String>? allowedGovernorates,
  }) {
    return ModulePermission(
      module: module ?? this.module,
      permissions: permissions ?? this.permissions,
      governorateRestricted: governorateRestricted ?? this.governorateRestricted,
      allowedGovernorates: allowedGovernorates ?? this.allowedGovernorates,
    );
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  bool canAccessGovernorate(String governorate) {
    if (!governorateRestricted) return true;
    return allowedGovernorates.contains(governorate) ||
        allowedGovernorates.contains('all');
  }
}

@JsonSerializable()
class SecuritySettings {
  final bool twoFactorEnabled;
  final bool emailNotifications;
  final bool smsNotifications;
  final DateTime? passwordChangedAt;
  final int failedLoginAttempts;
  final DateTime? lastFailedLogin;
  final bool accountLocked;
  final DateTime? lockedUntil;

  const SecuritySettings({
    this.twoFactorEnabled = false,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.passwordChangedAt,
    this.failedLoginAttempts = 0,
    this.lastFailedLogin,
    this.accountLocked = false,
    this.lockedUntil,
  });

  factory SecuritySettings.fromJson(Map<String, dynamic> json) =>
      _$SecuritySettingsFromJson(json);
  Map<String, dynamic> toJson() => _$SecuritySettingsToJson(this);

  SecuritySettings copyWith({
    bool? twoFactorEnabled,
    bool? emailNotifications,
    bool? smsNotifications,
    DateTime? passwordChangedAt,
    int? failedLoginAttempts,
    DateTime? lastFailedLogin,
    bool? accountLocked,
    DateTime? lockedUntil,
  }) {
    return SecuritySettings(
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      lastFailedLogin: lastFailedLogin ?? this.lastFailedLogin,
      accountLocked: accountLocked ?? this.accountLocked,
      lockedUntil: lockedUntil ?? this.lockedUntil,
    );
  }

  bool get isPasswordExpired {
    if (passwordChangedAt == null) return true;
    final daysSinceChange = DateTime.now().difference(passwordChangedAt!).inDays;
    return daysSinceChange > 90; // Password expires after 90 days
  }

  bool get isAccountLocked {
    if (!accountLocked) return false;
    if (lockedUntil == null) return true;
    return DateTime.now().isBefore(lockedUntil!);
  }
}

// Extensions for display names
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'مدير عام';
      case UserRole.admin:
        return 'مدير';
      case UserRole.manager:
        return 'مدير قسم';
      case UserRole.employee:
        return 'موظف';
      case UserRole.viewer:
        return 'مشاهد';
    }
  }

  String get displayNameEn {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.employee:
        return 'Employee';
      case UserRole.viewer:
        return 'Viewer';
    }
  }

  List<String> get defaultPermissions {
    switch (this) {
      case UserRole.superAdmin:
        return ['create', 'read', 'update', 'delete', 'manage', 'admin'];
      case UserRole.admin:
        return ['create', 'read', 'update', 'delete', 'manage'];
      case UserRole.manager:
        return ['create', 'read', 'update', 'delete'];
      case UserRole.employee:
        return ['create', 'read', 'update'];
      case UserRole.viewer:
        return ['read'];
    }
  }

  bool canAccessModule(SystemModule module) {
    switch (this) {
      case UserRole.superAdmin:
        return true;
      case UserRole.admin:
        return true;
      case UserRole.manager:
        return module != SystemModule.users && module != SystemModule.settings;
      case UserRole.employee:
        return module != SystemModule.users &&
            module != SystemModule.settings &&
            module != SystemModule.reports;
      case UserRole.viewer:
        return module == SystemModule.documents ||
            module == SystemModule.archive ||
            module == SystemModule.waqfLands;
    }
  }
}

extension SystemModuleExtension on SystemModule {
  String get displayName {
    switch (this) {
      case SystemModule.casesManagement:
        return 'إدارة القضايا';
      case SystemModule.waqfLands:
        return 'الأراضي الوقفية';
      case SystemModule.documents:
        return 'إدارة الوثائق';
      case SystemModule.archive:
        return 'الأرشيف';
      case SystemModule.gis:
        return 'نظم المعلومات الجغرافية';
      case SystemModule.users:
        return 'إدارة المستخدمين';
      case SystemModule.reports:
        return 'التقارير';
      case SystemModule.settings:
        return 'الإعدادات';
      case SystemModule.appointments:
        return 'المواعيد';
      case SystemModule.notifications:
        return 'الإشعارات';
    }
  }

  String get displayNameEn {
    switch (this) {
      case SystemModule.casesManagement:
        return 'Cases Management';
      case SystemModule.waqfLands:
        return 'Waqf Lands';
      case SystemModule.documents:
        return 'Document Management';
      case SystemModule.archive:
        return 'Archive';
      case SystemModule.gis:
        return 'GIS';
      case SystemModule.users:
        return 'User Management';
      case SystemModule.reports:
        return 'Reports';
      case SystemModule.settings:
        return 'Settings';
      case SystemModule.appointments:
        return 'Appointments';
      case SystemModule.notifications:
        return 'Notifications';
    }
  }

  List<String> get availablePermissions {
    switch (this) {
      case SystemModule.users:
      case SystemModule.settings:
        return ['read', 'update', 'admin'];
      case SystemModule.reports:
        return ['read', 'create', 'export'];
      case SystemModule.archive:
        return ['read', 'search', 'export'];
      default:
        return ['create', 'read', 'update', 'delete'];
    }
  }
}