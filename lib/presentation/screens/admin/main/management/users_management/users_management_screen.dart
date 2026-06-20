// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/access/access_profile.dart';
import '../../../../../../core/access/admin_route_access_contract.dart';
import '../../../../../../core/access/access_provider.dart';
import '../../../../../../core/enums/enums.dart';
import '../../../../../../data/models/admin_user.dart';
import '../../../../../../data/models/user_activity_log_item.dart';
import '../../../../../../data/models/user_scope_assignment.dart';
import '../../../../../providers/admin_users_provider.dart';
import '../../../../../providers/auth_provider.dart';
import '../../../../../providers/rbac_admin_provider.dart';
import '../../../../../widgets/admin/admin_gateway_strip.dart';
import '../../../../../widgets/admin/admin_panel_registry.dart';

bool _looksLikeUuid(String v) {
  final s = v.trim();
  final r = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
  return r.hasMatch(s);
}

bool _isKnownSystemKey(String v) {
  return SystemKey.values.any((e) => e.name == v);
}

bool _isKnownPermissionKey(String v) {
  return Permission.values.any((e) => e.name == v);
}

String _extractSystemKey(Map<String, dynamic> row) {
  final candidates = [row['system_key'], row['key'], row['code'], row['slug']]
      .where((e) => e != null)
      .map((e) => e.toString().trim())
      .where((s) => s.isNotEmpty)
      .toList();

  for (final c in candidates) {
    if (_isKnownSystemKey(c)) return c;
  }
  return candidates.isNotEmpty ? candidates.first : '';
}

String _extractPermissionKey(Map<String, dynamic> row) {
  final candidates = [
    row['permission_key'],
    row['key'],
    row['code'],
    row['slug']
  ]
      .where((e) => e != null)
      .map((e) => e.toString().trim())
      .where((s) => s.isNotEmpty)
      .toList();

  for (final c in candidates) {
    if (_isKnownPermissionKey(c)) return c;
  }
  return candidates.isNotEmpty ? candidates.first : '';
}

String _extractLabel(Map<String, dynamic> row) {
  return (row['name_ar'] ??
          row['name_en'] ??
          row['title_ar'] ??
          row['title_en'] ??
          row['title'] ??
          '')
      .toString();
}

String _systemLabelFromKey(String systemKey) {
  final governed = AdminPanelRegistry.governedSystemByName(systemKey);
  if (governed != null) return governed.label;

  for (final item in SystemKey.values) {
    if (item.name == systemKey) return item.nameAr;
  }
  return systemKey;
}

Map<String, String> _buildSystemLabels(List<Map<String, dynamic>> systems) {
  final map = <String, String>{
    for (final item in AdminPanelRegistry.governedSystems)
      item.systemKey.name: item.label,
  };

  for (final row in systems) {
    final key = _extractSystemKey(row);
    if (key.isEmpty) continue;
    final label = _extractLabel(row).trim();
    if (label.isNotEmpty) {
      map[key] = label;
    } else {
      map.putIfAbsent(key, () => _systemLabelFromKey(key));
    }
  }
  return map;
}

List<String> _sortSystemKeys(Iterable<String> keys) {
  final governedOrder = {
    for (var i = 0; i < AdminPanelRegistry.governedSystems.length; i++)
      AdminPanelRegistry.governedSystems[i].systemKey.name: i,
  };

  final list = keys.toSet().toList();
  list.sort((a, b) {
    final ai = governedOrder[a];
    final bi = governedOrder[b];
    if (ai != null && bi != null) return ai.compareTo(bi);
    if (ai != null) return -1;
    if (bi != null) return 1;
    return a.compareTo(b);
  });
  return list;
}

String _governanceChecklistText() {
  return '''
إضافة نظام جديد إلى PalWakf — Checklist حاكم

1) اعتماد system_key جديد سيادي داخل enum SystemKey وقاعدة البيانات.
2) تحديد نطاق النظام وحدود مسؤوليته وعدم كسر فصل الأنظمة.
3) تسجيل النظام داخل platform_systems وربطه بـ RBAC.
4) تحديد الشاشات/المسارات داخل لوحة التحكم والبوابة العامة إن وجدت.
5) تحديد الصلاحيات المطلوبة وإضافتها إلى platform_permissions عند الحاجة.
6) تحديث السجل المركزي للوحة التحكم AdminPanelRegistry.
7) تحديث دليل الصيانة الداخلي ADMIN_PANEL_MAINTENANCE.md.
8) عدم تمكين منح صلاحيات تشغيلية لنظام غير معتمد سياديًا.
''';
}

enum _AdminUsersPrivilegeFilter { all, superusers, regular }

enum _AdminUsersScopeFilter { all, central, unitScoped }

final _adminUsersRoleFilterProvider = StateProvider<String?>((ref) => null);
final _adminUsersPrivilegeFilterProvider =
    StateProvider<_AdminUsersPrivilegeFilter>(
        (ref) => _AdminUsersPrivilegeFilter.all);
final _adminUsersScopeFilterProvider =
    StateProvider<_AdminUsersScopeFilter>((ref) => _AdminUsersScopeFilter.all);
final _adminUsersUnitFilterProvider = StateProvider<String?>((ref) => null);
final _selectedAdminUserIdsProvider =
    StateProvider<Set<String>>((ref) => <String>{});
final _adminUsersActionNoteProvider = StateProvider<String>((ref) => '');

List<String> _collectRoleOptions(List<Map<String, dynamic>> rows) {
  final roles = rows
      .map(_operationalRoleKey)
      .where((role) => role.trim().isNotEmpty)
      .toSet()
      .toList()
    ..sort();
  return roles;
}

List<Map<String, String>> _collectUnitOptions(List<Map<String, dynamic>> rows) {
  final seen = <String>{};
  final items = <Map<String, String>>[];
  for (final row in rows) {
    final unitId = (row['unit_id'] ?? '').toString().trim();
    if (unitId.isEmpty || seen.contains(unitId)) continue;
    final label = ((row['unit_name_ar'] ??
                row['unit_slug'] ??
                row['department'] ??
                'وحدوي')
            .toString())
        .trim();
    seen.add(unitId);
    items.add({'id': unitId, 'label': label.isEmpty ? unitId : label});
  }
  items.sort((a, b) => (a['label'] ?? '').compareTo(b['label'] ?? ''));
  return items;
}

List<Map<String, dynamic>> _applyAdminUserFilters(
  List<Map<String, dynamic>> rows, {
  required String? role,
  required _AdminUsersPrivilegeFilter privilegeFilter,
  required _AdminUsersScopeFilter scopeFilter,
  required String? unitId,
}) {
  return rows.where((row) {
    final rowRole = _operationalRoleKey(row).trim();
    final isSuper = row['is_superuser'] == true;
    final rowUnitId = (row['unit_id'] ?? '').toString().trim();
    final isCentral = rowUnitId.isEmpty;

    final matchesRole =
        role == null || role.trim().isEmpty || rowRole == role.trim();
    final matchesPrivilege = switch (privilegeFilter) {
      _AdminUsersPrivilegeFilter.all => true,
      _AdminUsersPrivilegeFilter.superusers => isSuper,
      _AdminUsersPrivilegeFilter.regular => !isSuper,
    };
    final matchesScope = switch (scopeFilter) {
      _AdminUsersScopeFilter.all => true,
      _AdminUsersScopeFilter.central => isCentral,
      _AdminUsersScopeFilter.unitScoped => !isCentral,
    };
    final matchesUnit =
        unitId == null || unitId.trim().isEmpty || rowUnitId == unitId.trim();

    return matchesRole && matchesPrivilege && matchesScope && matchesUnit;
  }).toList();
}

String _selectionLabel(int selected, int visible) {
  if (selected <= 0) return 'لا يوجد تحديد نشط';
  return 'تم تحديد $selected من أصل $visible مستخدمًا';
}

String _adminScopeLabel(Map<String, dynamic> row) {
  final unitName = (row['unit_name_ar'] ?? '').toString().trim();
  final unitSlug = (row['unit_slug'] ?? '').toString().trim();
  final department = (row['department'] ?? '').toString().trim();
  final unitId = (row['unit_id'] ?? '').toString().trim();
  if (unitId.isEmpty) return 'مركزي';
  if (unitName.isNotEmpty) return unitName;
  if (unitSlug.isNotEmpty) return unitSlug;
  if (department.isNotEmpty) return department;
  return 'وحدوي';
}

String _operationalRoleKey(Map<String, dynamic> row) {
  final explicit = (row['operational_role_key'] ?? '').toString().trim();
  if (explicit.isNotEmpty) return explicit;
  final role = (row['role'] ?? '').toString().trim().toLowerCase();
  final unitId = (row['unit_id'] ?? '').toString().trim();
  // Existing scoped users may still carry legacy role='super_admin'.
  // Display global superuser only when the explicit is_superuser flag is true.
  final isSuper = row['is_superuser'] == true;
  if (isSuper) return 'superuser';
  if (role == 'manager' && unitId.isEmpty) return 'power_admin';
  if (role == 'admin' && unitId.isNotEmpty) return 'unit_admin';
  if (role == 'manager' && unitId.isNotEmpty) return 'system_super_user';
  if (role == 'employee') return 'employee';
  return 'viewer_experimental';
}

const List<Map<String, String>> _operationalScopeRoleOptions = [
  {'value': 'power_admin', 'label': 'Power Admin'},
  {'value': 'unit_admin', 'label': 'مدير صلاحيات الوحدة'},
  {'value': 'unit_director', 'label': 'مدير الوحدة'},
  {'value': 'unit_publisher', 'label': 'ناشر محتوى الوحدة'},
  {'value': 'unit_approver', 'label': 'معتمد محتوى الوحدة'},
  {'value': 'unit_reviewer', 'label': 'مراجع محتوى الوحدة'},
  {'value': 'unit_profile_manager', 'label': 'مسؤول ملف الوحدة'},
  {'value': 'unit_content_editor', 'label': 'محرر محتوى الوحدة'},
  {'value': 'unit_viewer', 'label': 'مشاهد للوحدة'},
  {'value': 'system_super_user', 'label': 'مشرف نظام الوحدة'},
  {'value': 'employee', 'label': 'موظف'},
  {'value': 'delegate_lawyer', 'label': 'وكيل قانوني مفوض'},
];

const Set<String> _siteUnitScopeRoles = {
  'unit_admin',
  'unit_director',
  'unit_publisher',
  'unit_approver',
  'unit_reviewer',
  'unit_profile_manager',
  'unit_content_editor',
  'unit_viewer',
};

bool _isSiteUnitScopeRole(String scopeRoleKey) =>
    _siteUnitScopeRoles.contains(scopeRoleKey.trim().toLowerCase());

String _persistedAdminRoleForScopeRole(String scopeRoleKey) {
  switch (scopeRoleKey.trim().toLowerCase()) {
    case 'power_admin':
    case 'system_super_user':
    case 'delegate_lawyer':
      return 'manager';
    case 'unit_admin':
      return 'admin';
    case 'employee':
      return 'employee';
    case 'viewer_experimental':
      return 'viewer';
    default:
      return 'employee';
  }
}

bool _scopeRoleRequiresUnit(String scopeRoleKey) =>
    _isSiteUnitScopeRole(scopeRoleKey) ||
    switch (scopeRoleKey.trim().toLowerCase()) {
      'system_super_user' => true,
      'employee' => true,
      _ => false,
    };

bool _scopeRoleRequiresSystem(String scopeRoleKey) =>
    _isSiteUnitScopeRole(scopeRoleKey) ||
    switch (scopeRoleKey.trim().toLowerCase()) {
      'power_admin' => true,
      'system_super_user' => true,
      'delegate_lawyer' => true,
      _ => false,
    };

bool _scopeRoleSupportsMultiUnit(String scopeRoleKey) =>
    scopeRoleKey.trim().toLowerCase() == 'delegate_lawyer';

String _operationalScopeRoleLabel(String scopeRoleKey) {
  final match = _operationalScopeRoleOptions
      .where((item) => item['value'] == scopeRoleKey)
      .toList();
  return match.isNotEmpty ? match.first['label']! : scopeRoleKey;
}

String _adminRoleLabel(String role, {Map<String, dynamic>? row}) {
  final key =
      row == null ? role.trim().toLowerCase() : _operationalRoleKey(row);
  switch (key) {
    case 'superuser':
    case 'super_admin':
      return 'سوبر يوزر';
    case 'power_admin':
      return 'Power Admin';
    case 'unit_admin':
    case 'admin':
      return 'مدير وحدة';
    case 'system_super_user':
    case 'manager':
      return 'مشرف نظام الوحدة';
    case 'delegate_lawyer':
      return 'وكيل قانوني مفوض';
    case 'employee':
      return 'موظف';
    case 'viewer':
    case 'viewer_experimental':
      return 'مشاهد (تجريبي)';
    default:
      return role;
  }
}

String _formatDateTime(dynamic raw) {
  if (raw == null) return '—';
  DateTime? dt;
  if (raw is DateTime) {
    dt = raw;
  } else {
    dt = DateTime.tryParse(raw.toString());
  }
  if (dt == null) return raw.toString();
  final local = dt.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year}/${two(local.month)}/${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}

String _buildInitials(Map<String, dynamic> row) {
  final source = ((row['name'] ?? row['username'] ?? row['email']) ?? '')
      .toString()
      .trim();
  if (source.isEmpty) return '؟';
  final parts =
      source.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.length >= 2) {
    return '${parts.first.characters.first}${parts[1].characters.first}'
        .toUpperCase();
  }
  return source.characters.take(2).toString().toUpperCase();
}

Color _roleAccent(String role, {Map<String, dynamic>? row}) {
  final key =
      row == null ? role.trim().toLowerCase() : _operationalRoleKey(row);
  switch (key) {
    case 'superuser':
    case 'super_admin':
      return const Color(0xFF7C3AED);
    case 'power_admin':
      return const Color(0xFFB22222);
    case 'unit_admin':
    case 'admin':
      return const Color(0xFF0F4C81);
    case 'system_super_user':
    case 'manager':
      return const Color(0xFFB45309);
    case 'delegate_lawyer':
      return const Color(0xFF8B5CF6);
    case 'employee':
      return const Color(0xFF047857);
    default:
      return const Color(0xFF6B7280);
  }
}

Set<String> _rowAssignedSystemKeys(Map<String, dynamic> row) {
  final values = <String>{
    for (final value in (row['assigned_system_keys'] as List? ?? const []))
      value.toString().trim(),
    (row['primary_scope_system_key'] ?? '').toString().trim(),
  };
  values.removeWhere((value) => value.isEmpty);
  return values;
}

Set<String> _rowAssignedUnitIds(Map<String, dynamic> row) {
  final values = <String>{
    for (final value in (row['assigned_unit_ids'] as List? ?? const []))
      value.toString().trim(),
    (row['unit_id'] ?? '').toString().trim(),
  };
  values.removeWhere((value) => value.isEmpty);
  return values;
}

Set<String> _actorSystemKeys(AdminUser? actor, AccessProfile? profile) {
  if (actor == null) return const <String>{};
  final keys = <String>{...actor.effectiveSystemKeys};
  if (profile != null) {
    for (final entry in profile.roles.entries) {
      if (entry.key != SystemKey.platformAdmin) keys.add(entry.key.name);
    }
    for (final entry in profile.permissions.entries) {
      if (entry.key != SystemKey.platformAdmin && entry.value.isNotEmpty)
        keys.add(entry.key.name);
    }
  }
  keys.removeWhere((value) => value.trim().isEmpty);
  return keys;
}

Set<String> _actorUnitIds(AdminUser? actor) {
  if (actor == null) return const <String>{};
  return actor.effectiveUnitIds;
}

bool _intersects(Set<String> a, Set<String> b) => a.any(b.contains);

bool _canAccessUsersManagement(AdminUser? actor, AccessProfile? profile) {
  if (actor == null) return false;
  if ((profile?.isSuperuser ?? false) || actor.isProtectedSuperuser)
    return true;
  if (profile?.can(SystemKey.platformAdmin, Permission.manageUsers) ?? false)
    return true;
  return actor.canAccessUsersManagement;
}

List<Map<String, dynamic>> _applyActorVisibility(
  List<Map<String, dynamic>> rows, {
  required AdminUser? actor,
  required AccessProfile? profile,
}) {
  if (actor == null) return const <Map<String, dynamic>>[];
  if ((profile?.isSuperuser ?? false) || actor.isProtectedSuperuser)
    return rows;

  final actorRole = actor.operationalRoleKey;
  final actorSystems = _actorSystemKeys(actor, profile);
  final actorUnits = _actorUnitIds(actor);

  bool canSee(Map<String, dynamic> row) {
    final targetId = (row['id'] ?? '').toString().trim();
    if (targetId == actor.id) return true;
    final targetSystems = _rowAssignedSystemKeys(row);
    final targetUnits = _rowAssignedUnitIds(row);

    switch (actorRole) {
      case 'power_admin':
        if (actorSystems.isEmpty) return false;
        return _intersects(actorSystems, targetSystems);
      case 'unit_admin':
        return actorUnits.isNotEmpty && _intersects(actorUnits, targetUnits);
      case 'system_super_user':
        return actorSystems.isNotEmpty &&
            actorUnits.isNotEmpty &&
            _intersects(actorSystems, targetSystems) &&
            _intersects(actorUnits, targetUnits);
      default:
        return false;
    }
  }

  return rows.where(canSee).toList();
}

List<Map<String, String>> _filterUnitsForActor(
  List<Map<String, String>> units,
  AdminUser? actor,
  AccessProfile? profile,
) {
  if (actor == null) return const <Map<String, String>>[];
  if ((profile?.isSuperuser ?? false) ||
      actor.isProtectedSuperuser ||
      actor.isPowerAdmin) return units;
  final actorUnits = _actorUnitIds(actor);
  if (actorUnits.isEmpty) return const <Map<String, String>>[];
  return units
      .where((item) => actorUnits.contains((item['id'] ?? '').trim()))
      .toList();
}

String _actorVisibilityDescription(AdminUser actor, AccessProfile? profile) {
  if ((profile?.isSuperuser ?? false) || actor.isProtectedSuperuser) {
    return 'ترى جميع المستخدمين والوحدات والأنظمة لأنك سوبر يوزر.';
  }
  switch (actor.operationalRoleKey) {
    case 'power_admin':
      final systems = _actorSystemKeys(actor, profile).join('، ');
      return systems.isEmpty
          ? 'ترى مستخدمي الأنظمة التي تتابعها عبر الوحدات.'
          : 'ترى فقط المستخدمين المرتبطين بالأنظمة التالية عبر الوحدات: $systems';
    case 'unit_admin':
      return 'ترى فقط المستخدمين التابعين لوحدتك الإدارية: ${actor.scopeLabel}';
    case 'system_super_user':
      return 'ترى فقط العاملين على نفس النظام داخل وحدتك.';
    default:
      return 'هذه الشاشة مقيدة بحسب نطاقك الحالي.';
  }
}

List<Map<String, String>> _allowedPersistedRolesForActor(
  AdminUser? actor,
  bool isSuperuserActor, {
  String? currentRole,
}) {
  final roles = <Map<String, String>>[];
  final actorRole = actor?.operationalRoleKey ?? '';

  if (isSuperuserActor || actor?.isProtectedSuperuser == true) {
    roles.addAll(const [
      {'value': 'super_admin', 'label': 'مدير عام'},
      {'value': 'admin', 'label': 'مدير وحدة'},
      {'value': 'manager', 'label': 'Power Admin / مشرف نظام'},
      {'value': 'employee', 'label': 'موظف'},
    ]);
  } else {
    switch (actorRole) {
      case 'power_admin':
        roles.addAll(const [
          {'value': 'manager', 'label': 'Power Admin / مشرف نظام'},
          {'value': 'employee', 'label': 'موظف'},
        ]);
        break;
      case 'unit_admin':
        roles.addAll(const [
          {'value': 'admin', 'label': 'مدير وحدة'},
          {'value': 'manager', 'label': 'مشرف نظام الوحدة'},
          {'value': 'employee', 'label': 'موظف'},
        ]);
        break;
      case 'system_super_user':
        roles.addAll(const [
          {'value': 'employee', 'label': 'موظف'},
        ]);
        break;
      default:
        roles.addAll(const [
          {'value': 'employee', 'label': 'موظف'},
        ]);
    }
  }

  if ((currentRole ?? '').trim().toLowerCase() == 'viewer') {
    roles.add({'value': 'viewer', 'label': 'مشاهد (تجريبي)'});
  }

  final seen = <String>{};
  return roles.where((item) => seen.add(item['value']!)).toList();
}

class _UsersUiPolicy {
  final bool canSeeGovernance;
  final bool canCreateUsers;
  final bool canToggleActive;
  final bool canManageSuperuser;
  final bool canManageAccess;
  final bool canUseBulkActions;
  final bool canSelectRows;

  const _UsersUiPolicy({
    required this.canSeeGovernance,
    required this.canCreateUsers,
    required this.canToggleActive,
    required this.canManageSuperuser,
    required this.canManageAccess,
    required this.canUseBulkActions,
    required this.canSelectRows,
  });

  factory _UsersUiPolicy.fromActor(AdminUser? actor, AccessProfile? profile) {
    final isSuper = (profile?.isSuperuser ?? false) ||
        (actor?.isProtectedSuperuser ?? false);
    final actorRole = actor?.operationalRoleKey ?? '';
    final canManageUsers =
        profile?.can(SystemKey.platformAdmin, Permission.manageUsers) ?? false;
    final canUpdateUsers =
        profile?.can(SystemKey.platformAdmin, Permission.update) ?? false;
    final canCreateUsers =
        profile?.can(SystemKey.platformAdmin, Permission.create) ?? false;

    final toggleActive = isSuper ||
        canManageUsers ||
        canUpdateUsers ||
        actorRole == 'power_admin' ||
        actorRole == 'unit_admin' ||
        actorRole == 'system_super_user';
    final manageAccess = isSuper ||
        canManageUsers ||
        actorRole == 'power_admin' ||
        actorRole == 'unit_admin' ||
        actorRole == 'system_super_user';
    final createUsers = isSuper ||
        canCreateUsers ||
        actorRole == 'power_admin' ||
        actorRole == 'unit_admin';
    final manageSuper = isSuper;

    return _UsersUiPolicy(
      canSeeGovernance: isSuper,
      canCreateUsers: createUsers,
      canToggleActive: toggleActive,
      canManageSuperuser: manageSuper,
      canManageAccess: manageAccess,
      canUseBulkActions: toggleActive || manageSuper,
      canSelectRows: toggleActive || manageSuper,
    );
  }
}

Future<void> _logAdminUsersAudit(
  WidgetRef ref, {
  required String actionKey,
  required String title,
  required String targetUserId,
  String entityType = 'admin_user',
  Map<String, dynamic> metadata = const {},
}) async {
  try {
    await ref.read(adminUsersAuditRepositoryProvider).logUserAdminAction(
          actionKey: actionKey,
          title: title,
          targetUserId: targetUserId,
          entityType: entityType,
          metadata: metadata,
        );
  } catch (_) {
    // Fail-soft for UI actions if the audit table is unavailable.
  } finally {
    ref.invalidate(adminUsersRecentAuditProvider);
  }
}

class UsersManagementScreen extends ConsumerWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actor = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(accessProfileProvider);
    final usersAsync = ref.watch(adminUsersListProvider);
    final systemsAsync = ref.watch(platformSystemsProvider);
    final activeFilter = ref.watch(adminUsersActiveFilterProvider);
    final selectedRole = ref.watch(_adminUsersRoleFilterProvider);
    final privilegeFilter = ref.watch(_adminUsersPrivilegeFilterProvider);
    final scopeFilter = ref.watch(_adminUsersScopeFilterProvider);
    final selectedUnitId = ref.watch(_adminUsersUnitFilterProvider);
    final recentAuditAsync = ref.watch(adminUsersRecentAuditProvider);
    final scopedRows = _applyActorVisibility(
      usersAsync.valueOrNull ?? const [],
      actor: actor,
      profile: profileAsync.valueOrNull,
    );
    final roleOptions = _collectRoleOptions(scopedRows);
    final unitOptions = _filterUnitsForActor(
      _collectUnitOptions(scopedRows),
      actor,
      profileAsync.valueOrNull,
    );
    final visibleRows = _applyAdminUserFilters(
      scopedRows,
      role: selectedRole,
      privilegeFilter: privilegeFilter,
      scopeFilter: scopeFilter,
      unitId: selectedUnitId,
    );
    final visibleIds = visibleRows
        .map((row) => (row['id'] ?? '').toString())
        .where((id) => id.trim().isNotEmpty)
        .toSet();
    final selectedIds = ref.watch(_selectedAdminUserIdsProvider);
    if (selectedIds.any((id) => !visibleIds.contains(id))) {
      Future.microtask(() => ref
          .read(_selectedAdminUserIdsProvider.notifier)
          .state = selectedIds.where(visibleIds.contains).toSet());
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المستخدمين'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: profileAsync.when(
            data: (profile) {
              final canManage = _canAccessUsersManagement(actor, profile);

              if (!canManage) {
                return _ForbiddenInline(
                  message: actor == null
                      ? 'تعذر تحديد هوية المستخدم الحالي.'
                      : 'ليس لديك نطاق يسمح بإدارة المستخدمين.\n${_actorVisibilityDescription(actor, profile)}',
                );
              }

              final uiPolicy = _UsersUiPolicy.fromActor(actor, profile);
              return LayoutBuilder(
                builder: (context, constraints) {
                  return ListView(
                    children: [
                      AdminGatewayStrip(
                          cards:
                              AdminPanelRegistry.quickAccessForPlatformPages()),
                      const SizedBox(height: 12),
                      if (uiPolicy.canSeeGovernance) ...[
                        _UsersSystemsGovernancePanel(
                            systemsAsync: systemsAsync),
                        const SizedBox(height: 12),
                        const _PlatformAuthorizationModelCard(),
                        const SizedBox(height: 12),
                      ],
                      if (actor != null) ...[
                        _UsersActorScopeCard(
                            actor: actor,
                            profile: profile,
                            visibleRowsCount: scopedRows.length),
                        const SizedBox(height: 12),
                      ],
                      _SearchBar(
                        onChanged: (v) => ref
                            .read(adminUsersSearchProvider.notifier)
                            .state = v,
                        onRefresh: () => ref.invalidate(adminUsersListProvider),
                        activeFilter: activeFilter,
                        selectedRole: selectedRole,
                        availableRoles: roleOptions,
                        availableUnits: unitOptions,
                        selectedUnitId: selectedUnitId,
                        privilegeFilter: privilegeFilter,
                        scopeFilter: scopeFilter,
                        onRoleChanged: (value) => ref
                            .read(_adminUsersRoleFilterProvider.notifier)
                            .state = value,
                        onUnitChanged: (value) => ref
                            .read(_adminUsersUnitFilterProvider.notifier)
                            .state = value,
                        onPrivilegeFilterChanged: (value) => ref
                            .read(_adminUsersPrivilegeFilterProvider.notifier)
                            .state = value,
                        onScopeFilterChanged: (value) => ref
                            .read(_adminUsersScopeFilterProvider.notifier)
                            .state = value,
                        onFilterChanged: (f) {
                          ref
                              .read(adminUsersActiveFilterProvider.notifier)
                              .state = f;
                          ref.invalidate(adminUsersListProvider);
                        },
                        showCreateButton: uiPolicy.canCreateUsers,
                        onCreate: () async {
                          final profile = profileAsync.value;
                          await showDialog(
                            context: context,
                            builder: (_) => _CreateAdminUserDialog(
                              isSuperuserActor: profile?.isSuperuser ?? false,
                              actorUser: actor,
                            ),
                          );
                          ref.invalidate(adminUsersListProvider);
                        },
                      ),
                      const SizedBox(height: 12),
                      if ((usersAsync.valueOrNull ?? const []).isNotEmpty) ...[
                        _UsersSummaryStrip(
                          allRows: scopedRows,
                          visibleRows: visibleRows,
                        ),
                        const SizedBox(height: 12),
                        const _UsersPolicyFrameworkCard(),
                        const SizedBox(height: 12),
                        if (uiPolicy.canUseBulkActions) ...[
                          _UsersBulkActionBar(
                            visibleRows: visibleRows,
                            selectedIds: selectedIds,
                            actorIsSuperuser: profile?.isSuperuser ?? false,
                            canToggleActive: uiPolicy.canToggleActive,
                            canManageSuperuser: uiPolicy.canManageSuperuser,
                          ),
                          const SizedBox(height: 12),
                        ],
                        const _UsersAuditHintCard(),
                        const SizedBox(height: 12),
                        _UsersRecentAuditPanel(auditAsync: recentAuditAsync),
                        const SizedBox(height: 12),
                      ],
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: usersAsync.when(
                          data: (rows) {
                            final visibleRows = _applyAdminUserFilters(
                              rows,
                              role: selectedRole,
                              privilegeFilter: privilegeFilter,
                              scopeFilter: scopeFilter,
                              unitId: selectedUnitId,
                            );
                            return _UsersTable(
                              rows: visibleRows,
                              selectedIds: selectedIds,
                              actorUserId: profile?.userId ?? '',
                              actorIsSuperuser: profile?.isSuperuser ?? false,
                              canToggleActive: uiPolicy.canToggleActive,
                              canManageSuperuser: uiPolicy.canManageSuperuser,
                              canManageAccess: uiPolicy.canManageAccess,
                              canSelectRows: uiPolicy.canSelectRows,
                              actorUser: actor,
                              onSelectionChanged: (id, selected) {
                                final next = {
                                  ...ref.read(_selectedAdminUserIdsProvider)
                                };
                                if (selected) {
                                  next.add(id);
                                } else {
                                  next.remove(id);
                                }
                                ref
                                    .read(
                                        _selectedAdminUserIdsProvider.notifier)
                                    .state = next;
                              },
                              onSelectVisible: (selected) {
                                if (selected) {
                                  ref
                                          .read(_selectedAdminUserIdsProvider
                                              .notifier)
                                          .state =
                                      visibleRows
                                          .map((row) =>
                                              (row['id'] ?? '').toString())
                                          .where((id) => id.trim().isNotEmpty)
                                          .toSet();
                                } else {
                                  ref
                                      .read(_selectedAdminUserIdsProvider
                                          .notifier)
                                      .state = <String>{};
                                }
                              },
                              onToggleActive: (id, value) async {
                                await ref
                                    .read(adminUsersRepositoryProvider)
                                    .setActive(userId: id, isActive: value);
                                await _logAdminUsersAudit(
                                  ref,
                                  actionKey: value
                                      ? 'user_activate'
                                      : 'user_deactivate',
                                  title: value
                                      ? 'إدارة المستخدمين - تفعيل مستخدم'
                                      : 'إدارة المستخدمين - تعطيل مستخدم',
                                  targetUserId: id,
                                  metadata: {'is_active': value},
                                );
                                ref.invalidate(adminUsersListProvider);
                              },
                              onToggleSuperuser: (id, value) async {
                                await ref
                                    .read(adminUsersRepositoryProvider)
                                    .setSuperuser(
                                        userId: id, isSuperuser: value);
                                await _logAdminUsersAudit(
                                  ref,
                                  actionKey: value
                                      ? 'grant_superuser'
                                      : 'revoke_superuser',
                                  title: value
                                      ? 'إدارة المستخدمين - منح Superuser'
                                      : 'إدارة المستخدمين - سحب Superuser',
                                  targetUserId: id,
                                  metadata: {'is_superuser': value},
                                );
                                ref.invalidate(adminUsersListProvider);
                              },
                              onViewDetails: (row) {
                                showDialog(
                                  context: context,
                                  builder: (_) => _UserDetailsDialog(
                                    row: row,
                                    actorIsSuperuser:
                                        profile?.isSuperuser ?? false,
                                    actorUser: actor,
                                  ),
                                );
                              },
                              onEditUser: (row) async {
                                final updated = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => _EditAdminUserDialog(
                                    row: row,
                                    isSuperuserActor:
                                        profile?.isSuperuser ?? false,
                                    actorUser: actor,
                                  ),
                                );
                                if (updated == true) {
                                  ref.invalidate(adminUsersListProvider);
                                }
                              },
                              onResetPassword: (row) async {
                                final email =
                                    (row['email'] ?? '').toString().trim();
                                if (email.isEmpty) return;
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: AlertDialog(
                                      title:
                                          const Text('إعادة تعيين كلمة المرور'),
                                      content: Text(
                                          'سيتم إرسال رابط إعادة تعيين كلمة المرور إلى\n$email'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('إلغاء')),
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          icon: const Icon(
                                              Icons.lock_reset_outlined),
                                          label: const Text('إرسال الرابط'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                if (ok != true) return;
                                try {
                                  await ref
                                      .read(authRepositoryProvider)
                                      .resetPassword(email);
                                  await _logAdminUsersAudit(
                                    ref,
                                    actionKey: 'reset_password_email',
                                    title:
                                        'إدارة المستخدمين - إرسال رابط إعادة تعيين كلمة المرور',
                                    targetUserId: (row['id'] ?? '').toString(),
                                    metadata: {'email': email},
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'تم إرسال رابط إعادة تعيين كلمة المرور إلى $email')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => _ErrorBox(
                            error: e.toString(),
                            onRetry: () =>
                                ref.invalidate(adminUsersListProvider),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorBox(
              error: e.toString(),
              onRetry: () => ref.invalidate(accessProfileProvider),
            ),
          ),
        ),
      ),
    );
  }
}

class _UsersActorScopeCard extends StatelessWidget {
  const _UsersActorScopeCard({
    required this.actor,
    required this.profile,
    required this.visibleRowsCount,
  });

  final AdminUser actor;
  final AccessProfile? profile;
  final int visibleRowsCount;

  @override
  Widget build(BuildContext context) {
    final systems = _actorSystemKeys(actor, profile).toList()..sort();
    final units = actor.effectiveUnitIds.length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رؤيتك الحالية لإدارة المستخدمين',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _actorVisibilityDescription(actor, profile),
                      style: const TextStyle(
                          color: Color(0xFF4B5563), height: 1.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _roleAccent(actor.operationalRoleKey)
                      .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  actor.operationalRoleLabelAr,
                  style: TextStyle(
                      color: _roleAccent(actor.operationalRoleKey),
                      fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusChip(
                  label: 'المستخدمون المرئيون: $visibleRowsCount',
                  active: true),
              _StatusChip(
                  label: 'الوحدات ضمن النطاق: $units', active: units > 0),
              _StatusChip(
                  label: 'الأنظمة ضمن النطاق: ${systems.length}',
                  active: systems.isNotEmpty),
              if (actor.scopeLabel.trim().isNotEmpty)
                _StatusChip(label: actor.scopeLabel, active: true),
            ],
          ),
          if (systems.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('الأنظمة المغطاة: ${systems.join('، ')}',
                style: const TextStyle(color: Color(0xFF4B5563))),
          ],
        ],
      ),
    );
  }
}

class _PlatformAuthorizationModelCard extends StatelessWidget {
  const _PlatformAuthorizationModelCard();

  @override
  Widget build(BuildContext context) {
    final protectedContracts = AdminRouteAccessContracts.contracts.length;
    final readOnlyContracts = AdminRouteAccessContracts.contracts
        .where((item) => item.readOnly)
        .length;
    final governanceContracts = AdminRouteAccessContracts.contracts
        .where((item) => item.governanceRoute)
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.admin_panel_settings_rounded,
                  color: Color(0xFF92400E)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'نموذج الصلاحيات الحاكم للمنصة',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF78350F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'PalWakf ليست مركزًا إعلاميًا وخدماتيًا فقط. إدارة المستخدمين هنا تُعامل كطبقة منصة متعددة الأنظمة والنطاقات: مستخدم، وحدة/نطاق، نظام/خدمة، ودور/فعل. Route Access Contract يربط المسارات الإدارية الحساسة بهذه الطبقة بدل الاكتفاء بوجود حساب إداري نشط.',
            style: TextStyle(color: Color(0xFF92400E), height: 1.55),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusChip(
                  label: 'عقود مسارات محمية: $protectedContracts',
                  active: protectedContracts > 0),
              _StatusChip(
                  label: 'مسارات قراءة/حوكمة: $readOnlyContracts',
                  active: readOnlyContracts > 0),
              _StatusChip(
                  label: 'مسارات حوكمة: $governanceContracts',
                  active: governanceContracts > 0),
              const _StatusChip(
                  label: 'النموذج: platform-wide + scope-aware', active: true),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'بوابة الإنتاج التالية: SQL UAT للمستخدمين/RBAC، Browser UAT حسب الدور، ثم إغلاق أي direct mutation حساس لا يمر عبر RPC حاكمة.',
            style: TextStyle(
                color: Color(0xFF78350F),
                fontWeight: FontWeight.w700,
                height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _UsersSystemsGovernancePanel extends ConsumerWidget {
  const _UsersSystemsGovernancePanel({required this.systemsAsync});

  final AsyncValue<List<Map<String, dynamic>>> systemsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: systemsAsync.when(
        data: (systems) {
          final registeredKeys = <String>{
            for (final row in systems)
              if (_extractSystemKey(row).isNotEmpty) _extractSystemKey(row),
          };
          final governed = AdminPanelRegistry.governedSystems;
          final missing = governed
              .where((item) => !registeredKeys.contains(item.systemKey.name))
              .toList();
          final listedInAdmin =
              governed.where((item) => item.visibleInAdminSystemsTab).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'حوكمة الأنظمة داخل صفحة المستخدمين',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'هذه المساحة هي مرجع إسناد الصلاحيات على مستوى كل أنظمة PalWakf الحالية، مع إغلاق الأنظمة الناقصة في RBAC والتنبيه إلى مسار إضافة أي نظام جديد.',
                        style: TextStyle(color: Color(0xFF6B7280), height: 1.5),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: _governanceChecklistText()));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'تم نسخ Checklist إضافة نظام جديد.')),
                            );
                          }
                        },
                        icon: const Icon(Icons.assignment_outlined),
                        label: const Text('نسخ Checklist إضافة نظام'),
                      ),
                      ElevatedButton.icon(
                        onPressed: missing.isEmpty
                            ? null
                            : () async {
                                try {
                                  for (final item in missing) {
                                    await ref
                                        .read(rbacAdminRepositoryProvider)
                                        .ensureSystemRegistered(
                                            item.systemKey.name);
                                  }
                                  ref.invalidate(platformSystemsProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'تم تسجيل ${missing.length} أنظمة مفقودة في RBAC.')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              },
                        icon: const Icon(
                            Icons.playlist_add_check_circle_outlined),
                        label: const Text('تسجيل الأنظمة الحالية الناقصة'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricCard(
                    title: 'الأنظمة السيادية الحالية',
                    value: governed.length.toString(),
                    icon: Icons.widgets_outlined,
                  ),
                  _MetricCard(
                    title: 'المسجلة في RBAC',
                    value: registeredKeys.length.toString(),
                    icon: Icons.verified_user_outlined,
                  ),
                  _MetricCard(
                    title: 'الناقصة في platform_systems',
                    value: missing.length.toString(),
                    icon: Icons.warning_amber_rounded,
                    accent: missing.isEmpty
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFB22222),
                  ),
                  _MetricCard(
                    title: 'الظاهرة في تبويب الأنظمة',
                    value: listedInAdmin.toString(),
                    icon: Icons.space_dashboard_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'تغطية الأنظمة الحالية',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'يعرض كل نظام حالته داخل RBAC، وهل له شاشة إدارة حالية داخل لوحة التحكم، مع إمكانية تسجيله فورًا إذا كان من الأنظمة المعتمدة ولم يُسجّل بعد.',
                style: TextStyle(color: Color(0xFF6B7280), height: 1.5),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final cardWidth = width >= 1400
                      ? (width - 36) / 4
                      : width >= 1100
                          ? (width - 24) / 3
                          : width >= 700
                              ? (width - 12) / 2
                              : width;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final item in governed)
                        SizedBox(
                          width: cardWidth,
                          child: _GovernedSystemCard(
                            system: item,
                            isRegistered:
                                registeredKeys.contains(item.systemKey.name),
                            onRegister: registeredKeys
                                    .contains(item.systemKey.name)
                                ? null
                                : () async {
                                    try {
                                      await ref
                                          .read(rbacAdminRepositoryProvider)
                                          .ensureSystemRegistered(
                                              item.systemKey.name);
                                      ref.invalidate(platformSystemsProvider);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'تم تسجيل ${item.label} داخل platform_systems.')),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      }
                                    }
                                  },
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.25)),
                ),
                child: const Text(
                  'مهم: إضافة نظام جديد خارج القائمة الحالية لا تتم مباشرة من هذه الشاشة، لأن system_key محكوم بسياديّة المنصة. يجب أولًا اعتماد النظام في enum/RBAC/السجل المركزي ثم يصبح قابلاً للإسناد للمستخدمين هنا.',
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تعذر تحميل سجل الأنظمة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(e.toString()),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(platformSystemsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.accent = const Color(0xFF0F4C81),
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF6B7280), height: 1.4)),
                const SizedBox(height: 6),
                Text(value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GovernedSystemCard extends StatelessWidget {
  const _GovernedSystemCard({
    required this.system,
    required this.isRegistered,
    this.onRegister,
  });

  final AdminGovernedSystem system;
  final bool isRegistered;
  final Future<void> Function()? onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 250),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(system.icon, color: const Color(0xFF0F4C81)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(system.label,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      system.systemKey.name,
                      style: const TextStyle(
                          fontSize: 12.5, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              if (system.adminRoute != null)
                IconButton(
                  tooltip: 'فتح شاشة الإدارة',
                  onPressed: () => context.go(system.adminRoute!),
                  icon: const Icon(Icons.open_in_new),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            system.description,
            style: const TextStyle(color: Color(0xFF6B7280), height: 1.5),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                label: isRegistered ? 'مسجل في RBAC' : 'غير مسجل في RBAC',
                active: isRegistered,
              ),
              _StatusChip(
                label: system.adminRoute != null
                    ? 'له شاشة إدارة'
                    : 'بدون شاشة إدارة حالية',
                active: system.adminRoute != null,
              ),
              _StatusChip(
                label: system.visibleInAdminSystemsTab
                    ? 'ظاهر في تبويب الأنظمة'
                    : 'مرجع حوكمة فقط',
                active: system.visibleInAdminSystemsTab,
              ),
            ],
          ),
          if (!isRegistered) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onRegister == null ? null : () => onRegister!.call(),
                icon: const Icon(Icons.add_link_outlined),
                label: const Text('تسجيله في platform_systems'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFECFDF3) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? const Color(0xFFBBF7D0) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? const Color(0xFF166534) : const Color(0xFF4B5563),
        ),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final void Function(String) onChanged;
  final VoidCallback onRefresh;
  final VoidCallback onCreate;
  final bool showCreateButton;
  final AdminUsersActiveFilter activeFilter;
  final void Function(AdminUsersActiveFilter) onFilterChanged;
  final List<String> availableRoles;
  final List<Map<String, String>> availableUnits;
  final String? selectedRole;
  final String? selectedUnitId;
  final void Function(String?) onRoleChanged;
  final void Function(String?) onUnitChanged;
  final _AdminUsersPrivilegeFilter privilegeFilter;
  final _AdminUsersScopeFilter scopeFilter;
  final void Function(_AdminUsersPrivilegeFilter) onPrivilegeFilterChanged;
  final void Function(_AdminUsersScopeFilter) onScopeFilterChanged;

  const _SearchBar({
    required this.onChanged,
    required this.onRefresh,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.availableRoles,
    required this.availableUnits,
    required this.selectedRole,
    required this.selectedUnitId,
    required this.onRoleChanged,
    required this.onUnitChanged,
    required this.privilegeFilter,
    required this.scopeFilter,
    required this.onPrivilegeFilterChanged,
    required this.onScopeFilterChanged,
    required this.onCreate,
    required this.showCreateButton,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 360,
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'بحث (الاسم أو البريد أو username)',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: widget.onChanged,
              ),
            ),
            ElevatedButton.icon(
              onPressed: widget.onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث'),
            ),
            if (widget.showCreateButton)
              ElevatedButton.icon(
                onPressed: widget.onCreate,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('إضافة مستخدم'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('الكل'),
              selected: widget.activeFilter == AdminUsersActiveFilter.all,
              onSelected: (_) =>
                  widget.onFilterChanged(AdminUsersActiveFilter.all),
            ),
            ChoiceChip(
              label: const Text('نشط'),
              selected: widget.activeFilter == AdminUsersActiveFilter.active,
              onSelected: (_) =>
                  widget.onFilterChanged(AdminUsersActiveFilter.active),
            ),
            ChoiceChip(
              label: const Text('غير نشط'),
              selected: widget.activeFilter == AdminUsersActiveFilter.inactive,
              onSelected: (_) =>
                  widget.onFilterChanged(AdminUsersActiveFilter.inactive),
            ),
            ChoiceChip(
              label: const Text('كل النطاقات'),
              selected: widget.scopeFilter == _AdminUsersScopeFilter.all,
              onSelected: (_) =>
                  widget.onScopeFilterChanged(_AdminUsersScopeFilter.all),
            ),
            ChoiceChip(
              label: const Text('مركزي'),
              selected: widget.scopeFilter == _AdminUsersScopeFilter.central,
              onSelected: (_) =>
                  widget.onScopeFilterChanged(_AdminUsersScopeFilter.central),
            ),
            ChoiceChip(
              label: const Text('وحدوي'),
              selected: widget.scopeFilter == _AdminUsersScopeFilter.unitScoped,
              onSelected: (_) => widget
                  .onScopeFilterChanged(_AdminUsersScopeFilter.unitScoped),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String?>(
                value: widget.selectedRole,
                decoration: const InputDecoration(
                  labelText: 'فلترة بالدور',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('كل الأدوار')),
                  ...widget.availableRoles
                      .map((role) => DropdownMenuItem<String?>(
                            value: role,
                            child: Text(_adminRoleLabel(role)),
                          )),
                ],
                onChanged: widget.onRoleChanged,
              ),
            ),
            SizedBox(
              width: 240,
              child: DropdownButtonFormField<String?>(
                value: widget.selectedUnitId,
                decoration: const InputDecoration(
                  labelText: 'فلترة بالوحدة',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('كل الوحدات')),
                  ...widget.availableUnits
                      .map((unit) => DropdownMenuItem<String?>(
                            value: unit['id'],
                            child: Text(unit['label'] ?? ''),
                          )),
                ],
                onChanged: widget.onUnitChanged,
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('كل الحسابات'),
                  selected:
                      widget.privilegeFilter == _AdminUsersPrivilegeFilter.all,
                  onSelected: (_) => widget
                      .onPrivilegeFilterChanged(_AdminUsersPrivilegeFilter.all),
                ),
                ChoiceChip(
                  label: const Text('Superuser'),
                  selected: widget.privilegeFilter ==
                      _AdminUsersPrivilegeFilter.superusers,
                  onSelected: (_) => widget.onPrivilegeFilterChanged(
                      _AdminUsersPrivilegeFilter.superusers),
                ),
                ChoiceChip(
                  label: const Text('عادي'),
                  selected: widget.privilegeFilter ==
                      _AdminUsersPrivilegeFilter.regular,
                  onSelected: (_) => widget.onPrivilegeFilterChanged(
                      _AdminUsersPrivilegeFilter.regular),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _UsersSummaryStrip extends StatelessWidget {
  const _UsersSummaryStrip({required this.allRows, required this.visibleRows});

  final List<Map<String, dynamic>> allRows;
  final List<Map<String, dynamic>> visibleRows;

  @override
  Widget build(BuildContext context) {
    int countOperational(String key) =>
        allRows.where((row) => _operationalRoleKey(row) == key).length;
    final activeCount = allRows.where((row) => row['is_active'] == true).length;
    final inactiveCount = allRows.length - activeCount;
    final centralCount = allRows
        .where((row) => (row['unit_id'] ?? '').toString().trim().isEmpty)
        .length;
    final unitScopedCount = allRows.length - centralCount;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _MetricCard(
            title: 'إجمالي الحسابات',
            value: allRows.length.toString(),
            icon: Icons.groups_2_outlined),
        _MetricCard(
            title: 'المعروضة بعد الفلاتر',
            value: visibleRows.length.toString(),
            icon: Icons.filter_alt_outlined,
            accent: const Color(0xFF7A1F2B)),
        _MetricCard(
            title: 'حسابات مركزية',
            value: centralCount.toString(),
            icon: Icons.account_tree_outlined,
            accent: const Color(0xFFC9A227)),
        _MetricCard(
            title: 'حسابات وحدوية',
            value: unitScopedCount.toString(),
            icon: Icons.apartment_outlined,
            accent: const Color(0xFF0F4C81)),
        _MetricCard(
            title: 'Superuser',
            value: countOperational('superuser').toString(),
            icon: Icons.workspace_premium_outlined,
            accent: const Color(0xFF7C3AED)),
        _MetricCard(
            title: 'Power Admin',
            value: countOperational('power_admin').toString(),
            icon: Icons.hub_outlined,
            accent: const Color(0xFFB22222)),
        _MetricCard(
            title: 'مدراء وحدات',
            value: countOperational('unit_admin').toString(),
            icon: Icons.admin_panel_settings_outlined,
            accent: const Color(0xFF1D4ED8)),
        _MetricCard(
            title: 'مشرفو الأنظمة',
            value: countOperational('system_super_user').toString(),
            icon: Icons.settings_applications_outlined,
            accent: const Color(0xFFB45309)),
        _MetricCard(
            title: 'موظفون',
            value: countOperational('employee').toString(),
            icon: Icons.badge_outlined,
            accent: const Color(0xFF047857)),
        _MetricCard(
            title: 'وكلاء مفوضون',
            value: countOperational('delegate_lawyer').toString(),
            icon: Icons.balance_outlined,
            accent: const Color(0xFF8B5CF6)),
        _MetricCard(
            title: 'مشاهدون (تجريبي)',
            value: countOperational('viewer_experimental').toString(),
            icon: Icons.remove_red_eye_outlined,
            accent: const Color(0xFF6B7280)),
        _MetricCard(
            title: 'نشطة',
            value: activeCount.toString(),
            icon: Icons.verified_user_outlined,
            accent: const Color(0xFF1D7A46)),
        _MetricCard(
            title: 'غير نشطة',
            value: inactiveCount.toString(),
            icon: Icons.person_off_outlined,
            accent: const Color(0xFFB22222)),
      ],
    );
  }
}

class _UsersPolicyFrameworkCard extends StatelessWidget {
  const _UsersPolicyFrameworkCard();

  @override
  Widget build(BuildContext context) {
    const items = <Map<String, String>>[
      {
        'title': 'سوبر يوزر',
        'desc':
            'مسؤول عن كل وحدات المنصة وكل الأنظمة، وحسابه محمي ولا يجوز حذفه.'
      },
      {
        'title': 'Power Admin',
        'desc': 'مسؤول عن نظام واحد يعمل عبر جميع الوحدات التي تتبعه.'
      },
      {
        'title': 'مدير وحدة',
        'desc':
            'مسؤول عن جميع الصفحات والخدمات والمستخدمين المتعلقة بوحدته الإدارية.'
      },
      {
        'title': 'مشرف نظام الوحدة',
        'desc':
            'أعلى من الموظف وأقل من Power Admin، ويتابع العاملين على نفس النظام داخل الوحدة.'
      },
      {
        'title': 'موظف',
        'desc': 'صلاحيات تشغيلية عادية مثل الإضافة والتعديل ضمن النطاق الممنوح.'
      },
      {
        'title': 'وكيل قانوني مفوض',
        'desc':
            'نطاق خاص في نظام القضايا أو الأنظمة المتخصصة على وحدات موكلة محددة.'
      },
      {
        'title': 'مشاهد (تجريبي)',
        'desc':
            'دور تجريبي مؤقت للحسابات الحالية وسيُزال من المسار التشغيلي النهائي.'
      },
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('إطار السياسات المعتمد للمستخدمين',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text(
              'تُدار لوحة المستخدمين الآن وفق فصل واضح بين الدور التنظيمي، نطاق الوحدة، والإشراف النظامي عبر الوحدات أو داخل الوحدة نفسها.',
              style: TextStyle(color: Color(0xFF4B5563), height: 1.55)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final item in items)
                SizedBox(
                  width: 280,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F4C81))),
                        const SizedBox(height: 6),
                        Text(item['desc']!,
                            style: const TextStyle(
                                color: Color(0xFF4B5563), height: 1.5)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsersBulkActionBar extends ConsumerWidget {
  const _UsersBulkActionBar({
    required this.visibleRows,
    required this.selectedIds,
    required this.actorIsSuperuser,
    required this.canToggleActive,
    required this.canManageSuperuser,
  });

  final List<Map<String, dynamic>> visibleRows;
  final Set<String> selectedIds;
  final bool actorIsSuperuser;
  final bool canToggleActive;
  final bool canManageSuperuser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRows = visibleRows
        .where((row) => selectedIds.contains((row['id'] ?? '').toString()))
        .toList();
    final note = ref.watch(_adminUsersActionNoteProvider);
    final hasSelection = selectedRows.isNotEmpty;

    Future<void> runBulk(String action,
        Future<void> Function(Map<String, dynamic> row) onEach) async {
      if (!hasSelection) return;
      for (final row in selectedRows) {
        await onEach(row);
        final targetId = (row['id'] ?? '').toString();
        if (targetId.trim().isEmpty) continue;
        await _logAdminUsersAudit(
          ref,
          actionKey: 'bulk_${action.replaceAll(' ', '_')}',
          title: 'إدارة المستخدمين - إجراء جماعي: $action',
          targetUserId: targetId,
          metadata: {
            'bulk_action': action,
            'target_email': (row['email'] ?? '').toString(),
            'target_name': (row['name'] ?? '').toString(),
            if (note.trim().isNotEmpty) 'note': note.trim(),
          },
        );
      }
      ref.invalidate(adminUsersListProvider);
      ref.read(_selectedAdminUserIdsProvider.notifier).state = <String>{};
      if (context.mounted) {
        final suffix = note.trim().isEmpty ? '' : ' — ملاحظة: ${note.trim()}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'تم تنفيذ $action على ${selectedRows.length} مستخدم$suffix')),
        );
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إجراءات جماعية للمستخدمين',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectionLabel(selectedRows.length, visibleRows.length),
                      style: const TextStyle(
                          color: Color(0xFF4B5563), height: 1.5),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: visibleRows.isEmpty
                    ? null
                    : () {
                        ref.read(_selectedAdminUserIdsProvider.notifier).state =
                            visibleRows
                                .map((row) => (row['id'] ?? '').toString())
                                .where((id) => id.trim().isNotEmpty)
                                .toSet();
                      },
                icon: const Icon(Icons.done_all_outlined),
                label: const Text('تحديد النتائج'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: hasSelection
                    ? () => ref
                        .read(_selectedAdminUserIdsProvider.notifier)
                        .state = <String>{}
                    : null,
                icon: const Icon(Icons.clear_all_outlined),
                label: const Text('إلغاء التحديد'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'ملاحظة تشغيلية قبل الإجراء (اختياري)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) =>
                ref.read(_adminUsersActionNoteProvider.notifier).state = value,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: (hasSelection && canToggleActive)
                    ? () => runBulk(
                        'التفعيل',
                        (row) =>
                            ref.read(adminUsersRepositoryProvider).setActive(
                                  userId: (row['id'] ?? '').toString(),
                                  isActive: true,
                                ))
                    : null,
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text('تفعيل المحدد'),
              ),
              OutlinedButton.icon(
                onPressed: (hasSelection && canToggleActive)
                    ? () => runBulk(
                        'التعطيل',
                        (row) =>
                            ref.read(adminUsersRepositoryProvider).setActive(
                                  userId: (row['id'] ?? '').toString(),
                                  isActive: false,
                                ))
                    : null,
                icon: const Icon(Icons.person_off_outlined),
                label: const Text('تعطيل المحدد'),
              ),
              OutlinedButton.icon(
                onPressed: (hasSelection && canManageSuperuser)
                    ? () => runBulk(
                        'منح Superuser',
                        (row) =>
                            ref.read(adminUsersRepositoryProvider).setSuperuser(
                                  userId: (row['id'] ?? '').toString(),
                                  isSuperuser: true,
                                ))
                    : null,
                icon: const Icon(Icons.workspace_premium_outlined),
                label: const Text('منح Superuser'),
              ),
              OutlinedButton.icon(
                onPressed: (hasSelection && canManageSuperuser)
                    ? () => runBulk(
                        'سحب Superuser',
                        (row) =>
                            ref.read(adminUsersRepositoryProvider).setSuperuser(
                                  userId: (row['id'] ?? '').toString(),
                                  isSuperuser: false,
                                ))
                    : null,
                icon: const Icon(Icons.remove_moderator_outlined),
                label: const Text('سحب Superuser'),
              ),
              OutlinedButton.icon(
                onPressed: hasSelection
                    ? () async {
                        final ids = selectedRows
                            .map((row) => (row['id'] ?? '').toString())
                            .join('\n');
                        await Clipboard.setData(ClipboardData(text: ids));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('تم نسخ معرفات المستخدمين المحددين')),
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('نسخ المعرفات'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsersAuditHintCard extends StatelessWidget {
  const _UsersAuditHintCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'مراجعة تشغيلية للمستخدمين',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          Text(
            'قبل منح أو سحب أي صلاحية، راجع: الدور، النطاق، هل الحساب نشط، وهل هو Superuser، ثم افتح إدارة الأدوار/الصلاحيات من نفس الصف.',
            style: TextStyle(color: Color(0xFF4B5563), height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _UsersTable extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  final Set<String> selectedIds;
  final String actorUserId;
  final bool actorIsSuperuser;
  final bool canToggleActive;
  final bool canManageSuperuser;
  final bool canManageAccess;
  final bool canSelectRows;
  final AdminUser? actorUser;
  final void Function(String userId, bool selected) onSelectionChanged;
  final void Function(bool selected) onSelectVisible;
  final Future<void> Function(String userId, bool value) onToggleActive;
  final Future<void> Function(String userId, bool value) onToggleSuperuser;
  final void Function(Map<String, dynamic> row) onViewDetails;
  final void Function(Map<String, dynamic> row) onEditUser;
  final Future<void> Function(Map<String, dynamic> row) onResetPassword;

  const _UsersTable({
    required this.rows,
    required this.selectedIds,
    required this.actorUserId,
    required this.actorIsSuperuser,
    required this.canToggleActive,
    required this.canManageSuperuser,
    required this.canManageAccess,
    required this.canSelectRows,
    required this.actorUser,
    required this.onSelectionChanged,
    required this.onSelectVisible,
    required this.onToggleActive,
    required this.onToggleSuperuser,
    required this.onViewDetails,
    required this.onEditUser,
    required this.onResetPassword,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Text('لا يوجد مستخدمون مطابقون.'),
      ));
    }

    final selectedVisibleCount = rows
        .where((row) => selectedIds.contains((row['id'] ?? '').toString()))
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cardWidth = width >= 1500
            ? (width - 24) / 3
            : width >= 980
                ? (width - 12) / 2
                : width;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (canSelectRows)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilterChip(
                      selected: rows.isNotEmpty &&
                          selectedVisibleCount == rows.length,
                      label: Text(
                          rows.isNotEmpty && selectedVisibleCount == rows.length
                              ? 'إلغاء تحديد المعروض'
                              : 'تحديد المعروض'),
                      onSelected: (value) => onSelectVisible(value),
                    ),
                    Text(
                      _selectionLabel(selectedVisibleCount, rows.length),
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final row in rows)
                  SizedBox(
                    width: cardWidth,
                    child: _UserCard(
                      row: row,
                      selected:
                          selectedIds.contains((row['id'] ?? '').toString()),
                      actorUserId: actorUserId,
                      actorIsSuperuser: actorIsSuperuser,
                      canToggleActive: canToggleActive,
                      canManageSuperuser: canManageSuperuser,
                      canManageAccess: canManageAccess,
                      canSelectRows: canSelectRows,
                      actorUser: actorUser,
                      onSelectionChanged: (selected) => onSelectionChanged(
                          (row['id'] ?? '').toString(), selected),
                      onToggleActive: onToggleActive,
                      onToggleSuperuser: onToggleSuperuser,
                      onViewDetails: onViewDetails,
                      onEditUser: onEditUser,
                      onResetPassword: onResetPassword,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.row,
    required this.selected,
    required this.actorUserId,
    required this.actorIsSuperuser,
    required this.canToggleActive,
    required this.canManageSuperuser,
    required this.canManageAccess,
    required this.canSelectRows,
    required this.actorUser,
    required this.onSelectionChanged,
    required this.onToggleActive,
    required this.onToggleSuperuser,
    required this.onViewDetails,
    required this.onEditUser,
    required this.onResetPassword,
  });

  final Map<String, dynamic> row;
  final bool selected;
  final String actorUserId;
  final bool actorIsSuperuser;
  final bool canToggleActive;
  final bool canManageSuperuser;
  final bool canManageAccess;
  final bool canSelectRows;
  final AdminUser? actorUser;
  final void Function(bool selected) onSelectionChanged;
  final Future<void> Function(String userId, bool value) onToggleActive;
  final Future<void> Function(String userId, bool value) onToggleSuperuser;
  final void Function(Map<String, dynamic> row) onViewDetails;
  final void Function(Map<String, dynamic> row) onEditUser;
  final Future<void> Function(Map<String, dynamic> row) onResetPassword;

  @override
  Widget build(BuildContext context) {
    final id = (row['id'] ?? '').toString();
    final name = (row['display_name'] ??
            row['name'] ??
            row['username'] ??
            row['email'] ??
            '')
        .toString();
    final username = (row['username'] ?? '').toString();
    final email = (row['email'] ?? '').toString();
    final role = (row['role'] ?? '').toString();
    final roleLabel =
        (row['role_label_ar'] ?? _adminRoleLabel(role, row: row)).toString();
    final scopeLabel = (row['scope_label'] ?? _adminScopeLabel(row)).toString();
    final unitName = (row['unit_name_ar'] ?? '').toString();
    final phone = (row['phone'] ?? '').toString();
    final governorate = (row['governorate'] ?? '').toString();
    final lastLogin = (row['last_login'] ?? '').toString();
    final isActive = row['is_active'] == true;
    final isSuper = row['is_superuser'] == true;
    final isSelf = actorUserId.isNotEmpty && actorUserId == id;
    final accent = isSuper ? const Color(0xFF7C3AED) : const Color(0xFF0F4C81);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF8FBFF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? accent.withValues(alpha: 0.45)
              : const Color(0xFFE5E7EB),
          width: selected ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (canSelectRows)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Checkbox(
                      value: selected,
                      onChanged: (v) => onSelectionChanged(v == true)),
                ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: accent.withValues(alpha: 0.12),
                      backgroundImage: ((row['avatar_url'] ?? '')
                              .toString()
                              .trim()
                              .isNotEmpty)
                          ? NetworkImage((row['avatar_url'] ?? '').toString())
                          : null,
                      child:
                          ((row['avatar_url'] ?? '').toString().trim().isEmpty)
                              ? Text(
                                  _buildInitials(row),
                                  style: TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.w900),
                                )
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          if (email.trim().isNotEmpty)
                            Text(email,
                                style:
                                    const TextStyle(color: Color(0xFF6B7280))),
                          if (username.trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('@$username',
                                  style: TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'إجراءات',
                onSelected: (value) async {
                  switch (value) {
                    case 'details':
                      onViewDetails(row);
                      break;
                    case 'edit':
                      onEditUser(row);
                      break;
                    case 'access':
                      if (!canManageAccess) return;
                      await showDialog(
                        context: context,
                        builder: (_) => _UserAccessDialog(
                          userId: id,
                          title: name,
                        ),
                      );
                      break;
                    case 'reset':
                      await onResetPassword(row);
                      break;
                    case 'copy_id':
                      await Clipboard.setData(ClipboardData(text: id));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم نسخ المعرّف')));
                      }
                      break;
                    case 'copy_email':
                      if (email.trim().isEmpty) return;
                      await Clipboard.setData(ClipboardData(text: email));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم نسخ البريد')));
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'details', child: Text('تفاصيل المستخدم')),
                  if (canManageAccess)
                    const PopupMenuItem(
                        value: 'edit', child: Text('تعديل البيانات')),
                  if (canManageAccess)
                    const PopupMenuItem(
                        value: 'access', child: Text('الصلاحيات والنطاقات')),
                  if (email.trim().isNotEmpty)
                    const PopupMenuItem(
                        value: 'reset', child: Text('إعادة تعيين كلمة المرور')),
                  const PopupMenuItem(
                      value: 'copy_id', child: Text('نسخ UUID')),
                  if (email.trim().isNotEmpty)
                    const PopupMenuItem(
                        value: 'copy_email', child: Text('نسخ البريد')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DetailChip(label: roleLabel, color: accent),
              _DetailChip(label: scopeLabel, color: const Color(0xFF0F4C81)),
              _DetailChip(
                  label: isActive ? 'نشط' : 'غير نشط',
                  color: isActive
                      ? const Color(0xFF1D7A46)
                      : const Color(0xFFB22222)),
              if (isSuper)
                _DetailChip(label: 'Superuser', color: const Color(0xFF7C3AED)),
              if (((row['scope_assignments_count'] ?? 0) as num) > 0)
                _DetailChip(
                    label: 'نطاقات: ${row['scope_assignments_count']}',
                    color: const Color(0xFF8B5CF6)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _InfoRow(
                    label: 'الوحدة',
                    value: unitName.isNotEmpty ? unitName : scopeLabel),
                if ((row['governance_scope_description'] ?? '')
                    .toString()
                    .trim()
                    .isNotEmpty)
                  _InfoRow(
                      label: 'الوصف الحوكمي',
                      value: (row['governance_scope_description'] ?? '')
                          .toString()),
                if ((row['scope_units_summary'] ?? '')
                    .toString()
                    .trim()
                    .isNotEmpty)
                  _InfoRow(
                      label: 'الوحدات الموكلة',
                      value: (row['scope_units_summary'] ?? '').toString()),
                _InfoRow(
                    label: 'المحافظة',
                    value: governorate.isNotEmpty ? governorate : '—'),
                _InfoRow(
                    label: 'الهاتف', value: phone.isNotEmpty ? phone : '—'),
                _InfoRow(
                    label: 'آخر دخول',
                    value: lastLogin.isNotEmpty ? lastLogin : '—'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ToggleActionCard(
                title: 'نشط',
                subtitle:
                    isSelf ? 'لا يمكن تعديل حسابك هنا' : 'تفعيل/تعطيل الحساب',
                value: isActive,
                enabled: canToggleActive && !isSelf,
                onChanged: (v) async {
                  await onToggleActive(id, v);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              v ? 'تم تفعيل المستخدم' : 'تم تعطيل المستخدم')),
                    );
                  }
                },
                color: const Color(0xFF1D7A46),
              ),
              if (canManageSuperuser)
                _ToggleActionCard(
                  title: 'Superuser',
                  subtitle: (!actorIsSuperuser || isSelf)
                      ? 'غير متاح'
                      : 'منح/سحب الصفة',
                  value: isSuper,
                  enabled: actorIsSuperuser && !isSelf,
                  onChanged: (v) async {
                    await onToggleSuperuser(id, v);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(v
                                ? 'تم جعل المستخدم سوبر'
                                : 'تم إلغاء السوبر')),
                      );
                    }
                  },
                  color: const Color(0xFF7C3AED),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => onViewDetails(row),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('التفاصيل'),
              ),
              if (canManageAccess)
                OutlinedButton.icon(
                  onPressed: () => onEditUser(row),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('تعديل'),
                ),
              if (canManageAccess)
                OutlinedButton.icon(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (_) =>
                          _UserAccessDialog(userId: id, title: name),
                    );
                  },
                  icon: const Icon(Icons.manage_accounts_outlined),
                  label: const Text('الصلاحيات والنطاقات'),
                ),
              if (email.trim().isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () async => onResetPassword(row),
                  icon: const Icon(Icons.lock_reset_outlined),
                  label: const Text('إعادة التعيين'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(label,
                style: const TextStyle(
                    color: Color(0xFF6B7280), fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _ToggleActionCard extends StatelessWidget {
  const _ToggleActionCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.color,
  });

  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontWeight: FontWeight.w800, color: color)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Switch(value: value, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}

class _UsersRecentAuditPanel extends StatelessWidget {
  const _UsersRecentAuditPanel({required this.auditAsync});

  final AsyncValue<List<UserActivityLogItem>> auditAsync;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: auditAsync.when(
        data: (items) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('سجل التدقيق الفعلي للمستخدمين',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800)),
                        SizedBox(height: 6),
                        Text(
                            'يعرض آخر العمليات المسجلة فعليًا على مسار /admin/users إن كانت جداول الأوديت متاحة في قاعدة البيانات.',
                            style: TextStyle(
                                color: Color(0xFF4B5563), height: 1.5)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('${items.length} سجل',
                        style: const TextStyle(
                            color: Color(0xFF0F4C81),
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const Text(
                    'لا توجد سجلات تدقيق مرئية حتى الآن، أو أن جدول الأوديت غير متاح في هذه البيئة.')
              else
                ...items.take(8).map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F4C81)
                                  .withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.fact_check_outlined,
                                color: Color(0xFF0F4C81)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(
                                  'الهدف: ${(item.entityId ?? '').isEmpty ? 'غير محدد' : item.entityId} — ${item.createdAt.toLocal()}',
                                  style: const TextStyle(
                                      color: Color(0xFF6B7280), fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('تعذر تحميل سجل التدقيق: $e'),
      ),
    );
  }
}

class _ForbiddenInline extends StatelessWidget {
  final String message;

  const _ForbiddenInline({
    this.message =
        'غير مصرح لك بإدارة المستخدمين.\nتحتاج صلاحية مناسبة أو نطاقًا يسمح بإدارة المستخدمين.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorBox({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class _UserDetailsDialog extends ConsumerWidget {
  const _UserDetailsDialog({
    required this.row,
    required this.actorIsSuperuser,
    required this.actorUser,
  });

  final Map<String, dynamic> row;
  final bool actorIsSuperuser;
  final AdminUser? actorUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = (row['id'] ?? '').toString();
    final name = ((row['name'] ??
                row['display_name'] ??
                row['username'] ??
                row['email']) ??
            '')
        .toString();
    final username = (row['username'] ?? '').toString();
    final email = (row['email'] ?? '').toString();
    final role = (row['role'] ?? '').toString();
    final roleLabel =
        (row['role_label_ar'] ?? _adminRoleLabel(role, row: row)).toString();
    final scopeLabel = (row['scope_label'] ?? _adminScopeLabel(row)).toString();
    final isActive = row['is_active'] == true;
    final isSuperuser = row['is_superuser'] == true;
    final accent = _roleAccent(role, row: row);
    final rolesAsync = ref.watch(userSystemRolesProvider(userId));
    final permissionsAsync = ref.watch(userSystemPermissionsProvider(userId));
    final auditAsync = ref.watch(adminUsersRecentAuditProvider);

    Widget summaryCard(
        {required String title,
        required String value,
        required IconData icon,
        Color? color}) {
      final c = color ?? accent;
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: c),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 12.5, color: Color(0xFF6B7280))),
                  const SizedBox(height: 4),
                  Text(value,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800, color: c)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 980,
          height: 720,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                    const Spacer(),
                    const Text(
                      'تفاصيل المستخدم',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accent.withValues(alpha: 0.12),
                                Colors.white
                              ],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: accent.withValues(alpha: 0.18)),
                          ),
                          child: Wrap(
                            spacing: 18,
                            runSpacing: 18,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 42,
                                backgroundColor: accent.withValues(alpha: 0.12),
                                backgroundImage: ((row['avatar_url'] ?? '')
                                        .toString()
                                        .trim()
                                        .isNotEmpty)
                                    ? NetworkImage(
                                        (row['avatar_url'] ?? '').toString())
                                    : null,
                                child: ((row['avatar_url'] ?? '')
                                        .toString()
                                        .trim()
                                        .isEmpty)
                                    ? Text(
                                        _buildInitials(row),
                                        style: TextStyle(
                                            color: accent,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 24),
                                      )
                                    : null,
                              ),
                              SizedBox(
                                width: 280,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name,
                                        style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 8),
                                    if (email.trim().isNotEmpty)
                                      Text(email,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF4B5563))),
                                    if (username.trim().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text('@$username',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: accent,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _DetailChip(
                                            label: roleLabel, color: accent),
                                        _DetailChip(
                                            label: scopeLabel,
                                            color: const Color(0xFF0F4C81)),
                                        _DetailChip(
                                            label: isActive ? 'نشط' : 'غير نشط',
                                            color: isActive
                                                ? const Color(0xFF1D7A46)
                                                : const Color(0xFFB22222)),
                                        if (isSuperuser)
                                          _DetailChip(
                                              label: 'Superuser',
                                              color: const Color(0xFF7C3AED)),
                                        if (((row['scope_assignments_count'] ??
                                                0) as num) >
                                            0)
                                          _DetailChip(
                                              label:
                                                  'نطاقات: ${row['scope_assignments_count']}',
                                              color: const Color(0xFF8B5CF6)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 300,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('إجراءات سريعة',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final updated =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (_) =>
                                                  _EditAdminUserDialog(
                                                      row: row,
                                                      isSuperuserActor:
                                                          actorIsSuperuser,
                                                      actorUser: actorUser),
                                            );
                                            if (updated == true) {
                                              ref.invalidate(
                                                  adminUsersListProvider);
                                            }
                                          },
                                          icon: const Icon(Icons.edit_outlined),
                                          label: const Text('تعديل البيانات'),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed: () async {
                                            await showDialog(
                                              context: context,
                                              builder: (_) => _UserAccessDialog(
                                                  userId: userId, title: name),
                                            );
                                          },
                                          icon: const Icon(
                                              Icons.manage_accounts_outlined),
                                          label: const Text('إدارة الصلاحيات'),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed: email.trim().isEmpty
                                              ? null
                                              : () async {
                                                  final ok =
                                                      await showDialog<bool>(
                                                    context: context,
                                                    builder: (_) =>
                                                        Directionality(
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      child: AlertDialog(
                                                        title: const Text(
                                                            'إعادة تعيين كلمة المرور'),
                                                        content: Text(
                                                            'سيتم إرسال رابط إعادة تعيين كلمة المرور إلى\n$email'),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context,
                                                                      false),
                                                              child: const Text(
                                                                  'إلغاء')),
                                                          ElevatedButton.icon(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context,
                                                                    true),
                                                            icon: const Icon(Icons
                                                                .lock_reset_outlined),
                                                            label: const Text(
                                                                'إرسال الرابط'),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                  if (ok != true) return;
                                                  try {
                                                    await ref
                                                        .read(
                                                            authRepositoryProvider)
                                                        .resetPassword(email);
                                                    await _logAdminUsersAudit(
                                                      ref,
                                                      actionKey:
                                                          'reset_password_email',
                                                      title:
                                                          'إدارة المستخدمين - إرسال رابط إعادة تعيين كلمة المرور',
                                                      targetUserId: userId,
                                                      metadata: {
                                                        'email': email
                                                      },
                                                    );
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                'تم إرسال رابط إعادة التعيين إلى $email')),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(e
                                                                  .toString())));
                                                    }
                                                  }
                                                },
                                          icon: const Icon(
                                              Icons.lock_reset_outlined),
                                          label: const Text(
                                              'إعادة تعيين كلمة المرور'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final itemWidth = constraints.maxWidth >= 1100
                                ? (constraints.maxWidth - 24) / 3
                                : constraints.maxWidth >= 700
                                    ? (constraints.maxWidth - 12) / 2
                                    : constraints.maxWidth;
                            final auditItems = auditAsync.valueOrNull
                                    ?.where((item) =>
                                        (item.entityId ?? '').trim() == userId)
                                    .take(4)
                                    .toList() ??
                                const <UserActivityLogItem>[];
                            final rolesCount =
                                rolesAsync.valueOrNull?.length ?? 0;
                            final permsCount =
                                permissionsAsync.valueOrNull?.length ?? 0;
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                    width: itemWidth,
                                    child: summaryCard(
                                        title: 'أدوار نظامية',
                                        value: '$rolesCount',
                                        icon: Icons.badge_outlined,
                                        color: const Color(0xFF1D4ED8))),
                                SizedBox(
                                    width: itemWidth,
                                    child: summaryCard(
                                        title: 'صلاحيات مباشرة',
                                        value: '$permsCount',
                                        icon: Icons.verified_user_outlined,
                                        color: const Color(0xFF0F766E))),
                                SizedBox(
                                    width: itemWidth,
                                    child: summaryCard(
                                        title: 'عمليات تدقيق حديثة',
                                        value: '${auditItems.length}',
                                        icon: Icons.fact_check_outlined,
                                        color: const Color(0xFFB45309))),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final itemWidth = constraints.maxWidth >= 1100
                                ? (constraints.maxWidth - 24) / 3
                                : constraints.maxWidth >= 700
                                    ? (constraints.maxWidth - 12) / 2
                                    : constraints.maxWidth;
                            final auditItems = auditAsync.valueOrNull
                                    ?.where((item) =>
                                        (item.entityId ?? '').trim() == userId)
                                    .take(4)
                                    .toList() ??
                                const <UserActivityLogItem>[];
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: itemWidth,
                                  child: _InfoPanel(
                                    title: 'المعلومات الأساسية',
                                    color: const Color(0xFFF3F8F2),
                                    children: [
                                      _InfoRow(
                                          label: 'الدور', value: roleLabel),
                                      _InfoRow(
                                          label: 'النطاق', value: scopeLabel),
                                      if ((row['governance_scope_description'] ??
                                              '')
                                          .toString()
                                          .trim()
                                          .isNotEmpty)
                                        _InfoRow(
                                            label: 'الوصف الحوكمي',
                                            value:
                                                (row['governance_scope_description'] ??
                                                        '')
                                                    .toString()),
                                      if ((row['scope_units_summary'] ?? '')
                                          .toString()
                                          .trim()
                                          .isNotEmpty)
                                        _InfoRow(
                                            label: 'الوحدات الموكلة',
                                            value:
                                                (row['scope_units_summary'] ??
                                                        '')
                                                    .toString()),
                                      _InfoRow(
                                          label: 'الوحدة',
                                          value: ((row['unit_name_ar'] ??
                                                  row['unit_slug'] ??
                                                  'مركزي')
                                              .toString())),
                                      _InfoRow(
                                          label: 'القسم',
                                          value: ((row['department'] ?? '—')
                                              .toString())),
                                      _InfoRow(
                                          label: 'المحافظة',
                                          value: ((row['governorate'] ?? '—')
                                              .toString())),
                                      _InfoRow(
                                          label: 'الهاتف',
                                          value: ((row['phone'] ?? '—')
                                              .toString())),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: _InfoPanel(
                                    title: 'الأمان والحساب',
                                    color: const Color(0xFFF8F8FC),
                                    children: [
                                      _InfoRow(
                                          label: 'الحالة',
                                          value:
                                              isActive ? 'مفعّل' : 'غير مفعّل'),
                                      _InfoRow(
                                          label: 'Superuser',
                                          value: isSuperuser ? 'نعم' : 'لا'),
                                      _InfoRow(
                                          label: 'آخر دخول',
                                          value: _formatDateTime(
                                              row['last_login'])),
                                      _InfoRow(
                                          label: 'تاريخ الإنشاء',
                                          value: _formatDateTime(
                                              row['created_at'])),
                                      _InfoRow(
                                          label: 'آخر تحديث',
                                          value: _formatDateTime(
                                              row['updated_at'])),
                                      _InfoRow(label: 'UUID', value: userId),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: _InfoPanel(
                                    title: 'معاينة نشاط الإدارة',
                                    color: const Color(0xFFFFFBEB),
                                    children: auditItems.isEmpty
                                        ? const [
                                            Text(
                                                'لا توجد عمليات تدقيق حديثة لهذا المستخدم.')
                                          ]
                                        : auditItems
                                            .map((item) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(item.title,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700)),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                          _formatDateTime(
                                                              item.createdAt),
                                                          style: const TextStyle(
                                                              fontSize: 12.5,
                                                              color: Color(
                                                                  0xFF6B7280))),
                                                    ],
                                                  ),
                                                ))
                                            .toList(),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('الصلاحيات والأدوار الحالية',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 12),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final itemWidth = constraints.maxWidth >= 1000
                                      ? (constraints.maxWidth - 12) / 2
                                      : constraints.maxWidth;
                                  return Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      SizedBox(
                                        width: itemWidth,
                                        child: _AsyncInfoPanel(
                                          title: 'الأدوار النظامية',
                                          asyncValue: rolesAsync,
                                          emptyText:
                                              'لا توجد أدوار نظامية لهذا المستخدم.',
                                          builder: (rows) => Column(
                                            children: rows.map((roleRow) {
                                              final systemKey =
                                                  (roleRow['system_key'] ?? '')
                                                      .toString();
                                              final roleText =
                                                  (roleRow['role'] ?? '')
                                                      .toString();
                                              return ListTile(
                                                dense: true,
                                                contentPadding: EdgeInsets.zero,
                                                leading: const Icon(
                                                    Icons.badge_outlined),
                                                title: Text(_systemLabelFromKey(
                                                    systemKey)),
                                                subtitle:
                                                    Text('الدور: $roleText'),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: itemWidth,
                                        child: _AsyncInfoPanel(
                                          title: 'الصلاحيات المباشرة',
                                          asyncValue: permissionsAsync,
                                          emptyText:
                                              'لا توجد صلاحيات مباشرة لهذا المستخدم.',
                                          builder: (rows) => Column(
                                            children: rows.map((permRow) {
                                              final systemKey =
                                                  (permRow['system_key'] ?? '')
                                                      .toString();
                                              final permissionText =
                                                  (permRow['permission_key'] ??
                                                          '')
                                                      .toString();
                                              return ListTile(
                                                dense: true,
                                                contentPadding: EdgeInsets.zero,
                                                leading: const Icon(
                                                    Icons.key_outlined),
                                                title: Text(_systemLabelFromKey(
                                                    systemKey)),
                                                subtitle: Text(
                                                    'الصلاحية: $permissionText'),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditAdminUserDialog extends ConsumerStatefulWidget {
  const _EditAdminUserDialog({
    required this.row,
    required this.isSuperuserActor,
    required this.actorUser,
  });

  final Map<String, dynamic> row;
  final bool isSuperuserActor;
  final AdminUser? actorUser;

  @override
  ConsumerState<_EditAdminUserDialog> createState() =>
      _EditAdminUserDialogState();
}

class _EditAdminUserDialogState extends ConsumerState<_EditAdminUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _deptCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _avatarCtrl;
  late String _role;
  late bool _isActive;
  late bool _isSuperuser;
  String? _selectedUnitId;
  String? _selectedGovernorate;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl =
        TextEditingController(text: (widget.row['email'] ?? '').toString());
    _nameCtrl =
        TextEditingController(text: (widget.row['name'] ?? '').toString());
    _usernameCtrl =
        TextEditingController(text: (widget.row['username'] ?? '').toString());
    _deptCtrl = TextEditingController(
        text: (widget.row['department'] ?? '').toString());
    _phoneCtrl =
        TextEditingController(text: (widget.row['phone'] ?? '').toString());
    _avatarCtrl = TextEditingController(
        text: (widget.row['avatar_url'] ?? '').toString());
    _role = (widget.row['role'] ?? 'admin').toString();
    _isActive = widget.row['is_active'] == true;
    _isSuperuser = widget.row['is_superuser'] == true;
    _selectedUnitId = (widget.row['unit_id'] ?? '').toString().trim().isEmpty
        ? null
        : (widget.row['unit_id'] ?? '').toString();
    _selectedGovernorate =
        (widget.row['governorate'] ?? '').toString().trim().isEmpty
            ? null
            : (widget.row['governorate'] ?? '').toString();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _deptCtrl.dispose();
    _phoneCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  bool get _requiresUnit => !_isSuperuser;

  List<Map<String, String>> _allowedRoles() {
    return _allowedPersistedRolesForActor(
      widget.actorUser,
      widget.isSuperuserActor,
      currentRole: (widget.row['role'] ?? '').toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(adminUsersActiveUnitsProvider);
    final roleOptions = _allowedRoles();
    const governorates = <String>[
      'NAB',
      'JEN',
      'RAM',
      'BTH',
      'HEB',
      'TUL',
      'QAL',
      'SAL',
      'TBS',
      'JER'
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('تعديل بيانات المستخدم'),
        content: SizedBox(
          width: 720,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 330,
                        child: TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                              labelText: 'الاسم الكامل',
                              border: OutlineInputBorder()),
                          validator: (v) =>
                              (v ?? '').trim().isEmpty ? 'مطلوب' : null,
                        ),
                      ),
                      SizedBox(
                        width: 330,
                        child: TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                              labelText: 'البريد الإلكتروني',
                              border: OutlineInputBorder()),
                          validator: (v) => ((v ?? '').trim().contains('@'))
                              ? null
                              : 'بريد غير صحيح',
                        ),
                      ),
                      SizedBox(
                        width: 330,
                        child: TextFormField(
                          controller: _usernameCtrl,
                          decoration: const InputDecoration(
                              labelText: 'اسم المستخدم',
                              border: OutlineInputBorder()),
                          validator: (v) =>
                              (v ?? '').trim().isEmpty ? 'مطلوب' : null,
                        ),
                      ),
                      SizedBox(
                        width: 330,
                        child: DropdownButtonFormField<String>(
                          value: _role,
                          decoration: const InputDecoration(
                              labelText: 'الدور الإداري الأساسي',
                              border: OutlineInputBorder()),
                          items: roleOptions
                              .map((r) => DropdownMenuItem(
                                  value: r['value'], child: Text(r['label']!)))
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _role = v;
                              if (_role == 'super_admin') {
                                _isSuperuser = true;
                                _selectedUnitId = null;
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 330,
                        child: unitsAsync.when(
                          data: (units) {
                            final filteredUnits = _filterUnitsForActor(
                              units
                                  .map((row) => {
                                        'id': (row['id'] ?? '').toString(),
                                        'label': ((row['name_ar'] ??
                                                row['slug'] ??
                                                row['name_en'] ??
                                                '')
                                            .toString()),
                                      })
                                  .toList(),
                              widget.actorUser,
                              null,
                            );
                            return DropdownButtonFormField<String?>(
                              value: _selectedUnitId,
                              decoration: const InputDecoration(
                                  labelText: 'الوحدة',
                                  border: OutlineInputBorder()),
                              items: [
                                const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('بدون وحدة / مركزي')),
                                ...filteredUnits.map((u) =>
                                    DropdownMenuItem<String?>(
                                      value: (u['id'] ?? '').toString(),
                                      child:
                                          Text((u['label'] ?? '').toString()),
                                    )),
                              ],
                              onChanged: (_role == 'super_admin' ||
                                      _isSuperuser)
                                  ? null
                                  : (v) => setState(() => _selectedUnitId = v),
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('تعذر تحميل الوحدات: $e'),
                        ),
                      ),
                      SizedBox(
                        width: 330,
                        child: TextFormField(
                          controller: _deptCtrl,
                          decoration: const InputDecoration(
                              labelText: 'القسم / الوصف',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        width: 330,
                        child: DropdownButtonFormField<String?>(
                          value: _selectedGovernorate,
                          decoration: const InputDecoration(
                              labelText: 'المحافظة',
                              border: OutlineInputBorder()),
                          items: [
                            const DropdownMenuItem<String?>(
                                value: null, child: Text('غير محددة')),
                            ...governorates.map((g) =>
                                DropdownMenuItem<String?>(
                                    value: g, child: Text(g))),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedGovernorate = v),
                        ),
                      ),
                      SizedBox(
                        width: 330,
                        child: TextFormField(
                          controller: _phoneCtrl,
                          decoration: const InputDecoration(
                              labelText: 'رقم الهاتف',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        width: 330,
                        child: TextFormField(
                          controller: _avatarCtrl,
                          decoration: const InputDecoration(
                              labelText: 'رابط الصورة الشخصية',
                              border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Text(
                      'مهم: الدور الإداري الأساسي يُحفظ في admin_users، أما النطاقات المتقدمة متعددة الوحدات والأنظمة فتُدار من نافذة الصلاحيات والنطاقات بعد الحفظ.',
                      style: TextStyle(height: 1.55),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    title: const Text('حساب نشط'),
                  ),
                  if (widget.isSuperuserActor)
                    SwitchListTile(
                      value: _isSuperuser,
                      onChanged: (_role == 'super_admin')
                          ? null
                          : (v) => setState(() {
                                _isSuperuser = v;
                                if (v) _selectedUnitId = null;
                              }),
                      title: const Text('منح صلاحية Superuser'),
                    ),
                  if (_requiresUnit && (_selectedUnitId ?? '').trim().isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('الحسابات غير المركزية يجب أن ترتبط بوحدة.',
                          style: TextStyle(color: Color(0xFFB22222))),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: _busy ? null : () => Navigator.of(context).pop(false),
              child: const Text('إلغاء')),
          ElevatedButton.icon(
            onPressed: _busy
                ? null
                : () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    if (_requiresUnit &&
                        (_selectedUnitId ?? '').trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('يجب اختيار وحدة للحسابات غير المركزية.')));
                      return;
                    }
                    setState(() => _busy = true);
                    try {
                      await ref
                          .read(adminUsersRepositoryProvider)
                          .updateAdminUser(
                            id: (widget.row['id'] ?? '').toString(),
                            email: _emailCtrl.text.trim(),
                            name: _nameCtrl.text.trim(),
                            username: _usernameCtrl.text.trim(),
                            role: _role,
                            unitId: _requiresUnit ? _selectedUnitId : null,
                            department: _deptCtrl.text.trim(),
                            governorate: _selectedGovernorate,
                            phone: _phoneCtrl.text.trim(),
                            avatarUrl: _avatarCtrl.text.trim(),
                            isActive: _isActive,
                            isSuperuser: _isSuperuser,
                          );
                      await _logAdminUsersAudit(
                        ref,
                        actionKey: 'update_admin_user',
                        title: 'إدارة المستخدمين - تحديث بيانات المستخدم',
                        targetUserId: (widget.row['id'] ?? '').toString(),
                        metadata: {
                          'email': _emailCtrl.text.trim(),
                          'name': _nameCtrl.text.trim(),
                          'username': _usernameCtrl.text.trim(),
                          'role': _role,
                          'unit_id': _requiresUnit ? _selectedUnitId : null,
                        },
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('تم حفظ تعديلات المستخدم')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())));
                      }
                    } finally {
                      if (mounted) setState(() => _busy = false);
                    }
                  },
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            label: const Text('حفظ التغييرات'),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w800)),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel(
      {required this.title, required this.children, required this.color});

  final String title;
  final List<Widget> children;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _AsyncInfoPanel extends StatelessWidget {
  const _AsyncInfoPanel(
      {required this.title,
      required this.asyncValue,
      required this.emptyText,
      required this.builder});

  final String title;
  final AsyncValue<List<Map<String, dynamic>>> asyncValue;
  final String emptyText;
  final Widget Function(List<Map<String, dynamic>> rows) builder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: asyncValue.when(
        data: (rows) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              Text(emptyText, style: const TextStyle(color: Color(0xFF6B7280)))
            else
              builder(rows),
          ],
        ),
        loading: () => const Center(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator())),
        error: (e, _) => Text('تعذر التحميل: $e'),
      ),
    );
  }
}

class _UserAccessDialog extends ConsumerWidget {
  final String userId;
  final String title;

  const _UserAccessDialog({
    required this.userId,
    required this.title,
  });

  static const _roleOptions = <String>['viewer', 'user', 'admin', 'superuser'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actorProfile = ref.watch(accessProfileProvider).valueOrNull;
    final isSelf = (actorProfile?.userId == userId);
    final systemsAsync = ref.watch(platformSystemsProvider);
    final permsCatalogAsync = ref.watch(platformPermissionsCatalogProvider);

    final rolesAsync = ref.watch(userSystemRolesProvider(userId));
    final permsAsync = ref.watch(userSystemPermissionsProvider(userId));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 980,
          height: 640,
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'إدارة الصلاحيات والنطاقات: $title',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: 'إغلاق',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab(text: 'الأدوار حسب الأنظمة'),
                    Tab(text: 'الصلاحيات حسب الأنظمة'),
                    Tab(text: 'النطاقات والوحدات'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _RolesTab(
                        userId: userId,
                        isSelf: isSelf,
                        systemsAsync: systemsAsync,
                        rolesAsync: rolesAsync,
                        roleOptions: _roleOptions,
                      ),
                      _PermissionsTab(
                        userId: userId,
                        isSelf: isSelf,
                        systemsAsync: systemsAsync,
                        permsCatalogAsync: permsCatalogAsync,
                        permsAsync: permsAsync,
                      ),
                      _ScopesTab(
                        userId: userId,
                        isSelf: isSelf,
                        systemsAsync: systemsAsync,
                        title: title,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RolesTab extends ConsumerWidget {
  final String userId;
  final bool isSelf;
  final AsyncValue<List<Map<String, dynamic>>> systemsAsync;
  final AsyncValue<List<Map<String, dynamic>>> rolesAsync;
  final List<String> roleOptions;

  const _RolesTab({
    required this.userId,
    required this.isSelf,
    required this.systemsAsync,
    required this.rolesAsync,
    required this.roleOptions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isSelf)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'تنبيه: أنت تعدّل صلاحيات حسابك الحالي. حذف دور/صلاحية قد يؤدي لفقدان الوصول للوحة التحكم.',
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () async {
                final systems = systemsAsync.valueOrNull ?? const [];
                await _showUpsertRoleDialog(
                  context: context,
                  ref: ref,
                  userId: userId,
                  systems: systems,
                  roleOptions: roleOptions,
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة/تعديل دور'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: systemsAsync.when(
              data: (systems) {
                final systemsMap = _buildSystemLabels(systems);

                return rolesAsync.when(
                  data: (rows) {
                    if (rows.isEmpty) {
                      return const Center(
                          child: Text('لا توجد أدوار لهذا المستخدم.'));
                    }

                    return ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final r = rows[i];
                        final systemKey = (r['system_key'] ?? '').toString();
                        final role = (r['role'] ?? '').toString();

                        final sysLabel = systemsMap[systemKey] ??
                            _systemLabelFromKey(systemKey);

                        return ListTile(
                          title: Text(sysLabel),
                          subtitle:
                              Text('الدور: $role  —  system_key: $systemKey'),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              IconButton(
                                tooltip: 'تعديل',
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  await _showUpsertRoleDialog(
                                    context: context,
                                    ref: ref,
                                    userId: userId,
                                    systems: systems,
                                    roleOptions: roleOptions,
                                    initialSystemKey: systemKey,
                                    initialRole: role,
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: 'حذف',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: AlertDialog(
                                        title: const Text('تأكيد الحذف'),
                                        content: Text(isSelf
                                            ? 'هل تريد حذف هذا الدور من حسابك؟ قد تفقد الصلاحيات.'
                                            : 'هل تريد حذف هذا الدور؟'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('إلغاء'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('حذف'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                  if (ok != true) return;
                                  await ref
                                      .read(rbacAdminRepositoryProvider)
                                      .deleteUserRole(
                                        userId: userId,
                                        systemKey: systemKey,
                                      );
                                  await _logAdminUsersAudit(
                                    ref,
                                    actionKey: 'delete_user_role',
                                    title: 'إدارة المستخدمين - حذف دور نظامي',
                                    targetUserId: userId,
                                    entityType: 'user_role',
                                    metadata: {'system_key': systemKey},
                                  );
                                  ref.invalidate(
                                      userSystemRolesProvider(userId));
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(e.toString())),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUpsertRoleDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String userId,
    required List<Map<String, dynamic>> systems,
    required List<String> roleOptions,
    String? initialSystemKey,
    String? initialRole,
  }) async {
    final sysLabels = _buildSystemLabels(systems);
    final systemOptions = _sortSystemKeys(sysLabels.keys);

    String systemKey = (initialSystemKey ?? '').trim();
    if (systemOptions.isEmpty) {
      systemKey = SystemKey.platformAdmin.name;
    } else if (systemKey.isEmpty || !systemOptions.contains(systemKey)) {
      systemKey = systemOptions.first;
    }
    final normalizedRoleOptions = {
      ...roleOptions,
      if ((initialRole ?? '').trim().isNotEmpty) initialRole!.trim()
    }.toList();
    String role = initialRole ?? normalizedRoleOptions.first;
    String roleLabel(String value) {
      switch (value.trim().toLowerCase()) {
        case 'superuser':
          return 'Power Admin / إشراف عال';
        case 'admin':
          return 'إدارة النظام ضمن النطاق';
        case 'user':
          return 'تشغيل';
        case 'viewer':
          return 'قراءة فقط (تجريبي)';
        default:
          return value;
      }
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تعيين دور'),
            content: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: systemKey,
                    decoration: const InputDecoration(
                        labelText: 'النظام', border: OutlineInputBorder()),
                    items: systemOptions
                        .map((k) => DropdownMenuItem(
                            value: k, child: Text(sysLabels[k] ?? k)))
                        .toList(),
                    onChanged: (v) => systemKey = v ?? systemKey,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(
                        labelText: 'الدور الإداري الأساسي',
                        border: OutlineInputBorder()),
                    items: normalizedRoleOptions
                        .map((r) => DropdownMenuItem(
                            value: r, child: Text(roleLabel(r))))
                        .toList(),
                    onChanged: (v) => role = v ?? role,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('إلغاء')),
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('حفظ')),
            ],
          ),
        );
      },
    );

    if (ok == true) {
      await ref.read(rbacAdminRepositoryProvider).upsertUserRole(
            userId: userId,
            systemKey: systemKey,
            role: role,
          );
      await _logAdminUsersAudit(
        ref,
        actionKey: 'upsert_user_role',
        title: 'إدارة المستخدمين - تعيين دور نظامي',
        targetUserId: userId,
        entityType: 'user_role',
        metadata: {'system_key': systemKey, 'role': role},
      );
      ref.invalidate(platformSystemsProvider);
      ref.invalidate(userSystemRolesProvider(userId));
    }
  }
}

class _PermissionsTab extends ConsumerWidget {
  final String userId;
  final bool isSelf;
  final AsyncValue<List<Map<String, dynamic>>> systemsAsync;
  final AsyncValue<List<Map<String, dynamic>>> permsCatalogAsync;
  final AsyncValue<List<Map<String, dynamic>>> permsAsync;

  const _PermissionsTab({
    required this.userId,
    required this.isSelf,
    required this.systemsAsync,
    required this.permsCatalogAsync,
    required this.permsAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isSelf)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'تنبيه: أنت تعدّل صلاحيات حسابك الحالي. حذف صلاحية قد يؤدي لفقدان الوصول للوحة التحكم.',
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () async {
                final systems = systemsAsync.valueOrNull ?? const [];
                final catalog = permsCatalogAsync.valueOrNull ?? const [];
                await _showAddPermissionDialog(
                  context: context,
                  ref: ref,
                  userId: userId,
                  systems: systems,
                  catalog: catalog,
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة صلاحية'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: systemsAsync.when(
              data: (systems) {
                final systemsMap = _buildSystemLabels(systems);

                return permsAsync.when(
                  data: (rows) {
                    if (rows.isEmpty) {
                      return const Center(
                          child: Text('لا توجد صلاحيات لهذا المستخدم.'));
                    }

                    return ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final r = rows[i];
                        final systemKey = (r['system_key'] ?? '').toString();
                        final permKey = (r['permission_key'] ?? '').toString();
                        final sysLabel = systemsMap[systemKey] ??
                            _systemLabelFromKey(systemKey);

                        return ListTile(
                          title: Text(sysLabel),
                          subtitle: Text(
                              'الصلاحية: $permKey  —  system_key: $systemKey'),
                          trailing: IconButton(
                            tooltip: 'حذف',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: AlertDialog(
                                    title: const Text('تأكيد الحذف'),
                                    content: Text(isSelf
                                        ? 'هل تريد حذف هذه الصلاحية من حسابك؟ قد تفقد الوصول.'
                                        : 'هل تريد حذف هذه الصلاحية؟'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('إلغاء'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('حذف'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              if (ok != true) return;
                              await ref
                                  .read(rbacAdminRepositoryProvider)
                                  .deleteUserPermission(
                                    userId: userId,
                                    systemKey: systemKey,
                                    permissionKey: permKey,
                                  );
                              await _logAdminUsersAudit(
                                ref,
                                actionKey: 'delete_user_permission',
                                title: 'إدارة المستخدمين - حذف صلاحية نظامية',
                                targetUserId: userId,
                                entityType: 'user_permission',
                                metadata: {
                                  'system_key': systemKey,
                                  'permission_key': permKey
                                },
                              );
                              ref.invalidate(
                                  userSystemPermissionsProvider(userId));
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(e.toString())),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPermissionDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String userId,
    required List<Map<String, dynamic>> systems,
    required List<Map<String, dynamic>> catalog,
  }) async {
    final sysLabels = _buildSystemLabels(systems);
    final systemOptions = _sortSystemKeys(sysLabels.keys);

    final permLabels = <String, String>{};
    for (final p in catalog) {
      final k = _extractPermissionKey(p);
      if (k.isEmpty) continue;
      final label = _extractLabel(p).trim();
      permLabels[k] = label.isNotEmpty ? label : k;
    }
    for (final item in Permission.values) {
      permLabels.putIfAbsent(item.name, () => item.name);
    }
    final permissionOptions = permLabels.keys.toList()..sort();

    String systemKey = systemOptions.isNotEmpty
        ? systemOptions.first
        : SystemKey.platformAdmin.name;
    String permissionKey = permissionOptions.first;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('إضافة صلاحية'),
            content: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: systemKey,
                    decoration: const InputDecoration(
                        labelText: 'النظام', border: OutlineInputBorder()),
                    items: systemOptions
                        .map((k) => DropdownMenuItem(
                            value: k, child: Text(sysLabels[k] ?? k)))
                        .toList(),
                    onChanged: (v) => systemKey = v ?? systemKey,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: permissionKey,
                    decoration: const InputDecoration(
                        labelText: 'الصلاحية', border: OutlineInputBorder()),
                    items: permissionOptions
                        .map((k) => DropdownMenuItem(
                            value: k, child: Text(permLabels[k] ?? k)))
                        .toList(),
                    onChanged: (v) => permissionKey = v ?? permissionKey,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('إلغاء')),
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('إضافة')),
            ],
          ),
        );
      },
    );

    if (ok == true) {
      await ref.read(rbacAdminRepositoryProvider).upsertUserPermission(
            userId: userId,
            systemKey: systemKey,
            permissionKey: permissionKey,
          );
      await _logAdminUsersAudit(
        ref,
        actionKey: 'upsert_user_permission',
        title: 'إدارة المستخدمين - إضافة صلاحية نظامية',
        targetUserId: userId,
        entityType: 'user_permission',
        metadata: {'system_key': systemKey, 'permission_key': permissionKey},
      );
      ref.invalidate(platformSystemsProvider);
      ref.invalidate(userSystemPermissionsProvider(userId));
    }
  }
}

class _ScopesTab extends ConsumerWidget {
  const _ScopesTab({
    required this.userId,
    required this.isSelf,
    required this.systemsAsync,
    required this.title,
  });

  final String userId;
  final bool isSelf;
  final AsyncValue<List<Map<String, dynamic>>> systemsAsync;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scopesAsync = ref.watch(userScopeAssignmentsProvider(userId));
    final unitsAsync = ref.watch(adminUsersActiveUnitsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Text(
              'هذه المساحة تغلق نموذج النطاقات متعددة الوحدات والأنظمة، خصوصًا لـ Power Admin والوكيل القانوني المفوض. إذا لم تُفعّل الجداول السيادية بعد، فستظهر القائمة فارغة ولن تُحفظ التعديلات.',
              style: TextStyle(height: 1.55),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () async {
                final systems = systemsAsync.valueOrNull ?? const [];
                final units = unitsAsync.valueOrNull ?? const [];
                await _showUpsertScopeDialog(
                  context: context,
                  ref: ref,
                  userId: userId,
                  systems: systems,
                  units: units,
                );
              },
              icon: const Icon(Icons.add_link_outlined),
              label: const Text('إضافة نطاق/تكليف'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: scopesAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                        'لا توجد نطاقات إضافية محفوظة لهذا المستخدم حتى الآن.'),
                  );
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final scopeLabel =
                        _operationalScopeRoleLabel(item.scopeRoleKey);
                    final systemLabel = (item.systemKey ?? '').trim().isEmpty
                        ? 'غير مرتبط بنظام محدد'
                        : _systemLabelFromKey(item.systemKey!);
                    final unitsLabel = item.unitsSummaryAr.isNotEmpty
                        ? item.unitsSummaryAr
                        : ((item.unitId ?? '').trim().isNotEmpty
                            ? 'وحدة أساسية مرتبطة'
                            : 'بدون وحدات إضافية');
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _DetailChip(
                                        label: scopeLabel,
                                        color: _roleAccent(item.scopeRoleKey)),
                                    _DetailChip(
                                        label: systemLabel,
                                        color: const Color(0xFF0F4C81)),
                                    _DetailChip(
                                        label:
                                            item.isActive ? 'نشط' : 'غير نشط',
                                        color: item.isActive
                                            ? const Color(0xFF1D7A46)
                                            : const Color(0xFFB22222)),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'تعديل',
                                onPressed: () async {
                                  final systems =
                                      systemsAsync.valueOrNull ?? const [];
                                  final units =
                                      unitsAsync.valueOrNull ?? const [];
                                  await _showUpsertScopeDialog(
                                    context: context,
                                    ref: ref,
                                    userId: userId,
                                    systems: systems,
                                    units: units,
                                    initial: item,
                                  );
                                },
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'حذف',
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: AlertDialog(
                                        title: const Text('حذف التكليف'),
                                        content: Text(isSelf
                                            ? 'سيتم حذف هذا التكليف من حسابك الحالي. هل تريد المتابعة؟'
                                            : 'هل تريد حذف هذا التكليف/النطاق؟'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('إلغاء')),
                                          ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('حذف')),
                                        ],
                                      ),
                                    ),
                                  );
                                  if (ok != true) return;
                                  await ref
                                      .read(
                                          userScopeAssignmentsRepositoryProvider)
                                      .deleteAssignment(item.id, systemKey: item.systemKey);
                                  await _logAdminUsersAudit(
                                    ref,
                                    actionKey: 'delete_scope_assignment',
                                    title: 'إدارة المستخدمين - حذف نطاق/تكليف',
                                    targetUserId: userId,
                                    entityType: 'user_scope_assignment',
                                    metadata: {
                                      'scope_role_key': item.scopeRoleKey,
                                      'system_key': item.systemKey
                                    },
                                  );
                                  ref.invalidate(
                                      userScopeAssignmentsProvider(userId));
                                  ref.invalidate(adminUsersListProvider);
                                },
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(label: 'وصف النطاق', value: systemLabel),
                          _InfoRow(label: 'الوحدات الموكلة', value: unitsLabel),
                          if ((item.notes ?? '').trim().isNotEmpty)
                            _InfoRow(
                                label: 'ملاحظات', value: item.notes!.trim()),
                          _InfoRow(
                              label: 'البداية',
                              value: _formatDateTime(item.startsAt)),
                          _InfoRow(
                              label: 'الانتهاء',
                              value: _formatDateTime(item.expiresAt)),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorBox(
                error: 'تعذر تحميل النطاقات: $e',
                onRetry: () =>
                    ref.invalidate(userScopeAssignmentsProvider(userId)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUpsertScopeDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String userId,
    required List<Map<String, dynamic>> systems,
    required List<Map<String, dynamic>> units,
    UserScopeAssignment? initial,
  }) async {
    final systemLabels = _buildSystemLabels(systems);
    final systemOptions = _sortSystemKeys(systemLabels.keys);
    String scopeRoleKey = (initial?.scopeRoleKey ?? 'employee').trim();
    String? systemKey = (initial?.systemKey ?? '').trim().isEmpty
        ? null
        : initial!.systemKey!.trim();
    String? primaryUnitId =
        (initial?.unitId ?? '').trim().isEmpty ? null : initial!.unitId!.trim();
    final selectedUnits = <String>{
      ...(initial?.linkedUnitIds ?? const <String>[])
    };
    final notesController = TextEditingController(text: initial?.notes ?? '');
    bool isActive = initial?.isActive ?? true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            final requiresSystem = _scopeRoleRequiresSystem(scopeRoleKey);
            final requiresUnit = _scopeRoleRequiresUnit(scopeRoleKey);
            final supportsMultiUnit = _scopeRoleSupportsMultiUnit(scopeRoleKey);
            final filteredSystemOptions = _isSiteUnitScopeRole(scopeRoleKey)
                ? systemOptions.where((key) => key == SystemKey.site.name).toList()
                : supportsMultiUnit
                    ? systemOptions
                        .where((key) => key == SystemKey.cases.name)
                        .toList()
                    : systemOptions;
            if (_isSiteUnitScopeRole(scopeRoleKey)) {
              systemKey = SystemKey.site.name;
            }
            if (requiresSystem &&
                (systemKey == null || systemKey!.isEmpty) &&
                filteredSystemOptions.isNotEmpty) {
              systemKey = filteredSystemOptions.first;
            }
            if (!requiresSystem) {
              systemKey = null;
            }
            if (!requiresUnit && !supportsMultiUnit) {
              primaryUnitId = null;
            }
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text(
                    initial == null ? 'إضافة نطاق/تكليف' : 'تعديل نطاق/تكليف'),
                content: SizedBox(
                  width: 680,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: scopeRoleKey,
                          decoration: const InputDecoration(
                              labelText: 'النموذج التشغيلي',
                              border: OutlineInputBorder()),
                          items: _operationalScopeRoleOptions
                              .where((item) =>
                                  item['value'] != 'viewer_experimental')
                              .map((item) => DropdownMenuItem<String>(
                                  value: item['value'],
                                  child: Text(item['label']!)))
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              scopeRoleKey = value;
                              if (!_scopeRoleRequiresSystem(scopeRoleKey))
                                systemKey = null;
                              if (!_scopeRoleRequiresUnit(scopeRoleKey) &&
                                  !_scopeRoleSupportsMultiUnit(scopeRoleKey)) {
                                primaryUnitId = null;
                              }
                              if (!_scopeRoleSupportsMultiUnit(scopeRoleKey))
                                selectedUnits.clear();
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        if (requiresSystem)
                          DropdownButtonFormField<String>(
                            value: systemKey,
                            decoration: const InputDecoration(
                                labelText: 'النظام',
                                border: OutlineInputBorder()),
                            items: filteredSystemOptions
                                .map((key) => DropdownMenuItem<String>(
                                    value: key,
                                    child: Text(systemLabels[key] ?? key)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => systemKey = value),
                          ),
                        if (requiresSystem) const SizedBox(height: 12),
                        if (requiresUnit)
                          DropdownButtonFormField<String?>(
                            value: primaryUnitId,
                            decoration: const InputDecoration(
                                labelText: 'الوحدة الأساسية',
                                border: OutlineInputBorder()),
                            items: units
                                .map((u) => DropdownMenuItem<String?>(
                                      value: (u['id'] ?? '').toString(),
                                      child: Text(
                                          ((u['name_ar'] ?? u['slug']) ?? '')
                                              .toString()),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => primaryUnitId = value),
                          ),
                        if (requiresUnit) const SizedBox(height: 12),
                        if (supportsMultiUnit) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('الوحدات الموكلة',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: units.map((u) {
                                    final id = (u['id'] ?? '').toString();
                                    final label =
                                        ((u['name_ar'] ?? u['slug']) ?? '')
                                            .toString();
                                    final selected = selectedUnits.contains(id);
                                    return FilterChip(
                                      label: Text(label),
                                      selected: selected,
                                      onSelected: (value) => setState(() {
                                        if (value) {
                                          selectedUnits.add(id);
                                        } else {
                                          selectedUnits.remove(id);
                                        }
                                      }),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                              labelText: 'ملاحظات',
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          value: isActive,
                          onChanged: (value) =>
                              setState(() => isActive = value),
                          title: const Text('تكليف/نطاق نشط'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('إلغاء')),
                  ElevatedButton(
                    onPressed: () {
                      if (_scopeRoleRequiresSystem(scopeRoleKey) &&
                          (systemKey == null || systemKey!.trim().isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('يجب اختيار نظام لهذا النطاق.')));
                        return;
                      }
                      if (_scopeRoleRequiresUnit(scopeRoleKey) &&
                          (primaryUnitId == null ||
                              primaryUnitId!.trim().isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'يجب اختيار وحدة أساسية لهذا النطاق.')));
                        return;
                      }
                      if (_scopeRoleSupportsMultiUnit(scopeRoleKey) &&
                          selectedUnits.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'يجب تحديد وحدة واحدة على الأقل للوحدات الموكلة.')));
                        return;
                      }
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('حفظ'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (ok == true) {
      await ref.read(userScopeAssignmentsRepositoryProvider).upsertAssignment(
            id: initial?.id,
            userId: userId,
            scopeRoleKey: scopeRoleKey,
            systemKey: systemKey,
            unitId: primaryUnitId,
            linkedUnitIds: selectedUnits.toList(),
            notes: notesController.text.trim(),
            isActive: isActive,
          );
      await _logAdminUsersAudit(
        ref,
        actionKey: initial == null
            ? 'create_scope_assignment'
            : 'update_scope_assignment',
        title: initial == null
            ? 'إدارة المستخدمين - إضافة نطاق/تكليف'
            : 'إدارة المستخدمين - تحديث نطاق/تكليف',
        targetUserId: userId,
        entityType: 'user_scope_assignment',
        metadata: {
          'scope_role_key': scopeRoleKey,
          'system_key': systemKey,
          'unit_id': primaryUnitId,
          'linked_unit_ids': selectedUnits.toList(),
        },
      );
      ref.invalidate(userScopeAssignmentsProvider(userId));
      ref.invalidate(adminUsersListProvider);
    }
    notesController.dispose();
  }
}

class _CreateAdminUserDialog extends ConsumerStatefulWidget {
  final bool isSuperuserActor;
  final AdminUser? actorUser;

  const _CreateAdminUserDialog(
      {required this.isSuperuserActor, required this.actorUser});

  @override
  ConsumerState<_CreateAdminUserDialog> createState() =>
      _CreateAdminUserDialogState();
}

class _CreateAdminUserDialogState
    extends ConsumerState<_CreateAdminUserDialog> {
  final _formKey = GlobalKey<FormState>();

  final _uidCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();

  String _role = 'admin';
  bool _isActive = true;
  bool _isSuperuser = false;
  bool _busy = false;
  String? _selectedUnitId;

  @override
  void dispose() {
    _uidCtrl.dispose();
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }

  List<Map<String, String>> _allowedRoles() {
    return _allowedPersistedRolesForActor(
        widget.actorUser, widget.isSuperuserActor);
  }

  bool get _requiresUnit => !_isSuperuser;

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(adminUsersActiveUnitsProvider);
    final roleOptions = _allowedRoles();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إضافة مستخدم (admin_users)'),
        content: SizedBox(
          width: 620,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _uidCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Auth UID (UUID)',
                      hintText: 'انسخه من Auth → Users',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'مطلوب';
                      if (!_looksLikeUuid(s)) return 'صيغة UUID غير صحيحة';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم التشغيلي',
                      hintText: 'مثل bthadmin أو bthusr1',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'مطلوب';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'مطلوب';
                      if (!s.contains('@')) return 'بريد غير صحيح';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'الاسم',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'مطلوب';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _role,
                    decoration: const InputDecoration(
                      labelText: 'الدور الإداري الأساسي',
                      border: OutlineInputBorder(),
                    ),
                    items: roleOptions
                        .map((r) => DropdownMenuItem<String>(
                            value: r['value'], child: Text(r['label']!)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _role = v;
                        if (_role == 'super_admin') {
                          _isSuperuser = true;
                          _selectedUnitId = null;
                        } else if (_isSuperuser && !widget.isSuperuserActor) {
                          _isSuperuser = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  unitsAsync.when(
                    data: (units) {
                      final filteredUnits = _filterUnitsForActor(
                        units
                            .map((row) => {
                                  'id': (row['id'] ?? '').toString(),
                                  'label': ((row['name_ar'] ??
                                          row['slug'] ??
                                          row['name_en'] ??
                                          '')
                                      .toString()),
                                })
                            .toList(),
                        widget.actorUser,
                        null,
                      );
                      return DropdownButtonFormField<String?>(
                        value: _selectedUnitId,
                        decoration: const InputDecoration(
                          labelText: 'الوحدة',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                              value: null, child: Text('بدون وحدة / مركزي')),
                          ...filteredUnits.map((u) => DropdownMenuItem<String?>(
                                value: (u['id'] ?? '').toString(),
                                child: Text((u['label'] ?? '').toString()),
                              )),
                        ],
                        onChanged: (_role == 'super_admin' || _isSuperuser)
                            ? null
                            : (v) => setState(() => _selectedUnitId = v),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('تعذر تحميل الوحدات: $e'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _deptCtrl,
                    decoration: const InputDecoration(
                      labelText: 'القسم / الوصف (اختياري)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    title: const Text('نشط'),
                  ),
                  if (widget.isSuperuserActor) ...[
                    SwitchListTile(
                      value: _isSuperuser,
                      onChanged: _role == 'super_admin'
                          ? null
                          : (v) => setState(() {
                                _isSuperuser = v;
                                if (v) _selectedUnitId = null;
                              }),
                      title: const Text('Superuser'),
                    ),
                  ],
                  if (_requiresUnit && (_selectedUnitId ?? '').trim().isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'الحسابات غير المركزية يجب أن ترتبط بوحدة.',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFFB22222)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton.icon(
            onPressed: _busy
                ? null
                : () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    if (_requiresUnit &&
                        (_selectedUnitId ?? '').trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('يجب اختيار وحدة للحسابات غير المركزية.')),
                      );
                      return;
                    }
                    setState(() => _busy = true);
                    try {
                      final uid = _uidCtrl.text.trim();
                      final email = _emailCtrl.text.trim();
                      final name = _nameCtrl.text.trim();
                      final username = _usernameCtrl.text.trim();
                      final dept = _deptCtrl.text.trim();
                      final isSuper = (_role == 'super_admin') ||
                          (widget.isSuperuserActor && _isSuperuser);
                      final persistedRole = _role;

                      await ref
                          .read(adminUsersRepositoryProvider)
                          .createAdminUser(
                            id: uid,
                            email: email,
                            name: name,
                            username: username,
                            unitId: _requiresUnit ? _selectedUnitId : null,
                            role: persistedRole,
                            department: dept.isEmpty ? null : dept,
                            isActive: _isActive,
                            isSuperuser: isSuper,
                          );
                      await _logAdminUsersAudit(
                        ref,
                        actionKey: 'create_admin_user',
                        title: 'إدارة المستخدمين - إنشاء مستخدم إداري',
                        targetUserId: uid,
                        metadata: {
                          'email': email,
                          'name': name,
                          'username': username,
                          'role': persistedRole,
                          'department': dept,
                          'unit_id': _requiresUnit ? _selectedUnitId : null,
                          'is_active': _isActive,
                          'is_superuser': isSuper,
                        },
                      );

                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'تمت إضافة المستخدم إلى admin_users. يمكن إغلاق النطاقات المتقدمة من تبويب الصلاحيات والنطاقات بعد الحفظ.')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _busy = false);
                    }
                  },
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
