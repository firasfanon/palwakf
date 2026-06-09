import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/routing/app_routes.dart';
import '../../../../../core/access/access_profile.dart';
import '../../../../../core/access/access_provider.dart';
import '../../data/models/pwf_dynamic_system_models.dart';
import '../providers/pwf_dynamic_system_registry_providers.dart';

/// Platform-level operations console for semi-independent systems.
///
/// This page does not implement an individual system. It keeps the platform
/// responsible for registry, routing, RBAC, health/maintenance metadata, and
/// handoff readiness while systems such as awqaf_system remain operationally
/// isolated until their real runtime is merged.
class PwfPlatformSystemOperationsPage extends ConsumerWidget {
  const PwfPlatformSystemOperationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(dynamicSystemAdminCatalogProvider);
    final visibleAsync = ref.watch(visibleDynamicAdminSystemsProvider);
    final accessAsync = ref.watch(accessProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const _OperationsFailure(),
        data: (catalog) {
          final visible =
              visibleAsync.valueOrNull ?? const <PwfDynamicSystemModule>[];
          final profile = accessAsync.valueOrNull;
          final visibleKeys = visible
              .map(
                (module) =>
                    AccessProfile.normalizeSystemKeyAlias(module.systemKey),
              )
              .toSet();
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _OperationsHero(
                totalSystems: catalog.length,
                activeSystems: catalog
                    .where((module) => module.isActive)
                    .length,
                visibleSystems: visible.length,
                rootAuthority: profile?.hasPlatformRootAuthority == true,
              ),
              const SizedBox(height: 18),
              _OperationsDecisionStrip(profile: profile),
              const SizedBox(height: 18),
              _OperationsMetricsGrid(catalog: catalog, visible: visible),
              const SizedBox(height: 18),
              if (catalog.isEmpty)
                const _EmptyCatalogState()
              else
                ...catalog.map(
                  (module) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _SystemOperationsCard(
                      module: module,
                      profile: profile,
                      visibleByRpc: visibleKeys.contains(
                        AccessProfile.normalizeSystemKeyAlias(module.systemKey),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              const _OperationalRulesCard(),
            ],
          );
        },
      ),
    );
  }
}

class _OperationsHero extends StatelessWidget {
  const _OperationsHero({
    required this.totalSystems,
    required this.activeSystems,
    required this.visibleSystems,
    required this.rootAuthority,
  });

  final int totalSystems;
  final int activeSystems;
  final int visibleSystems;
  final bool rootAuthority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C81), Color(0xFF0B1220)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.account_tree_rounded,
              color: Color(0xFF0F4C81),
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مركز تشغيل الأنظمة المندمجة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'لوحة منصة مركزية لمتابعة الأنظمة شبه المستقلة: سجل الأنظمة، الوصول، المسارات، حالة الصحة، وضع الصيانة، وجاهزية الدمج دون اختراق حدود كل نظام.',
                  style: TextStyle(color: Color(0xFFD7E3F6), height: 1.6),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Chip(text: 'الأنظمة المسجلة: $totalSystems'),
                    _Chip(text: 'المفعلة: $activeSystems'),
                    _Chip(text: 'مرئية للمستخدم: $visibleSystems'),
                    _Chip(
                      text: rootAuthority
                          ? 'Root Authority: yes'
                          : 'Root Authority: no',
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => context.go(AppRoutes.adminDynamicSystemRegistry),
            icon: const Icon(
              Icons.playlist_add_check_rounded,
              color: Colors.white,
            ),
            label: const Text(
              'سجل الأنظمة',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationsDecisionStrip extends StatelessWidget {
  const _OperationsDecisionStrip({required this.profile});

  final AccessProfile? profile;

  @override
  Widget build(BuildContext context) {
    final root = profile?.hasPlatformRootAuthority == true;
    final active = profile?.isActive == true;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _StatusBadge(
            icon: active
                ? Icons.check_circle_rounded
                : Icons.lock_outline_rounded,
            label: active ? 'الحساب فعال' : 'الحساب غير محمل/غير فعال',
          ),
          _StatusBadge(
            icon: root
                ? Icons.verified_user_rounded
                : Icons.manage_accounts_rounded,
            label: root
                ? 'Superuser يمر قبل scoped permissions'
                : 'الصلاحيات حسب النظام والسجل الديناميكي',
          ),
          const _StatusBadge(
            icon: Icons.route_rounded,
            label: 'المسارات التشغيلية عبر /admin/systems/:systemKey',
          ),
          const _StatusBadge(
            icon: Icons.shield_rounded,
            label: 'لا لمس لـ waqf_assets من هذه الصفحة',
          ),
        ],
      ),
    );
  }
}

class _OperationsMetricsGrid extends StatelessWidget {
  const _OperationsMetricsGrid({required this.catalog, required this.visible});

  final List<PwfDynamicSystemModule> catalog;
  final List<PwfDynamicSystemModule> visible;

  @override
  Widget build(BuildContext context) {
    final sovereign = catalog.where((module) => module.isSovereign).length;
    final maintenance = catalog
        .where((module) => _metadataBool(module.metadata, 'maintenance_mode'))
        .length;
    final withPublicEntry = catalog
        .where((module) => (module.publicRoutePath ?? '').trim().isNotEmpty)
        .length;
    final withSections = catalog
        .where((module) => module.sections.isNotEmpty)
        .length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;
        final cards = [
          _MetricCard(
            label: 'سيادية',
            value: '$sovereign',
            icon: Icons.security_rounded,
          ),
          _MetricCard(
            label: 'صيانة',
            value: '$maintenance',
            icon: Icons.construction_rounded,
          ),
          _MetricCard(
            label: 'مدخل عام',
            value: '$withPublicEntry',
            icon: Icons.public_rounded,
          ),
          _MetricCard(
            label: 'أقسام',
            value: '$withSections',
            icon: Icons.view_module_rounded,
          ),
        ];
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: compact ? 2 : 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: compact ? 2.1 : 2.7,
          children: cards,
        );
      },
    );
  }
}

class _SystemOperationsCard extends StatelessWidget {
  const _SystemOperationsCard({
    required this.module,
    required this.profile,
    required this.visibleByRpc,
  });

  final PwfDynamicSystemModule module;
  final AccessProfile? profile;
  final bool visibleByRpc;

  @override
  Widget build(BuildContext context) {
    final canOperate =
        profile?.canAccessSystemByAlias(module.systemKey) ?? false;
    final canManage =
        profile?.canManageDynamicSystem(module.systemKey) ?? false;
    final root = profile?.hasPlatformRootAuthority == true;
    final maintenance = _metadataBool(module.metadata, 'maintenance_mode');
    final health = _metadataValue(
      module.metadata,
      'health_status',
      fallback: maintenance ? 'maintenance' : 'unknown',
    );
    final integrationStatus = _metadataValue(
      module.metadata,
      'integration_status',
      fallback: 'registered',
    );
    final sensitivity = _metadataValue(
      module.metadata,
      'sensitivity_level',
      fallback: module.isSovereign ? 'high' : 'standard',
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  module.icon,
                  color: const Color(0xFF0F4C81),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.nameAr,
                      style: const TextStyle(
                        color: Color(0xFF0B1220),
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      module.descriptionAr.isEmpty
                          ? 'نظام مسجل في سجل الأنظمة الديناميكي.'
                          : module.descriptionAr,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              _AccessPill(
                label: canOperate ? 'مسموح' : 'محجوب',
                allowed: canOperate,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusBadge(
                icon: Icons.key_rounded,
                label: 'key: ${module.systemKey}',
              ),
              _StatusBadge(
                icon: Icons.category_rounded,
                label: module.moduleType.labelAr,
              ),
              _StatusBadge(
                icon: Icons.health_and_safety_rounded,
                label: 'health: $health',
              ),
              _StatusBadge(
                icon: Icons.integration_instructions_rounded,
                label: 'integration: $integrationStatus',
              ),
              _StatusBadge(
                icon: Icons.shield_rounded,
                label: 'sensitivity: $sensitivity',
              ),
              if (visibleByRpc)
                const _StatusBadge(
                  icon: Icons.visibility_rounded,
                  label: 'visible RPC',
                ),
              if (root)
                const _StatusBadge(
                  icon: Icons.verified_user_rounded,
                  label: 'root bypass',
                ),
              if (canManage)
                const _StatusBadge(
                  icon: Icons.admin_panel_settings_rounded,
                  label: 'manage',
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: (module.publicRoutePath ?? '').trim().isEmpty
                    ? null
                    : () => context.go(module.publicRoutePath!.trim()),
                icon: const Icon(Icons.public_rounded),
                label: const Text('المدخل العام'),
              ),
              FilledButton.icon(
                onPressed: canOperate
                    ? () => context.go(module.routeForShell())
                    : null,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('مركز التشغيل'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OperationalRulesCard extends StatelessWidget {
  const _OperationalRulesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'قواعد التشغيل المعتمدة في هذه الدفعة',
            style: TextStyle(
              color: Color(0xFF0B1220),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '• أعمال أوقاف سيستم السابقة لا تُلغى؛ تحفظ كطبقة تجهيز للدمج.\n'
            '• المنصة لا تطور منطق awqaf_system الداخلي هنا، بل تضبط الدخول والتسجيل والربط.\n'
            '• Superuser/Platform Root Authority يمر قبل فحص صلاحيات النظام scoped.\n'
            '• أي Quarantine لجداول cache يبقى مشروطًا بنتيجة SQL strict gate.\n'
            '• waqf_assets وschema waqf وبيانات الأصول السيادية خارج نطاق هذه الصفحة.',
            style: TextStyle(color: Color(0xFF475569), height: 1.7),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0F4C81)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0B1220),
                  ),
                ),
                Text(label, style: const TextStyle(color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0F4C81)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessPill extends StatelessWidget {
  const _AccessPill({required this.label, required this.allowed});

  final String label;
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: allowed ? const Color(0xFFEFFAF3) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: allowed ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: allowed ? const Color(0xFF166534) : const Color(0xFF991B1B),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OperationsFailure extends StatelessWidget {
  const _OperationsFailure();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620),
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: Color(0xFFB22222),
              ),
              SizedBox(height: 12),
              Text(
                'تعذر تحميل مركز تشغيل الأنظمة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 8),
              Text(
                'تحقق من وجود RPCs الخاصة بسجل الأنظمة الديناميكي ومن صلاحيات المستخدم. لا يتم عرض أخطاء backend الخام للمستخدم.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCatalogState extends StatelessWidget {
  const _EmptyCatalogState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 42,
            color: Color(0xFF0F4C81),
          ),
          const SizedBox(height: 12),
          const Text(
            'لا توجد أنظمة مسجلة بعد',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ من سجل الأنظمة والأقسام لإضافة awqaf_system أو أي نظام شبه مستقل، ثم عد إلى هذه الصفحة لمراقبة التشغيل.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), height: 1.6),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.adminDynamicSystemRegistry),
            icon: const Icon(Icons.playlist_add_rounded),
            label: const Text('فتح سجل الأنظمة'),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: const Color(0xFFE5E7EB)),
    boxShadow: const [
      BoxShadow(color: Color(0x0A000000), blurRadius: 14, offset: Offset(0, 8)),
    ],
  );
}

String _metadataValue(
  Map<String, dynamic> metadata,
  String key, {
  required String fallback,
}) {
  final value = metadata[key];
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

bool _metadataBool(Map<String, dynamic> metadata, String key) {
  final value = metadata[key];
  if (value is bool) return value;
  final text = value?.toString().trim().toLowerCase();
  return text == 'true' || text == '1' || text == 'yes';
}
