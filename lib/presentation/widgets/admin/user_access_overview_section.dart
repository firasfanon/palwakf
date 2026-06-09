import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/access/user_dashboard_contract.dart';
import '../../../core/enums/permission.dart';

class UserAccessOverviewSection extends StatelessWidget {
  final UserDashboardContract contract;

  const UserAccessOverviewSection({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 18),
            _buildStats(),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1050;
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _buildSystemsSection(context)),
                      const SizedBox(width: 16),
                      Expanded(flex: 4, child: _buildSideColumn(context)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildSideColumn(context),
                    const SizedBox(height: 16),
                    _buildSystemsSection(context),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final parts = contract.displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .take(2)
        .toList();
    final initials = parts.isEmpty
        ? 'PW'
        : parts.map((e) => e.substring(0, 1)).join();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C81), Color(0xFF154B79)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.16),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مساحة عملي الديناميكية',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${contract.displayName}${contract.username.isNotEmpty ? '  •  @${contract.username}' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'هذه اللوحة تتغير تلقائيًا بحسب دورك المؤسسي ونطاقك الإداري والوحدة التابعة لك والأنظمة والصلاحيات الممنوحة لك داخل PalWakf.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.90),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderChip(label: contract.policyRoleLabelAr),
              _HeaderChip(label: contract.scopeLabel),
              _HeaderChip(
                label: contract.isActive ? 'الحساب نشط' : 'الحساب غير نشط',
              ),
              ...contract.governanceBadges
                  .take(3)
                  .map((badge) => _HeaderChip(label: badge)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatTile(
          title: 'الأنظمة المتاحة',
          value: contract.visibleSystemsCount.toString(),
          icon: Icons.widgets_outlined,
        ),
        _StatTile(
          title: 'الأنظمة القابلة للإدارة/التشغيل',
          value: contract.writableSystemsCount.toString(),
          icon: Icons.tune_outlined,
          accent: const Color(0xFF1D7A46),
        ),
        _StatTile(
          title: 'الصلاحيات المباشرة',
          value: contract.grantedPermissionsCount.toString(),
          icon: Icons.verified_user_outlined,
          accent: const Color(0xFFC9A227),
        ),
        _StatTile(
          title: 'الأدوات الإدارية',
          value: contract.adminTools.length.toString(),
          icon: Icons.admin_panel_settings_outlined,
          accent: const Color(0xFF7A1F2B),
        ),
      ],
    );
  }

  Widget _buildSideColumn(BuildContext context) {
    return Column(
      children: [
        _PolicyCard(contract: contract),
        const SizedBox(height: 16),
        _IdentityCard(contract: contract),
        const SizedBox(height: 16),
        _QuickActionsCard(contract: contract),
        const SizedBox(height: 16),
        _AdminToolsCard(contract: contract),
      ],
    );
  }

  Widget _buildSystemsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.space_dashboard_outlined,
                color: Color(0xFF0F4C81),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'الأنظمة المصرح بها',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'يتم عرض هذه الأنظمة ديناميكيًا بحسب الدور النظامي والصلاحيات الممنوحة لك حاليًا.',
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 900
                  ? 3
                  : width >= 580
                  ? 2
                  : 1;
              final itemWidth = (width - ((columns - 1) * 12)) / columns;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: contract.systems.map((system) {
                  return SizedBox(
                    width: itemWidth,
                    child: _SystemCard(system: system),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({required this.contract});

  final UserDashboardContract contract;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'نموذج الصلاحية المعتمد',
      icon: Icons.policy_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contract.policyRoleLabelAr,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF0F4C81),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            contract.governanceScopeDescription,
            style: TextStyle(color: Colors.grey.shade700, height: 1.55),
          ),
          if (contract.governanceBadges.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: contract.governanceBadges
                  .map(
                    (badge) => _MiniBadge(
                      label: badge,
                      accent: const Color(0xFF0F4C81),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (contract.managedSystems.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoRow(
              label: 'الأنظمة المتابعة',
              value: contract.managedSystems.join('، '),
            ),
          ],
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.contract});

  final UserDashboardContract contract;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'هويتي ونطاقي',
      icon: Icons.badge_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'الاسم', value: contract.displayName),
          _InfoRow(label: 'البريد', value: contract.email),
          if (contract.username.isNotEmpty)
            _InfoRow(label: 'اسم المستخدم', value: '@${contract.username}'),
          _InfoRow(label: 'الدور التشغيلي', value: contract.policyRoleLabelAr),
          _InfoRow(label: 'النطاق', value: contract.scopeLabel),
          if ((contract.unitNameAr ?? '').trim().isNotEmpty)
            _InfoRow(label: 'الوحدة', value: contract.unitNameAr!),
          if ((contract.unitSlug ?? '').trim().isNotEmpty)
            _InfoRow(label: 'Slug', value: contract.unitSlug!),
          if (contract.managedSystems.isNotEmpty)
            _InfoRow(
              label: 'الأنظمة المغطاة',
              value: contract.managedSystems.join('، '),
            ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({required this.contract});

  final UserDashboardContract contract;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'الوصولات السريعة',
      icon: Icons.flash_on_outlined,
      child: Column(
        children: contract.quickActions.map((action) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.go(action.route),
              child: Ink(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF8FAFC),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Color(0xFF0F4C81),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            action.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            action.subtitle,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AdminToolsCard extends StatelessWidget {
  const _AdminToolsCard({required this.contract});

  final UserDashboardContract contract;

  @override
  Widget build(BuildContext context) {
    if (contract.adminTools.isEmpty) {
      return _SectionCard(
        title: 'أدواتي الإدارية',
        icon: Icons.settings_suggest_outlined,
        child: Text(
          'لا توجد أدوات إدارية إضافية معروضة لك حاليًا خارج الأنظمة والصلاحيات الحالية.',
          style: TextStyle(color: Colors.grey.shade700, height: 1.5),
        ),
      );
    }

    return _SectionCard(
      title: 'أدواتي الإدارية',
      icon: Icons.settings_suggest_outlined,
      child: Column(
        children: contract.adminTools.map((tool) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                alignment: Alignment.centerRight,
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => context.go(tool.route),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tool.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tool.subtitle,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.3),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0F4C81), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SystemCard extends StatelessWidget {
  final UserDashboardSystemAccess system;

  const _SystemCard({required this.system});

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(system.systemKey);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.go(system.route),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    system.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _roleLabel(system.role),
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniBadge(
                  label: system.canWrite ? 'تشغيل وإدارة' : 'قراءة فقط',
                  accent: system.canWrite
                      ? const Color(0xFF1D7A46)
                      : const Color(0xFF64748B),
                ),
                _MiniBadge(
                  label: '${system.grantedPermissions.length} صلاحية',
                  accent: accent,
                ),
              ],
            ),
            if (system.grantedPermissions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: system.grantedPermissions.map((permission) {
                  return _PermissionPill(label: _permissionLabel(permission));
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _roleLabel(dynamic role) {
    final text = role.toString().toLowerCase();
    if (text.contains('superuser')) return 'إشراف عال';
    if (text.contains('admin')) return 'إدارة نظام';
    if (text.contains('user')) return 'تشغيل';
    return 'قراءة';
  }

  static String _permissionLabel(Permission permission) {
    switch (permission) {
      case Permission.read:
        return 'قراءة';
      case Permission.create:
        return 'إنشاء';
      case Permission.update:
        return 'تعديل';
      case Permission.delete:
        return 'حذف';
      case Permission.manageUsers:
        return 'إدارة مستخدمين';
      case Permission.manageSystems:
        return 'إدارة أنظمة';
      case Permission.manageSite:
        return 'إدارة الموقع';
      case Permission.manageHome:
        return 'إدارة الصفحة الرئيسية';
      case Permission.viewReports:
        return 'تقارير';
      case Permission.manageZakat:
        return 'إدارة الزكاة';
      case Permission.managePrayerTimes:
        return 'إدارة المواقيت';
      case Permission.manageQuran:
        return 'إدارة القرآن';
      case Permission.manageMapLayers:
        return 'طبقات GIS';
      case Permission.manageLandsCrud:
        return 'إدارة الأراضي';
    }
  }

  static Color _accentFor(dynamic key) {
    switch (key.toString()) {
      case 'SystemKey.platformAdmin':
        return const Color(0xFF0F4C81);
      case 'SystemKey.lands':
        return const Color(0xFF1D7A46);
      case 'SystemKey.cases':
        return const Color(0xFFB22222);
      case 'SystemKey.tasks':
        return const Color(0xFF7A1F2B);
      default:
        return const Color(0xFFC9A227);
    }
  }
}

class _PermissionPill extends StatelessWidget {
  const _PermissionPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final Color accent;

  const _MiniBadge({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: accent, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, height: 1.3),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ],
            ),
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
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
