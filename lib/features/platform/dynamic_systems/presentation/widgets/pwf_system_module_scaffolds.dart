import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/pwf_dynamic_system_models.dart';

/// Standard System Module Kit widgets for semi-independent systems inside PalWakf.
///
/// N2.14 rule:
/// Any dynamic system registered in `platform.system_registry` and any section
/// registered in `platform.system_sections` must render through common shells so
/// that header/footer, dashboard, maintenance, error boundary, assistant scope,
/// usage guide scope, and RBAC visibility stay consistent across systems.
class PwfSystemAdminScaffold extends StatelessWidget {
  const PwfSystemAdminScaffold({
    super.key,
    required this.module,
    this.activeSection,
    required this.children,
  });

  final PwfDynamicSystemModule module;
  final PwfDynamicSystemSection? activeSection;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          PwfSystemContextHeader(module: module, activeSection: activeSection),
          const SizedBox(height: 14),
          PwfSystemOperationalStrip(
            module: module,
            activeSection: activeSection,
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class PwfSystemPublicScaffold extends StatelessWidget {
  const PwfSystemPublicScaffold({
    super.key,
    required this.module,
    required this.children,
  });

  final PwfDynamicSystemModule module;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          PwfSystemPublicHero(module: module),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class PwfSystemDashboardScaffold extends StatelessWidget {
  const PwfSystemDashboardScaffold({
    super.key,
    required this.module,
    required this.sections,
    this.emptyMessage,
  });

  final PwfDynamicSystemModule module;
  final List<PwfDynamicSystemSection> sections;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PwfSystemSectionCard(
          icon: module.icon,
          title: module.nameAr,
          subtitle: module.descriptionAr.isEmpty
              ? 'نظام شبه مستقل مسجل في platform.system_registry ويخضع للصلاحيات والأدوار الديناميكية.'
              : module.descriptionAr,
          chips: [
            'النظام: ${module.systemKey}',
            'النوع: ${module.moduleType.labelAr}',
            'التصنيف: ${module.categoryKey}',
            'الحساسية: ${_metadataValue(module.metadata, 'sensitivity_level', fallback: module.isSovereign ? 'high' : 'standard')}',
          ],
        ),
        const SizedBox(height: 18),
        if (sections.isEmpty)
          PwfSystemEmptyState(
            title: 'لا توجد أقسام متاحة',
            message:
                emptyMessage ??
                'لا توجد أقسام مسجلة أو مصرح بها لهذا المستخدم ضمن platform.system_sections.',
          )
        else
          PwfSystemSectionsGrid(module: module, sections: sections),
        const SizedBox(height: 18),
        PwfSystemGovernanceCard(module: module),
      ],
    );
  }
}

class PwfSystemContextHeader extends StatelessWidget {
  const PwfSystemContextHeader({
    super.key,
    required this.module,
    this.activeSection,
  });

  final PwfDynamicSystemModule module;
  final PwfDynamicSystemSection? activeSection;

  @override
  Widget build(BuildContext context) {
    final title = activeSection == null
        ? module.nameAr
        : '${module.nameAr} / ${activeSection!.titleAr}';
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C81), Color(0xFF0B1220)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              activeSection?.icon ?? module.icon,
              color: const Color(0xFF0F4C81),
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'واجهة نظام شبه مستقل داخل PalWakf: مدمج حوكميًا عبر Auth/RBAC/Registry، ومعزول تشغيليًا بعقود واضحة.',
                  style: TextStyle(color: Color(0xFFD7E3F6), height: 1.5),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => context.go('/admin/dashboard'),
            icon: const Icon(Icons.dashboard_rounded, color: Colors.white),
            label: const Text(
              'لوحة التحكم',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class PwfSystemPublicHero extends StatelessWidget {
  const PwfSystemPublicHero({super.key, required this.module});

  final PwfDynamicSystemModule module;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(module.icon, color: const Color(0xFF0F4C81), size: 44),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.nameAr,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0B1220),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  module.descriptionAr.isEmpty
                      ? 'صفحة تعريفية للنظام ضمن PalWakf.'
                      : module.descriptionAr,
                  style: const TextStyle(color: Color(0xFF64748B), height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PwfSystemOperationalStrip extends StatelessWidget {
  const PwfSystemOperationalStrip({
    super.key,
    required this.module,
    this.activeSection,
  });

  final PwfDynamicSystemModule module;
  final PwfDynamicSystemSection? activeSection;

  @override
  Widget build(BuildContext context) {
    final maintenance = _metadataBool(
      activeSection?.metadata ?? module.metadata,
      'maintenance_mode',
    );
    final health = _metadataValue(
      module.metadata,
      'health_status',
      fallback: maintenance ? 'maintenance' : 'healthy',
    );
    final sensitivity = _metadataValue(
      module.metadata,
      'sensitivity_level',
      fallback: module.isSovereign ? 'high' : 'standard',
    );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        PwfSystemStatusBadge(
          label: 'الصحة: $health',
          icon: Icons.monitor_heart_rounded,
        ),
        PwfSystemStatusBadge(
          label: 'الحساسية: $sensitivity',
          icon: Icons.shield_rounded,
        ),
        PwfSystemStatusBadge(
          label: maintenance ? 'وضع الصيانة مفعل' : 'تشغيل عادي',
          icon: maintenance
              ? Icons.construction_rounded
              : Icons.check_circle_rounded,
        ),
        PwfSystemStatusBadge(
          label: 'RBAC / Registry',
          icon: Icons.verified_user_rounded,
        ),
      ],
    );
  }
}

class PwfSystemSectionsGrid extends StatelessWidget {
  const PwfSystemSectionsGrid({
    super.key,
    required this.module,
    required this.sections,
  });

  final PwfDynamicSystemModule module;
  final List<PwfDynamicSystemSection> sections;

  @override
  Widget build(BuildContext context) {
    return PwfSystemPanel(
      title: 'أقسام النظام',
      subtitle:
          'أي قسم جديد يضاف إلى platform.system_sections يظهر هنا تلقائيًا إذا سمحت الصلاحيات.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final section in sections)
            PwfSystemActionCard(
              icon: section.icon,
              title: section.titleAr,
              subtitle: section.descriptionAr.isEmpty
                  ? 'قسم ديناميكي: ${section.sectionType}'
                  : section.descriptionAr,
              chips: [
                'section: ${section.sectionKey}',
                'permission: ${section.requiredPermissionKey}',
              ],
              onTap: () => context.go(section.routePath),
            ),
        ],
      ),
    );
  }
}

class PwfSystemGovernanceCard extends StatelessWidget {
  const PwfSystemGovernanceCard({super.key, required this.module});

  final PwfDynamicSystemModule module;

  @override
  Widget build(BuildContext context) {
    return PwfSystemSectionCard(
      icon: Icons.hub_rounded,
      title: 'حوكمة النظام شبه المستقل',
      subtitle:
          'هذا النظام يعمل كنظام فرعي Bounded System: يظهر عبر Dynamic Registry، وتظهر أقسامه عبر platform.system_sections، ويتكامل مع الأنظمة الأخرى عبر RPC/views/contracts فقط.',
      chips: [
        'Sidebar/Dashboard من نفس AccessProfile',
        'Assistant Scope مقيد',
        'Usage Guide Scope مقيد',
        'لا كتابة مباشرة بين الأنظمة',
      ],
    );
  }
}

class PwfSystemPanel extends StatelessWidget {
  const PwfSystemPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF64748B), height: 1.5),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class PwfSystemSectionCard extends StatelessWidget {
  const PwfSystemSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.chips,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> chips;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF0F4C81), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final chip in chips)
                        Chip(
                          label: Text(chip),
                          backgroundColor: const Color(0xFFE8F0FE),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );
  }
}

class PwfSystemActionCard extends StatelessWidget {
  const PwfSystemActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> chips;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 300,
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
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F4C81).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF0F4C81)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final chip in chips)
                  Chip(label: Text(chip), visualDensity: VisualDensity.compact),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PwfSystemStatusBadge extends StatelessWidget {
  const PwfSystemStatusBadge({
    super.key,
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0F4C81)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class PwfSystemEmptyState extends StatelessWidget {
  const PwfSystemEmptyState({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, size: 42, color: Color(0xFF94A3B8)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), height: 1.5),
          ),
        ],
      ),
    );
  }
}

class PwfSystemErrorState extends StatelessWidget {
  const PwfSystemErrorState({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Color(0xFFB22222),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _metadataValue(
  Map<String, dynamic> metadata,
  String key, {
  required String fallback,
}) {
  final value = metadata[key];
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? fallback : text;
}

bool _metadataBool(Map<String, dynamic> metadata, String key) {
  final value = metadata[key];
  if (value is bool) return value;
  final text = value?.toString().trim().toLowerCase();
  return text == 'true' || text == '1' || text == 'yes';
}
