// lib/data/models/admin_user.dart
class AdminUser {
  final String id; // UUID from Supabase Auth
  final String email;
  final String name;
  final String role;
  final String? department;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.department,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create AdminUser from Supabase JSON
  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      department: json['department'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert AdminUser to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'department': department,
      'is_active': isActive,
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
    String? department,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      department: department ?? this.department,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin.value;

  /// Check if user is staff
  bool get isStaff => role == UserRole.staff.value;

  /// Check if user is moderator
  bool get isModerator => role == UserRole.moderator.value;

  /// Get user role enum
  UserRole get roleEnum {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'moderator':
        return UserRole.moderator;
      case 'staff':
        return UserRole.staff;
      default:
        return UserRole.staff;
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
        other.department == department &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(id, email, name, role, department, isActive);
  }

  @override
  String toString() {
    return 'AdminUser(id: $id, email: $email, name: $name, role: $role, department: $department)';
  }
}

/// User roles enum
enum UserRole {
  admin('admin', 'مدير'),
  moderator('moderator', 'مشرف'),
  staff('staff', 'موظف');

  final String value;
  final String displayName;

  const UserRole(this.value, this.displayName);

  /// Get role from string value
  static UserRole fromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'moderator':
        return UserRole.moderator;
      case 'staff':
        return UserRole.staff;
      default:
        return UserRole.staff;
    }
  }
}