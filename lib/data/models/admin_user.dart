// lib/data/models/admin_user.dart
class AdminUser {
  final String id; // UUID from Supabase Auth
  final String email;
  final String name;
  final String role;
  final String? username;
  final String? department;
  final String? unitId;
  final String? unitSlug;
  final String? unitNameAr;
  final List<String> scopeRoleKeys;
  final List<String> assignedSystemKeys;
  final List<String> assignedUnitIds;
  final List<String> assignedUnitNamesAr;
  final String? primaryScopeRoleKey;
  final String? primaryScopeSystemKey;
  final bool isActive;
  final bool isSuperuser;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.username,
    this.department,
    this.unitId,
    this.unitSlug,
    this.unitNameAr,
    this.scopeRoleKeys = const [],
    this.assignedSystemKeys = const [],
    this.assignedUnitIds = const [],
    this.assignedUnitNamesAr = const [],
    this.primaryScopeRoleKey,
    this.primaryScopeSystemKey,
    this.isActive = true,
    this.isSuperuser = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create AdminUser from Supabase JSON
  factory AdminUser.fromJson(Map<String, dynamic> json) {
    List<String> _toStringList(dynamic value) {
      if (value is List) {
        return value
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();
      }
      return const <String>[];
    }

    return AdminUser(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      username: json['username']?.toString(),
      department: json['department']?.toString(),
      unitId: json['unit_id']?.toString(),
      unitSlug: json['unit_slug']?.toString(),
      unitNameAr: json['unit_name_ar']?.toString(),
      scopeRoleKeys: _toStringList(json['scope_role_keys']),
      assignedSystemKeys: _toStringList(json['assigned_system_keys']),
      assignedUnitIds: _toStringList(json['assigned_unit_ids']),
      assignedUnitNamesAr: _toStringList(json['assigned_unit_names_ar']),
      primaryScopeRoleKey: json['primary_scope_role_key']?.toString(),
      primaryScopeSystemKey: json['primary_scope_system_key']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      isSuperuser: json['is_superuser'] as bool? ?? false,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  /// Convert AdminUser to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'username': username,
      'department': department,
      'unit_id': unitId,
      'unit_slug': unitSlug,
      'unit_name_ar': unitNameAr,
      'scope_role_keys': scopeRoleKeys,
      'assigned_system_keys': assignedSystemKeys,
      'assigned_unit_ids': assignedUnitIds,
      'assigned_unit_names_ar': assignedUnitNamesAr,
      'primary_scope_role_key': primaryScopeRoleKey,
      'primary_scope_system_key': primaryScopeSystemKey,
      'is_active': isActive,
      'is_superuser': isSuperuser,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  AdminUser copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? username,
    String? department,
    String? unitId,
    String? unitSlug,
    String? unitNameAr,
    List<String>? scopeRoleKeys,
    List<String>? assignedSystemKeys,
    List<String>? assignedUnitIds,
    List<String>? assignedUnitNamesAr,
    String? primaryScopeRoleKey,
    String? primaryScopeSystemKey,
    bool? isActive,
    bool? isSuperuser,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      username: username ?? this.username,
      department: department ?? this.department,
      unitId: unitId ?? this.unitId,
      unitSlug: unitSlug ?? this.unitSlug,
      unitNameAr: unitNameAr ?? this.unitNameAr,
      scopeRoleKeys: scopeRoleKeys ?? this.scopeRoleKeys,
      assignedSystemKeys: assignedSystemKeys ?? this.assignedSystemKeys,
      assignedUnitIds: assignedUnitIds ?? this.assignedUnitIds,
      assignedUnitNamesAr: assignedUnitNamesAr ?? this.assignedUnitNamesAr,
      primaryScopeRoleKey: primaryScopeRoleKey ?? this.primaryScopeRoleKey,
      primaryScopeSystemKey:
          primaryScopeSystemKey ?? this.primaryScopeSystemKey,
      isActive: isActive ?? this.isActive,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isCentral => (unitId ?? '').trim().isEmpty;
  Set<String> get effectiveUnitIds => {
        if ((unitId ?? '').trim().isNotEmpty) unitId!.trim(),
        ...assignedUnitIds.map((e) => e.trim()).where((e) => e.isNotEmpty),
      };
  Set<String> get effectiveSystemKeys => assignedSystemKeys
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toSet();
  String get displayName => name.trim().isNotEmpty
      ? name
      : (username?.trim().isNotEmpty == true ? username!.trim() : email);
  String get scopeLabel {
    if (assignedUnitNamesAr.isNotEmpty) {
      if (assignedUnitNamesAr.length == 1) return assignedUnitNamesAr.first;
      if (assignedUnitNamesAr.length <= 3)
        return assignedUnitNamesAr.join('، ');
      return '${assignedUnitNamesAr.take(3).join('، ')} +${assignedUnitNamesAr.length - 3}';
    }
    return isCentral
        ? 'مركزي'
        : ((unitNameAr?.trim().isNotEmpty == true)
            ? unitNameAr!.trim()
            : ((unitSlug?.trim().isNotEmpty == true)
                ? unitSlug!.trim()
                : (department?.trim().isNotEmpty == true
                    ? department!.trim()
                    : 'وحدوي')));
  }

  /// Any record in admin_users is an administrative account.
  String get normalizedRole => role.trim().toLowerCase();

  bool get isAdmin => true;
  bool get isStaff => normalizedRole == 'employee';
  bool get isModerator => normalizedRole == 'manager';

  /// Global root authority must be explicit.
  ///
  /// A legacy `role = super_admin` value can still be shown in audit/history,
  /// but it must not by itself elevate a scoped unit administrator to a
  /// platform superuser. The authoritative runtime flag is `is_superuser=true`
  /// or a platformAdmin superuser grant resolved by AccessProfile.
  bool get isProtectedSuperuser => isSuperuser;

  bool get hasLegacySuperAdminRole => normalizedRole == 'super_admin';

  bool get hasDelegateHint {
    final source =
        '${name.toLowerCase()} ${(department ?? '').toLowerCase()} ${(username ?? '').toLowerCase()} ${email.toLowerCase()}';
    return source.contains('محامي') ||
        source.contains('وكيل') ||
        source.contains('lawyer') ||
        source.contains('delegate') ||
        source.contains('counsel');
  }

  String get explicitScopeRoleKey =>
      (primaryScopeRoleKey ?? '').trim().toLowerCase();

  bool get isPowerAdmin =>
      explicitScopeRoleKey == 'power_admin' ||
      (!isProtectedSuperuser && isCentral && normalizedRole == 'manager');
  bool get isUnitAdmin =>
      explicitScopeRoleKey == 'unit_admin' ||
      (!isProtectedSuperuser && !isCentral && normalizedRole == 'admin');
  bool get isSystemSuperUser =>
      explicitScopeRoleKey == 'system_super_user' ||
      (!isProtectedSuperuser &&
          !isCentral &&
          normalizedRole == 'manager' &&
          (primaryScopeSystemKey ?? '').trim().isNotEmpty);
  bool get isDelegateLawyer =>
      explicitScopeRoleKey == 'delegate_lawyer' ||
      (!isProtectedSuperuser && hasDelegateHint);
  bool get isExperimentalViewer =>
      explicitScopeRoleKey == 'viewer_experimental' ||
      normalizedRole == 'viewer';
  bool get canAccessUsersManagement =>
      isProtectedSuperuser || isPowerAdmin || isUnitAdmin || isSystemSuperUser;
  bool get canCreateScopedUsers =>
      isProtectedSuperuser || isPowerAdmin || isUnitAdmin;
  bool get canManageSystemScopedUsers =>
      isProtectedSuperuser || isPowerAdmin || isUnitAdmin || isSystemSuperUser;

  String get operationalRoleKey {
    if (isProtectedSuperuser) return 'superuser';
    if (explicitScopeRoleKey.isNotEmpty) return explicitScopeRoleKey;
    if (isDelegateLawyer) return 'delegate_lawyer';
    if (isPowerAdmin) return 'power_admin';
    if (isUnitAdmin) return 'unit_admin';
    if (isSystemSuperUser) return 'system_super_user';
    if (normalizedRole == 'employee') return 'employee';
    return 'viewer_experimental';
  }

  String get operationalRoleLabelAr {
    switch (operationalRoleKey) {
      case 'superuser':
        return 'سوبر يوزر';
      case 'power_admin':
        return 'Power Admin';
      case 'unit_admin':
        return 'مدير وحدة';
      case 'system_super_user':
        return 'مشرف نظام الوحدة';
      case 'delegate_lawyer':
        return 'وكيل قانوني مفوض';
      case 'employee':
        return 'موظف';
      default:
        return 'مشاهد (تجريبي)';
    }
  }

  String get governanceScopeDescription {
    switch (operationalRoleKey) {
      case 'superuser':
        return 'مسؤول عن جميع وحدات المنصة وجميع الأنظمة، وحسابه محمي ولا يجوز حذفه.';
      case 'power_admin':
        return 'مسؤول عن نظام واحد عبر جميع الوحدات التي تعمل عليه، ويتابع العاملين عليه على مستوى المنصة.';
      case 'unit_admin':
        return 'مسؤول عن جميع الصفحات والمستخدمين والخدمات والأنظمة المتعلقة بوحدته الإدارية فقط.';
      case 'system_super_user':
        return 'يتابع نظامًا محددًا داخل وحدته، وصلاحياته أعلى من الموظف العادي وأقل من Power Admin.';
      case 'delegate_lawyer':
        return 'وكيل/محامٍ مفوض على نظام القضايا أو نظام مماثل في وحدات محددة فقط، وليس على كل الوحدات.';
      case 'employee':
        return 'صلاحيات تشغيلية عادية ضمن النطاق والوحدة والأنظمة الممنوحة له.';
      default:
        return 'حساب مشاهدة تجريبي مؤقت وسيُزال أو تُعدّل صلاحياته لاحقًا.';
    }
  }

  UserRole get roleEnum {
    switch (normalizedRole) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'employee':
        return UserRole.employee;
      case 'viewer':
      default:
        return UserRole.viewer;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminUser &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.role == role &&
        other.username == username &&
        other.department == department &&
        other.unitId == unitId &&
        other.unitSlug == unitSlug &&
        other.unitNameAr == unitNameAr &&
        other.primaryScopeRoleKey == primaryScopeRoleKey &&
        other.primaryScopeSystemKey == primaryScopeSystemKey &&
        other.isActive == isActive &&
        other.isSuperuser == isSuperuser;
  }

  @override
  int get hashCode => Object.hash(
      id,
      email,
      name,
      role,
      username,
      department,
      unitId,
      unitSlug,
      unitNameAr,
      primaryScopeRoleKey,
      primaryScopeSystemKey,
      isActive,
      isSuperuser);

  @override
  String toString() {
    return 'AdminUser(id: $id, email: $email, name: $name, username: $username, role: $role, unitId: $unitId)';
  }
}

/// Admin users roles from public.admin_users
enum UserRole {
  superAdmin('super_admin', 'سوبر يوزر'),
  admin('admin', 'مدير وحدة'),
  manager('manager', 'Power Admin / مشرف نظام'),
  employee('employee', 'موظف'),
  viewer('viewer', 'مشاهد (تجريبي)');

  final String value;
  final String displayName;

  const UserRole(this.value, this.displayName);

  static UserRole fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'employee':
        return UserRole.employee;
      case 'viewer':
      default:
        return UserRole.viewer;
    }
  }
}
