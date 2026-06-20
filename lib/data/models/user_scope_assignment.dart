class UserScopeAssignment {
  final String id;
  final String userId;
  final String scopeRoleKey;
  final String? systemKey;
  final String? unitId;
  final bool isActive;
  final String? notes;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? grantedBy;
  final List<String> linkedUnitIds;
  final List<String> linkedUnitNamesAr;

  const UserScopeAssignment({
    required this.id,
    required this.userId,
    required this.scopeRoleKey,
    this.systemKey,
    this.unitId,
    required this.isActive,
    this.notes,
    this.startsAt,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.grantedBy,
    this.linkedUnitIds = const [],
    this.linkedUnitNamesAr = const [],
  });

  factory UserScopeAssignment.fromJson(Map<String, dynamic> json) {
    List<String> _toStringList(dynamic value) {
      if (value is List) {
        return value
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();
      }
      return const <String>[];
    }

    DateTime? _dt(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return UserScopeAssignment(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      scopeRoleKey: (json['scope_role_key'] ?? '').toString(),
      systemKey: json['system_key']?.toString(),
      unitId: json['unit_id']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes']?.toString(),
      startsAt: _dt(json['starts_at']),
      expiresAt: _dt(json['expires_at']),
      createdAt: _dt(json['created_at']),
      updatedAt: _dt(json['updated_at']),
      grantedBy: json['granted_by']?.toString(),
      linkedUnitIds: _toStringList(json['linked_unit_ids']),
      linkedUnitNamesAr: _toStringList(json['linked_unit_names_ar']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'scope_role_key': scopeRoleKey,
    'system_key': systemKey,
    'unit_id': unitId,
    'is_active': isActive,
    'notes': notes,
    'starts_at': startsAt?.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'granted_by': grantedBy,
    'linked_unit_ids': linkedUnitIds,
    'linked_unit_names_ar': linkedUnitNamesAr,
  };

  bool get isMultiUnit =>
      linkedUnitIds.length > 1 || linkedUnitNamesAr.length > 1;

  String get scopeLabelAr {
    switch (scopeRoleKey.trim().toLowerCase()) {
      case 'power_admin':
        return 'Power Admin';
      case 'unit_admin':
        return 'مدير وحدة';
      case 'system_super_user':
        return 'مشرف نظام الوحدة';
      case 'delegate_lawyer':
        return 'وكيل قانوني مفوض';
      case 'unit_viewer':
        return 'مشاهد للوحدة';
      case 'unit_content_editor':
        return 'محرر محتوى الوحدة';
      case 'unit_profile_manager':
        return 'مسؤول ملف الوحدة';
      case 'unit_reviewer':
        return 'مراجع محتوى الوحدة';
      case 'unit_approver':
        return 'معتمد محتوى الوحدة';
      case 'unit_publisher':
        return 'ناشر محتوى الوحدة';
      case 'unit_director':
        return 'مدير الوحدة';
      case 'employee':
        return 'موظف';
      default:
        return scopeRoleKey;
    }
  }

  String get unitsSummaryAr {
    final names = linkedUnitNamesAr.where((e) => e.trim().isNotEmpty).toList();
    if (names.isEmpty) return '';
    if (names.length == 1) return names.first;
    if (names.length <= 3) return names.join('، ');
    return '${names.take(3).join('، ')} +${names.length - 3}';
  }
}
