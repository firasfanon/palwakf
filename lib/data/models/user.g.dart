// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      name: json['name'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      department: json['department'] as String,
      governorate: json['governorate'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      lastLogin: json['lastLogin'] == null
          ? null
          : DateTime.parse(json['lastLogin'] as String),
      permissions:
          UserPermissions.fromJson(json['permissions'] as Map<String, dynamic>),
      security:
          SecuritySettings.fromJson(json['security'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'role': _$UserRoleEnumMap[instance.role]!,
      'department': instance.department,
      'governorate': instance.governorate,
      'phone': instance.phone,
      'avatarUrl': instance.avatarUrl,
      'isActive': instance.isActive,
      'lastLogin': instance.lastLogin?.toIso8601String(),
      'permissions': instance.permissions,
      'security': instance.security,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.superAdmin: 'super_admin',
  UserRole.admin: 'admin',
  UserRole.manager: 'manager',
  UserRole.employee: 'employee',
  UserRole.viewer: 'viewer',
};

UserPermissions _$UserPermissionsFromJson(Map<String, dynamic> json) =>
    UserPermissions(
      modules: (json['modules'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, ModulePermission.fromJson(e as Map<String, dynamic>)),
      ),
      governorates: (json['governorates'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$UserPermissionsToJson(UserPermissions instance) =>
    <String, dynamic>{
      'modules': instance.modules,
      'governorates': instance.governorates,
      'isActive': instance.isActive,
    };

ModulePermission _$ModulePermissionFromJson(Map<String, dynamic> json) =>
    ModulePermission(
      module: $enumDecode(_$SystemModuleEnumMap, json['module']),
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      governorateRestricted: json['governorateRestricted'] as bool? ?? false,
      allowedGovernorates: (json['allowedGovernorates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ModulePermissionToJson(ModulePermission instance) =>
    <String, dynamic>{
      'module': _$SystemModuleEnumMap[instance.module]!,
      'permissions': instance.permissions,
      'governorateRestricted': instance.governorateRestricted,
      'allowedGovernorates': instance.allowedGovernorates,
    };

const _$SystemModuleEnumMap = {
  SystemModule.casesManagement: 'cases_management',
  SystemModule.waqfLands: 'waqf_lands',
  SystemModule.documents: 'documents',
  SystemModule.archive: 'archive',
  SystemModule.gis: 'gis',
  SystemModule.users: 'users',
  SystemModule.reports: 'reports',
  SystemModule.settings: 'settings',
  SystemModule.appointments: 'appointments',
  SystemModule.notifications: 'notifications',
};

SecuritySettings _$SecuritySettingsFromJson(Map<String, dynamic> json) =>
    SecuritySettings(
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      smsNotifications: json['smsNotifications'] as bool? ?? false,
      passwordChangedAt: json['passwordChangedAt'] == null
          ? null
          : DateTime.parse(json['passwordChangedAt'] as String),
      failedLoginAttempts: (json['failedLoginAttempts'] as num?)?.toInt() ?? 0,
      lastFailedLogin: json['lastFailedLogin'] == null
          ? null
          : DateTime.parse(json['lastFailedLogin'] as String),
      accountLocked: json['accountLocked'] as bool? ?? false,
      lockedUntil: json['lockedUntil'] == null
          ? null
          : DateTime.parse(json['lockedUntil'] as String),
    );

Map<String, dynamic> _$SecuritySettingsToJson(SecuritySettings instance) =>
    <String, dynamic>{
      'twoFactorEnabled': instance.twoFactorEnabled,
      'emailNotifications': instance.emailNotifications,
      'smsNotifications': instance.smsNotifications,
      'passwordChangedAt': instance.passwordChangedAt?.toIso8601String(),
      'failedLoginAttempts': instance.failedLoginAttempts,
      'lastFailedLogin': instance.lastFailedLogin?.toIso8601String(),
      'accountLocked': instance.accountLocked,
      'lockedUntil': instance.lockedUntil?.toIso8601String(),
    };
