import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../../../providers/rbac_admin_provider.dart';

import '../../../../../providers/admin_users_provider.dart';
import '../../../../../../core/access/access_provider.dart';
import '../../../../../../core/enums/enums.dart';

bool _looksLikeUuid(String v) {
  final s = v.trim();
  final r = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
  return r.hasMatch(s);
}

bool _isKnownSystemKey(String v) {
  return SystemKey.values.any((e) => e.name == v);
}

bool _isKnownPermissionKey(String v) {
  return Permission.values.any((e) => e.name == v);
}

String _extractSystemKey(Map<String, dynamic> row) {
  // لا نعتمد على id لأن غالبًا UUID ولا يطابق enum system_key.
  final candidates = [row['system_key'], row['key'], row['code'], row['slug']]
      .where((e) => e != null)
      .map((e) => e.toString().trim())
      .where((s) => s.isNotEmpty)
      .toList();

  for (final c in candidates) {
    if (_isKnownSystemKey(c)) return c;
  }
  // fallback: لو لم نجد مفتاح مطابق للـ enum
  return candidates.isNotEmpty ? candidates.first : '';
}

String _extractPermissionKey(Map<String, dynamic> row) {
  final candidates = [row['permission_key'], row['key'], row['code'], row['slug']]
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
  return (row['name_ar'] ?? row['name_en'] ?? row['title_ar'] ?? row['title_en'] ?? '').toString();
}


class UsersManagementScreen extends ConsumerWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(accessProfileProvider);
    final usersAsync = ref.watch(adminUsersListProvider);
    final activeFilter = ref.watch(adminUsersActiveFilterProvider);

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
              // Fail-closed
              final canManage = (profile?.can(SystemKey.platformAdmin, Permission.manageUsers) ?? false);

              if (!canManage) {
                return const _ForbiddenInline();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SearchBar(
                    onChanged: (v) => ref.read(adminUsersSearchProvider.notifier).state = v,
                    onRefresh: () => ref.invalidate(adminUsersListProvider),
                    activeFilter: activeFilter,
                    onFilterChanged: (f) {
                      ref.read(adminUsersActiveFilterProvider.notifier).state = f;
                      ref.invalidate(adminUsersListProvider);
                    },
                    onCreate: () async {
                      final profile = profileAsync.value;
                      await showDialog(
                        context: context,
                        builder: (_) => _CreateAdminUserDialog(
                          isSuperuserActor: profile?.isSuperuser ?? false,
                        ),
                      );
                      ref.invalidate(adminUsersListProvider);
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: usersAsync.when(
                      data: (rows) => _UsersTable(
                        rows: rows,
                        actorUserId: profile?.userId ?? '',
                        actorIsSuperuser: profile?.isSuperuser ?? false,
                        onToggleActive: (id, value) async {
                          await ref.read(adminUsersRepositoryProvider).setActive(userId: id, isActive: value);
                          ref.invalidate(adminUsersListProvider);
                        },
                        onToggleSuperuser: (id, value) async {
                          await ref.read(adminUsersRepositoryProvider).setSuperuser(userId: id, isSuperuser: value);
                          ref.invalidate(adminUsersListProvider);
                        },
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => _ErrorBox(error: e.toString(), onRetry: () => ref.invalidate(adminUsersListProvider)),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorBox(error: e.toString(), onRetry: () => ref.invalidate(accessProfileProvider)),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final void Function(String) onChanged;
  final VoidCallback onRefresh;
  final VoidCallback onCreate;
  final AdminUsersActiveFilter activeFilter;
  final void Function(AdminUsersActiveFilter) onFilterChanged;

  const _SearchBar({
    required this.onChanged,
    required this.onRefresh,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onCreate,
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
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 360,
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'بحث (الاسم أو البريد)',
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('الكل'),
              selected: widget.activeFilter == AdminUsersActiveFilter.all,
              onSelected: (_) => widget.onFilterChanged(AdminUsersActiveFilter.all),
            ),
            ChoiceChip(
              label: const Text('نشط'),
              selected: widget.activeFilter == AdminUsersActiveFilter.active,
              onSelected: (_) => widget.onFilterChanged(AdminUsersActiveFilter.active),
            ),
            ChoiceChip(
              label: const Text('غير نشط'),
              selected: widget.activeFilter == AdminUsersActiveFilter.inactive,
              onSelected: (_) => widget.onFilterChanged(AdminUsersActiveFilter.inactive),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: widget.onCreate,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('إضافة مستخدم'),
        ),
      ],
    );
  }
}

class _UsersTable extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  final String actorUserId;
  final bool actorIsSuperuser;
  final Future<void> Function(String userId, bool value) onToggleActive;
  final Future<void> Function(String userId, bool value) onToggleSuperuser;

  const _UsersTable({
    required this.rows,
    required this.actorUserId,
    required this.actorIsSuperuser,
    required this.onToggleActive,
    required this.onToggleSuperuser,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(child: Text('لا يوجد مستخدمون مطابقون.'));
    }

    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('الاسم')),
          DataColumn(label: Text('البريد')),
          DataColumn(label: Text('الدور')),
          DataColumn(label: Text('نشط')),
          DataColumn(label: Text('سوبر')),
          DataColumn(label: Text('إجراء')),
        ],
        rows: rows.map((r) {
          final id = (r['id'] ?? '').toString();
          final name = (r['name'] ?? '').toString();
          final email = (r['email'] ?? '').toString();
          final role = (r['role'] ?? '').toString();
          final isActive = (r['is_active'] == true);
          final isSuper = (r['is_superuser'] == true);
          final isSelf = actorUserId.isNotEmpty && id == actorUserId;

          return DataRow(cells: [
            DataCell(Text(name)),
            DataCell(Text(email)),
            DataCell(Text(role)),
            DataCell(
              Tooltip(
                message: isSelf ? 'لا يمكن تعديل حسابك من هنا' : '',
                child: Switch(
                  value: isActive,
                  onChanged: isSelf
                      ? null
                      : (v) async {
                          await onToggleActive(id, v);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(v ? 'تم تفعيل المستخدم' : 'تم تعطيل المستخدم')),
                            );
                          }
                        },
                ),
              ),
            ),
            DataCell(
              Tooltip(
                message: !actorIsSuperuser
                    ? 'تعيين Superuser متاح فقط للسوبر يوزر'
                    : (isSelf ? 'لا يمكن تعديل حسابك من هنا' : ''),
                child: Switch(
                  value: isSuper,
                  onChanged: (!actorIsSuperuser || isSelf)
                      ? null
                      : (v) async {
                          await onToggleSuperuser(id, v);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(v ? 'تم جعل المستخدم سوبر' : 'تم إلغاء السوبر')),
                            );
                          }
                        },
                ),
              ),
            ),
            DataCell(
              Row(
                children: [
                  IconButton(
                    tooltip: 'إدارة الأدوار/الصلاحيات',
                    icon: const Icon(Icons.manage_accounts),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => _UserAccessDialog(
                          userId: id,
                          title: name.isNotEmpty ? name : email,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'نسخ UUID',
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: id));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم نسخ المعرّف')),
                        );
                      }
                    },
                  ),
                  IconButton(
                    tooltip: 'نسخ البريد',
                    icon: const Icon(Icons.alternate_email),
                    onPressed: email.trim().isEmpty
                        ? null
                        : () async {
                            await Clipboard.setData(ClipboardData(text: email.trim()));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم نسخ البريد')),
                              );
                            }
                          },
                  ),
                ],
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }
}

class _ForbiddenInline extends StatelessWidget {
  const _ForbiddenInline();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'غير مصرح لك بإدارة المستخدمين.\nتحتاج صلاحية manageUsers على platformAdmin.',
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
class _UserAccessDialog extends ConsumerWidget {
  final String userId;
  final String title;

  const _UserAccessDialog({
    required this.userId,
    required this.title,
  });

  static const _roleOptions = <String>['viewer', 'user', 'admin'];

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
            length: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'إدارة الصلاحيات: $title',
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
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Roles tab
                      _RolesTab(
                        userId: userId,
                        isSelf: isSelf,
                        systemsAsync: systemsAsync,
                        rolesAsync: rolesAsync,
                        roleOptions: _roleOptions,
                      ),
                      // Permissions tab
                      _PermissionsTab(
                        userId: userId,
                        isSelf: isSelf,
                        systemsAsync: systemsAsync,
                        permsCatalogAsync: permsCatalogAsync,
                        permsAsync: permsAsync,
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
                final systemsMap = <String, String>{};
                for (final s in systems) {
                  final k = _extractSystemKey(s);
                  if (k.isEmpty) continue;
                  final label = _extractLabel(s);
                  systemsMap[k] = label.isNotEmpty ? label : k;
                }

                return rolesAsync.when(
                  data: (rows) {
                    if (rows.isEmpty) {
                      return const Center(child: Text('لا توجد أدوار لهذا المستخدم.'));
                    }

                    return ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final r = rows[i];
                        final systemKey = (r['system_key'] ?? '').toString();
                        final role = (r['role'] ?? '').toString();

                        final sysLabel = systemsMap[systemKey] ?? systemKey;

                        return ListTile(
                          title: Text(sysLabel),
                          subtitle: Text('الدور: $role  —  system_key: $systemKey'),
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
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                                          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
                                        ],
                                      ),
                                    ),
                                  );
                                  if (ok != true) return;
                                  await ref.read(rbacAdminRepositoryProvider).deleteUserRole(
                                    userId: userId,
                                    systemKey: systemKey,
                                  );
                                  ref.invalidate(userSystemRolesProvider(userId));
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
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
    final sysLabels = <String, String>{};
    for (final s in systems) {
      final k = _extractSystemKey(s);
      if (k.isEmpty) continue;
      final label = _extractLabel(s);
      sysLabels[k] = label.isNotEmpty ? label : k;
    }

    final systemOptions = sysLabels.keys.isNotEmpty
        ? (sysLabels.keys.toList()..sort())
        : (SystemKey.values.map((e) => e.name).toList()..sort());

    String systemKey = (initialSystemKey ?? '').trim();
    if (systemKey.isEmpty || !systemOptions.contains(systemKey)) {
      systemKey = systemOptions.first;
    }
    String role = initialRole ?? roleOptions.first;

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
                    decoration: const InputDecoration(labelText: 'النظام', border: OutlineInputBorder()),
                    items: systemOptions
                        .map((k) => DropdownMenuItem(value: k, child: Text(sysLabels[k] ?? k)))
                        .toList(),
                    onChanged: (v) => systemKey = v ?? systemKey,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: 'الدور', border: OutlineInputBorder()),
                    items: roleOptions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) => role = v ?? role,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('إلغاء')),
              ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('حفظ')),
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
                final systemsMap = <String, String>{};
                for (final s in systems) {
                  final k = _extractSystemKey(s);
                  if (k.isEmpty) continue;
                  final label = _extractLabel(s);
                  systemsMap[k] = label.isNotEmpty ? label : k;
                }

                return permsAsync.when(
                  data: (rows) {
                    if (rows.isEmpty) {
                      return const Center(child: Text('لا توجد صلاحيات لهذا المستخدم.'));
                    }

                    return ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final r = rows[i];
                        final systemKey = (r['system_key'] ?? '').toString();
                        final permKey = (r['permission_key'] ?? '').toString();
                        final sysLabel = systemsMap[systemKey] ?? systemKey;

                        return ListTile(
                          title: Text(sysLabel),
                          subtitle: Text('الصلاحية: $permKey  —  system_key: $systemKey'),
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
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('إلغاء')),
                                      ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('حذف')),
                                    ],
                                  ),
                                ),
                              );
                              if (ok != true) return;
                              await ref.read(rbacAdminRepositoryProvider).deleteUserPermission(
                                userId: userId,
                                systemKey: systemKey,
                                permissionKey: permKey,
                              );
                              ref.invalidate(userSystemPermissionsProvider(userId));
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
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
    final sysLabels = <String, String>{};
    for (final s in systems) {
      final k = _extractSystemKey(s);
      if (k.isEmpty) continue;
      final label = _extractLabel(s);
      sysLabels[k] = label.isNotEmpty ? label : k;
    }

    final systemOptions = sysLabels.keys.isNotEmpty
        ? (sysLabels.keys.toList()..sort())
        : (SystemKey.values.map((e) => e.name).toList()..sort());

    final permLabels = <String, String>{};
    for (final p in catalog) {
      final k = _extractPermissionKey(p);
      if (k.isEmpty) continue;
      final label = _extractLabel(p);
      permLabels[k] = label.isNotEmpty ? label : k;
    }
    final permissionOptions = permLabels.keys.isNotEmpty
        ? (permLabels.keys.toList()..sort())
        : (Permission.values.map((e) => e.name).toList()..sort());

    String systemKey = systemOptions.first;
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
                    decoration: const InputDecoration(labelText: 'النظام', border: OutlineInputBorder()),
                    items: systemOptions
                        .map((k) => DropdownMenuItem(value: k, child: Text(sysLabels[k] ?? k)))
                        .toList(),
                    onChanged: (v) => systemKey = v ?? systemKey,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: permissionKey,
                    decoration: const InputDecoration(labelText: 'الصلاحية', border: OutlineInputBorder()),
                    items: permissionOptions
                        .map((k) => DropdownMenuItem(value: k, child: Text(permLabels[k] ?? k)))
                        .toList(),
                    onChanged: (v) => permissionKey = v ?? permissionKey,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('إلغاء')),
              ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('إضافة')),
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
      ref.invalidate(userSystemPermissionsProvider(userId));
    }
  }
}

class _CreateAdminUserDialog extends ConsumerStatefulWidget {
  final bool isSuperuserActor;

  const _CreateAdminUserDialog({required this.isSuperuserActor});

  @override
  ConsumerState<_CreateAdminUserDialog> createState() => _CreateAdminUserDialogState();
}

class _CreateAdminUserDialogState extends ConsumerState<_CreateAdminUserDialog> {
  final _formKey = GlobalKey<FormState>();

  final _uidCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();

  UserRole _role = UserRole.user;
  bool _isActive = true;
  bool _isSuperuser = false;
  bool _busy = false;

  @override
  void dispose() {
    _uidCtrl.dispose();
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }

  bool _looksLikeUuid(String v) {
    final s = v.trim();
    final r = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return r.hasMatch(s);
  }

  @override
  Widget build(BuildContext context) {
    final roleOptions = widget.isSuperuserActor
        ? UserRole.values
        : UserRole.values.where((r) => r != UserRole.superuser).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إضافة مستخدم (admin_users)'),
        content: SizedBox(
          width: 560,
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
                  DropdownButtonFormField<UserRole>(
                    value: _role,
                    decoration: const InputDecoration(
                      labelText: 'الدور',
                      border: OutlineInputBorder(),
                    ),
                    items: roleOptions.map((r) {
                      return DropdownMenuItem(value: r, child: Text(r.name));
                    }).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _role = v;
                        if (_role == UserRole.superuser) {
                          _isSuperuser = true;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _deptCtrl,
                    decoration: const InputDecoration(
                      labelText: 'القسم (اختياري)',
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
                      onChanged: (v) => setState(() => _isSuperuser = v),
                      title: const Text('Superuser'),
                    ),
                  ],
                  if (!widget.isSuperuserActor && _role == UserRole.superuser)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'ملاحظة: تعيين superuser يحتاج أن تكون أنت superuser.',
                        style: TextStyle(fontSize: 12),
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
                    if (!widget.isSuperuserActor && _role == UserRole.superuser) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('لا يمكنك تعيين دور superuser.')), 
                      );
                      return;
                    }
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    setState(() => _busy = true);
                    try {
                      final uid = _uidCtrl.text.trim();
                      final email = _emailCtrl.text.trim();
                      final name = _nameCtrl.text.trim();
                      final dept = _deptCtrl.text.trim();

                      // Fail-closed: non-superuser actor cannot grant superuser.
                      final isSuper = widget.isSuperuserActor ? _isSuperuser : false;

                      await ref.read(adminUsersRepositoryProvider).createAdminUser(
                            id: uid,
                            email: email,
                            name: name,
                            role: _role.name,
                            department: dept.isEmpty ? null : dept,
                            isActive: _isActive,
                            isSuperuser: isSuper,
                          );

                      if (mounted) {
                        Navigator.of(context).pop(true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تمت إضافة المستخدم إلى admin_users')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _busy = false);
                    }
                  },
            icon: _busy
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
