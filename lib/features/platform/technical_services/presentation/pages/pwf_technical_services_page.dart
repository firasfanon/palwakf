import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/app/routing/app_routes.dart';

import '../../application/pwf_technical_services_providers.dart';
import '../../domain/models/pwf_technical_service_models.dart';
import '../../domain/models/pwf_technical_service_operations_models.dart';

enum PwfTechnicalServiceSection {
  overview,
  backup,
  maintenance,
  health,
  deployment,
  audit,
}

/// Real governed technical services console.
///
/// This page is no longer a static readiness mock. It is wired to backend RPCs:
/// - rpc_platform_technical_services_dashboard_v1
/// - rpc_platform_technical_service_request_create_v1
/// - rpc_platform_maintenance_window_create_v1
/// - rpc_platform_technical_release_record_create_v1
/// - rpc_platform_technical_health_snapshot_refresh_v1
///
/// The page still does not execute destructive backup/restore or close the site
/// directly. It creates governed requests, records releases, schedules
/// maintenance windows, refreshes health snapshots, and displays audit state.
class PwfTechnicalServicesPage extends ConsumerWidget {
  const PwfTechnicalServicesPage({
    super.key,
    this.section = PwfTechnicalServiceSection.overview,
  });

  final PwfTechnicalServiceSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedModule = _moduleFor(section);
    final state = ref.watch(pwfTechnicalServicesControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(pwfTechnicalServicesControllerProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TechnicalHero(module: selectedModule),
                const SizedBox(height: 18),
                _TechnicalNavigation(section: section),
                const SizedBox(height: 18),
                const _TechnicalGuardrailStrip(),
                const SizedBox(height: 18),
                state.when(
                  loading: () => const _LoadingPanel(),
                  error: (error, stack) => _ErrorPanel(
                    message: error.toString(),
                    onRetry: () => ref
                        .read(pwfTechnicalServicesControllerProvider.notifier)
                        .refresh(),
                  ),
                  data: (dashboard) => _TechnicalDashboardBody(
                    section: section,
                    module: selectedModule,
                    dashboard: dashboard,
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

class _TechnicalDashboardBody extends ConsumerWidget {
  const _TechnicalDashboardBody({
    required this.section,
    required this.module,
    required this.dashboard,
  });

  final PwfTechnicalServiceSection section;
  final _TechnicalModule module;
  final PwfTechnicalServicesDashboard dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BackendStatusStrip(dashboard: dashboard),
        const SizedBox(height: 18),
        _TechnicalClosureStrip(dashboard: dashboard),
        const SizedBox(height: 18),
        _MetricsGrid(metrics: dashboard.metrics),
        const SizedBox(height: 18),
        if (section == PwfTechnicalServiceSection.overview)
          _TechnicalOverview(dashboard: dashboard)
        else
          _TechnicalModuleDetail(
            module: module,
            dashboard: dashboard,
          ),
      ],
    );
  }
}

class _TechnicalHero extends StatelessWidget {
  const _TechnicalHero({required this.module});

  final _TechnicalModule module;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0F4C81), Color(0xFF0B1220)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final content = [
            Expanded(
              flex: compact ? 0 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Text(
                      'خدمات تقنية تشغيلية — طلبات واعتماد وسجل تدقيق',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    module.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    module.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 14.5,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18, height: 18),
            Container(
              width: compact ? double.infinity : 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeroMetric(
                    label: 'نمط التنفيذ',
                    value: 'RPC + Audit',
                    icon: Icons.verified_user_outlined,
                  ),
                  SizedBox(height: 12),
                  _HeroMetric(
                    label: 'التشغيل الخطر',
                    value: 'طلب واعتماد',
                    icon: Icons.lock_outline_rounded,
                  ),
                  SizedBox(height: 12),
                  _HeroMetric(
                    label: 'الإنتاج',
                    value: 'بوابة اعتماد',
                    icon: Icons.fact_check_outlined,
                  ),
                ],
              ),
            ),
          ];

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: content,
          );
        },
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: Colors.white, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TechnicalNavigation extends StatelessWidget {
  const _TechnicalNavigation({required this.section});

  final PwfTechnicalServiceSection section;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _technicalModules.map((module) {
        final selected = module.section == section;
        return InkWell(
          onTap: () => context.go(module.route),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE8F0FE) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    selected ? const Color(0xFF0F4C81) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  module.icon,
                  size: 18,
                  color: selected
                      ? const Color(0xFF0F4C81)
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Text(
                  module.shortTitle,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF0F4C81)
                        : const Color(0xFF334155),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _TechnicalGuardrailStrip extends StatelessWidget {
  const _TechnicalGuardrailStrip();

  @override
  Widget build(BuildContext context) {
    const items = [
      _GuardrailItem('لا service_role في Flutter', Icons.no_encryption_outlined),
      _GuardrailItem('Backup/Restore = طلب واعتماد', Icons.approval_outlined),
      _GuardrailItem('Maintenance لا يغلق الموقع تلقائيًا', Icons.construction_rounded),
      _GuardrailItem('كل إجراء له Audit Event', Icons.assignment_turned_in_outlined),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items.map((item) => _GuardrailChip(item: item)).toList(),
      ),
    );
  }
}

class _GuardrailItem {
  const _GuardrailItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _GuardrailChip extends StatelessWidget {
  const _GuardrailChip({required this.item});
  final _GuardrailItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 17, color: const Color(0xFF92400E)),
          const SizedBox(width: 7),
          Text(
            item.label,
            style: const TextStyle(
              color: Color(0xFF92400E),
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackendStatusStrip extends StatelessWidget {
  const _BackendStatusStrip({required this.dashboard});

  final PwfTechnicalServicesDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final ok = dashboard.backendApplied;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ok ? const Color(0xFFEFFDF5) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ok ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ok ? Icons.cloud_done_rounded : Icons.warning_amber_rounded,
            color: ok ? const Color(0xFF166534) : const Color(0xFF92400E),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ok
                  ? 'Backend contract متصل: الجداول و RPCs التقنية تعمل وتعرض بيانات حية.'
                  : 'الواجهة تعمل، لكن Backend contract غير مطبق أو غير متاح. طبّق SQL المرفق لتفعيل الطلبات والسجلات والمؤشرات الحية.',
              style: TextStyle(
                color: ok ? const Color(0xFF166534) : const Color(0xFF92400E),
                fontWeight: FontWeight.w800,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _TechnicalClosureStrip extends StatelessWidget {
  const _TechnicalClosureStrip({required this.dashboard});

  final PwfTechnicalServicesDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final backendReady = dashboard.backendApplied;
    final operationsReady = dashboard.notifications.isNotEmpty ||
        dashboard.evidence.isNotEmpty ||
        dashboard.operationDecisions.isNotEmpty ||
        dashboard.auditEvents.isNotEmpty;

    final chips = [
      _ClosureChip(
        label: backendReady ? 'Backend RPC متصل' : 'Backend غير مكتمل',
        status: backendReady ? 'passed' : 'blocked',
        icon: backendReady ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
      ),
      _ClosureChip(
        label: 'لا service_role في Flutter',
        status: 'passed',
        icon: Icons.no_encryption_outlined,
      ),
      _ClosureChip(
        label: operationsReady ? 'Operations evidence ظاهر' : 'Operations ينتظر بيانات',
        status: operationsReady ? 'passed' : 'pending',
        icon: Icons.rule_folder_outlined,
      ),
      const _ClosureChip(
        label: 'التنفيذ الخطر خارج Flutter',
        status: 'passed',
        icon: Icons.lock_clock_outlined,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: chips,
      ),
    );
  }
}

class _ClosureChip extends StatelessWidget {
  const _ClosureChip({
    required this.label,
    required this.status,
    required this.icon,
  });

  final String label;
  final String status;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationsCenter extends StatelessWidget {
  const _OperationsCenter({required this.dashboard});

  final PwfTechnicalServicesDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return _WhitePanel(
      title: 'مركز الإغلاق التشغيلي والأدلة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 820;
              final width = compact
                  ? constraints.maxWidth
                  : ((constraints.maxWidth - 28) / 3).clamp(240.0, 420.0);

              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  SizedBox(
                    width: width.toDouble(),
                    child: _OperationsCountCard(
                      title: 'Evidence',
                      value: dashboard.evidence.length.toString(),
                      subtitle: 'لقطات، Network، SQL، قرارات',
                      icon: Icons.attachment_rounded,
                      status: dashboard.evidence.isEmpty ? 'pending' : 'passed',
                    ),
                  ),
                  SizedBox(
                    width: width.toDouble(),
                    child: _OperationsCountCard(
                      title: 'Notifications',
                      value: dashboard.notifications.length.toString(),
                      subtitle: 'تنبيهات تشغيلية داخلية',
                      icon: Icons.notifications_active_outlined,
                      status: dashboard.notifications.isEmpty ? 'pending' : 'ready',
                    ),
                  ),
                  SizedBox(
                    width: width.toDouble(),
                    child: _OperationsCountCard(
                      title: 'Decisions',
                      value: dashboard.operationDecisions.length.toString(),
                      subtitle: 'اعتماد، تأجيل، إغلاق، Rollback',
                      icon: Icons.gavel_rounded,
                      status: dashboard.operationDecisions.isEmpty ? 'pending' : 'passed',
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _NotificationsPreview(notifications: dashboard.notifications),
          const SizedBox(height: 14),
          _EvidencePreview(evidence: dashboard.evidence),
          const SizedBox(height: 14),
          _DecisionsPreview(decisions: dashboard.operationDecisions),
        ],
      ),
    );
  }
}

class _OperationsCountCard extends StatelessWidget {
  const _OperationsCountCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.status,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
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

class _NotificationsPreview extends StatelessWidget {
  const _NotificationsPreview({required this.notifications});

  final List<PwfTechnicalNotification> notifications;

  @override
  Widget build(BuildContext context) {
    return _SimpleRows(
      emptyLabel: 'لا توجد تنبيهات تشغيلية مسجلة.',
      headers: const ['العنوان', 'الشدة', 'النوع', 'التاريخ'],
      rows: notifications
          .take(6)
          .map((item) => [
                item.title,
                item.severity,
                item.notificationType,
                _formatDate(item.createdAt),
              ])
          .toList(growable: false),
    );
  }
}

class _EvidencePreview extends StatelessWidget {
  const _EvidencePreview({required this.evidence});

  final List<PwfTechnicalEvidence> evidence;

  @override
  Widget build(BuildContext context) {
    return _SimpleRows(
      emptyLabel: 'لا توجد أدلة تشغيلية مسجلة بعد.',
      headers: const ['العنوان', 'النوع', 'الوصف', 'التاريخ'],
      rows: evidence
          .take(6)
          .map((item) => [
                item.title,
                item.evidenceType,
                item.description ?? '-',
                _formatDate(item.createdAt),
              ])
          .toList(growable: false),
    );
  }
}

class _DecisionsPreview extends StatelessWidget {
  const _DecisionsPreview({required this.decisions});

  final List<PwfTechnicalOperationDecision> decisions;

  @override
  Widget build(BuildContext context) {
    return _SimpleRows(
      emptyLabel: 'لا توجد قرارات تشغيلية مسجلة.',
      headers: const ['القرار', 'النوع', 'السبب', 'التاريخ'],
      rows: decisions
          .take(6)
          .map((item) => [
                item.decisionLabel,
                item.decisionType,
                item.decisionReason ?? '-',
                _formatDate(item.decidedAt),
              ])
          .toList(growable: false),
    );
  }
}


class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.metrics});

  final List<PwfTechnicalMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final shown = metrics.isEmpty
        ? const [
            PwfTechnicalMetric(
              keyName: 'empty',
              label: 'Metrics',
              value: 'لا توجد مؤشرات بعد',
              status: 'unknown',
            ),
          ]
        : metrics;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 820;
        final width = compact
            ? constraints.maxWidth
            : ((constraints.maxWidth - 30) / 3).clamp(240.0, 420.0);
        return Wrap(
          spacing: 15,
          runSpacing: 15,
          children: shown
              .map(
                (metric) => SizedBox(
                  width: width.toDouble(),
                  child: _MetricCard(metric: metric),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final PwfTechnicalMetric metric;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(metric.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.insights_rounded, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  metric.value,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
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

class _TechnicalOverview extends StatelessWidget {
  const _TechnicalOverview({required this.dashboard});

  final PwfTechnicalServicesDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cardWidth = width < 760 ? width : (width - 28) / 2;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: _technicalModules
                  .where((module) =>
                      module.section != PwfTechnicalServiceSection.overview)
                  .map(
                    (module) => SizedBox(
                      width: cardWidth.clamp(280.0, 520.0).toDouble(),
                      child: _TechnicalModuleCard(module: module),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
        const SizedBox(height: 18),
        _RecentRequestsTable(requests: dashboard.requests),
        const SizedBox(height: 18),
        _TechnicalMatrix(dashboard: dashboard),
        const SizedBox(height: 18),
        _OperationsCenter(dashboard: dashboard),
      ],
    );
  }
}

class _TechnicalModuleCard extends StatelessWidget {
  const _TechnicalModuleCard({required this.module});

  final _TechnicalModule module;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: module.tint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(module.icon, color: module.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  module.shortTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            module.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF64748B), height: 1.55),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => context.go(module.route),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('فتح المساحة'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F4C81),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnicalModuleDetail extends ConsumerWidget {
  const _TechnicalModuleDetail({
    required this.module,
    required this.dashboard,
  });

  final _TechnicalModule module;
  final PwfTechnicalServicesDashboard dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModuleActionHeader(module: module),
        const SizedBox(height: 16),
        _ModuleActionBar(module: module),
        const SizedBox(height: 16),
        _ModuleLivePanel(module: module, dashboard: dashboard),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final tight = constraints.maxWidth < 900;
            final width = tight ? constraints.maxWidth : (constraints.maxWidth - 14) / 2;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: module.panels
                  .map(
                    (panel) => SizedBox(
                      width: width,
                      child: _TechnicalPanel(panel: panel),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
        const SizedBox(height: 18),
        const _DeferredExecutionNotice(),
      ],
    );
  }
}

class _ModuleActionHeader extends StatelessWidget {
  const _ModuleActionHeader({required this.module});

  final _TechnicalModule module;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: module.tint,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(module.icon, color: module.color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.shortTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  module.statusLabel,
                  style: TextStyle(
                    color: module.color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  module.description,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    height: 1.6,
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

class _ModuleActionBar extends ConsumerWidget {
  const _ModuleActionBar({required this.module});

  final _TechnicalModule module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.read(pwfTechnicalServicesControllerProvider.notifier);

    Future<void> runAction(Future<void> Function() action) async {
      try {
        await action();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تسجيل الإجراء بنجاح')),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تعذر التنفيذ: $error')),
          );
        }
      }
    }

    switch (module.section) {
      case PwfTechnicalServiceSection.backup:
        return _ActionCard(
          title: 'طلب نسخ احتياطي محكوم',
          description:
              'ينشئ طلبًا موثقًا للنسخ الاحتياطي دون تشغيل export من Flutter.',
          icon: Icons.backup_rounded,
          onPressed: () async {
            final data = await _showRequestDialog(
              context,
              title: 'تسجيل طلب نسخ احتياطي',
              defaultAction: 'backup_request',
              defaultRisk: 'medium',
            );
            if (data == null) return;
            await runAction(() => controller.createServiceRequest(
                  serviceType: 'backup',
                  actionType: data.actionType,
                  title: data.title,
                  description: data.description,
                  riskLevel: data.riskLevel,
                  payload: {'source': 'flutter_admin_dashboard'},
                ));
          },
        );
      case PwfTechnicalServiceSection.maintenance:
        return _ActionCard(
          title: 'جدولة نافذة صيانة',
          description:
              'ينشئ نافذة صيانة مخططة تحتاج اعتمادًا قبل أي تفعيل فعلي.',
          icon: Icons.construction_rounded,
          onPressed: () async {
            final data = await _showMaintenanceDialog(context);
            if (data == null) return;
            await runAction(() => controller.createMaintenanceWindow(
                  title: data.title,
                  messageAr: data.messageAr,
                  startsAt: data.startsAt,
                  endsAt: data.endsAt,
                  affectedSurfaces: data.affectedSurfaces,
                ));
          },
        );
      case PwfTechnicalServiceSection.health:
        return _ActionCard(
          title: 'تحديث Health Snapshot',
          description:
              'يشغّل RPC آمنًا لتحديث مؤشرات صحية من catalog/RPCs دون تعديل بيانات سيادية.',
          icon: Icons.monitor_heart_rounded,
          onPressed: () => runAction(controller.refreshHealthSnapshot),
        );
      case PwfTechnicalServiceSection.deployment:
        return _ActionCard(
          title: 'تسجيل Release Record',
          description:
              'يسجل أثر إصدار أو نشر Vercel دون تنفيذ deploy من الواجهة.',
          icon: Icons.rocket_launch_rounded,
          onPressed: () async {
            final data = await _showReleaseDialog(context);
            if (data == null) return;
            await runAction(() => controller.recordRelease(
                  releaseTag: data.releaseTag,
                  gitCommitHash: data.gitCommitHash,
                  deployUrl: data.deployUrl,
                  status: data.status,
                ));
          },
        );
      case PwfTechnicalServiceSection.audit:
        return _ActionCard(
          title: 'تحديث سجلات التدقيق',
          description:
              'يعيد تحميل audit events المسجلة في backend contract.',
          icon: Icons.manage_search_rounded,
          onPressed: controller.refresh,
        );
      case PwfTechnicalServiceSection.overview:
        return _ActionCard(
          title: 'تحديث لوحة الخدمات',
          description: 'إعادة تحميل الطلبات والمؤشرات والسجلات من RPC.',
          icon: Icons.refresh_rounded,
          onPressed: controller.refresh,
        );
    }
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String description;
  final IconData icon;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0F4C81)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 5),
                Text(description,
                    style: const TextStyle(
                        color: Color(0xFF475569), height: 1.5)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add_task_rounded, size: 18),
            label: const Text('تنفيذ آمن'),
          ),
        ],
      ),
    );
  }
}

class _ModuleLivePanel extends StatelessWidget {
  const _ModuleLivePanel({
    required this.module,
    required this.dashboard,
  });

  final _TechnicalModule module;
  final PwfTechnicalServicesDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    switch (module.section) {
      case PwfTechnicalServiceSection.backup:
        return _BackupTable(backups: dashboard.backups);
      case PwfTechnicalServiceSection.maintenance:
        return _MaintenanceTable(windows: dashboard.maintenanceWindows);
      case PwfTechnicalServiceSection.health:
        return _HealthTable(checks: dashboard.healthChecks);
      case PwfTechnicalServiceSection.deployment:
        return _ReleaseTable(releases: dashboard.releases);
      case PwfTechnicalServiceSection.audit:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AuditTable(events: dashboard.auditEvents),
            const SizedBox(height: 14),
            _OperationsCenter(dashboard: dashboard),
          ],
        );
      case PwfTechnicalServiceSection.overview:
        return _RecentRequestsTable(requests: dashboard.requests);
    }
  }
}

class _TechnicalPanel extends StatelessWidget {
  const _TechnicalPanel({required this.panel});

  final _TechnicalPanelData panel;

  @override
  Widget build(BuildContext context) {
    return _WhitePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(panel.icon, color: const Color(0xFF0F4C81)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  panel.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...panel.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F4C81),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        height: 1.55,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRequestsTable extends StatelessWidget {
  const _RecentRequestsTable({required this.requests});

  final List<PwfTechnicalRequest> requests;

  @override
  Widget build(BuildContext context) {
    return _WhitePanel(
      title: 'آخر الطلبات التقنية',
      child: _SimpleRows(
        emptyLabel: 'لا توجد طلبات تقنية مسجلة بعد.',
        rows: requests
            .take(8)
            .map((item) => [
                  item.title,
                  '${item.serviceType} / ${item.actionType}',
                  '${item.status} / ${item.approvalStatus}',
                  item.riskLevel,
                ])
            .toList(growable: false),
        headers: const ['العنوان', 'النوع', 'الحالة', 'المخاطر'],
      ),
    );
  }
}

class _MaintenanceTable extends StatelessWidget {
  const _MaintenanceTable({required this.windows});

  final List<PwfMaintenanceWindow> windows;

  @override
  Widget build(BuildContext context) {
    return _WhitePanel(
      title: 'نوافذ الصيانة المسجلة',
      child: _SimpleRows(
        emptyLabel: 'لا توجد نوافذ صيانة مسجلة.',
        headers: const ['العنوان', 'الحالة', 'البداية', 'النهاية'],
        rows: windows
            .take(8)
            .map((item) => [
                  item.title,
                  item.status,
                  _formatDate(item.startsAt),
                  _formatDate(item.endsAt),
                ])
            .toList(growable: false),
      ),
    );
  }
}

class _BackupTable extends StatelessWidget {
  const _BackupTable({required this.backups});

  final List<PwfBackupRegistryEntry> backups;

  @override
  Widget build(BuildContext context) {
    return _WhitePanel(
      title: 'سجل النسخ الاحتياطي',
      child: _SimpleRows(
        emptyLabel: 'لا توجد سجلات backup موثقة بعد.',
        headers: const ['التسمية', 'النوع', 'الحالة', 'المزوّد'],
        rows: backups
            .take(8)
            .map((item) => [
                  item.backupLabel,
                  item.backupKind,
                  item.status,
                  item.provider ?? '-',
                ])
            .toList(growable: false),
      ),
    );
  }
}

class _HealthTable extends StatelessWidget {
  const _HealthTable({required this.checks});

  final List<PwfHealthCheck> checks;

  @override
  Widget build(BuildContext context) {
    return _WhitePanel(
      title: 'Health Checks',
      child: _SimpleRows(
        emptyLabel: 'لا توجد health checks بعد.',
        headers: const ['الفحص', 'المجموعة', 'الحالة', 'آخر تحديث'],
        rows: checks
            .take(12)
            .map((item) => [
                  item.label,
                  item.checkGroup,
                  item.status,
                  _formatDate(item.lastCheckedAt),
                ])
            .toList(growable: false),
      ),
    );
  }
}

class _ReleaseTable extends StatelessWidget {
  const _ReleaseTable({required this.releases});

  final List<PwfReleaseRecord> releases;

  @override
  Widget build(BuildContext context) {
    return _WhitePanel(
      title: 'Release Records',
      child: _SimpleRows(
        emptyLabel: 'لا توجد إصدارات مسجلة.',
        headers: const ['الإصدار', 'الحالة', 'commit', 'الرابط'],
        rows: releases
            .take(8)
            .map((item) => [
                  item.releaseTag,
                  item.status,
                  item.gitCommitHash ?? '-',
                  item.deployUrl ?? '-',
                ])
            .toList(growable: false),
      ),
    );
  }
}

class _AuditTable extends StatelessWidget {
  const _AuditTable({required this.events});

  final List<PwfAuditEvent> events;

  @override
  Widget build(BuildContext context) {
    return _WhitePanel(
      title: 'Audit Events',
      child: _SimpleRows(
        emptyLabel: 'لا توجد أحداث تدقيق بعد.',
        headers: const ['النوع', 'الشدة', 'الرسالة', 'التاريخ'],
        rows: events
            .take(12)
            .map((item) => [
                  item.eventType,
                  item.severity,
                  item.message,
                  _formatDate(item.createdAt),
                ])
            .toList(growable: false),
      ),
    );
  }
}

class _SimpleRows extends StatelessWidget {
  const _SimpleRows({
    required this.headers,
    required this.rows,
    required this.emptyLabel,
  });

  final List<String> headers;
  final List<List<String>> rows;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          emptyLabel,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
        columns: headers.map((h) => DataColumn(label: Text(h))).toList(),
        rows: rows
            .map(
              (row) => DataRow(
                cells: row
                    .map(
                      (cell) => DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 240),
                          child: Text(
                            cell,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _WhitePanel extends StatelessWidget {
  const _WhitePanel({this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _DeferredExecutionNotice extends StatelessWidget {
  const _DeferredExecutionNotice();

  @override
  Widget build(BuildContext context) {
    return _WhitePanel(
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF0F4C81)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'الدفعة أصبحت مرتبطة بـ Backend RPC وجداول تشغيل تقنية. لكنها لا تنفذ backup/restore أو إغلاق الموقع مباشرة. هذه الإجراءات تسجل كطلبات محكومة تحتاج اعتمادًا وسجل تدقيق وخطة rollback قبل التنفيذ الخارجي.',
              style: TextStyle(
                color: Color(0xFF334155),
                height: 1.6,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnicalMatrix extends StatelessWidget {
  const _TechnicalMatrix({required this.dashboard});

  final PwfTechnicalServicesDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final rows = [
      [
        'Backup',
        '${dashboard.backups.length} سجل',
        'طلب واعتماد',
        'لا export من Flutter'
      ],
      [
        'Maintenance',
        '${dashboard.maintenanceWindows.length} نافذة',
        'تخطيط وجدولة',
        'لا إغلاق تلقائي'
      ],
      [
        'Health',
        '${dashboard.healthChecks.length} فحص',
        'قراءة ومراقبة',
        'RPC آمن'
      ],
      [
        'Deployment',
        '${dashboard.releases.length} إصدار',
        'توثيق إصدار',
        'لا deploy من Flutter'
      ],
      [
        'Audit',
        '${dashboard.auditEvents.length} حدث',
        'سجل تدقيق',
        'لا حذف سجلات'
      ],
    ];

    return _WhitePanel(
      title: 'مصفوفة الخدمات التقنية الحية',
      child: _SimpleRows(
        headers: const ['الخدمة', 'المؤشر', 'نمط التشغيل', 'حد الأمان'],
        rows: rows,
        emptyLabel: 'لا توجد بيانات.',
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const _WhitePanel(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(22),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _WhitePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تعذر تحميل الخدمات التقنية',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Color(0xFFB91C1C))),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class _TechnicalModule {
  const _TechnicalModule({
    required this.section,
    required this.title,
    required this.shortTitle,
    required this.description,
    required this.route,
    required this.icon,
    required this.color,
    required this.tint,
    required this.statusLabel,
    required this.panels,
  });

  final PwfTechnicalServiceSection section;
  final String title;
  final String shortTitle;
  final String description;
  final String route;
  final IconData icon;
  final Color color;
  final Color tint;
  final String statusLabel;
  final List<_TechnicalPanelData> panels;
}

class _TechnicalPanelData {
  const _TechnicalPanelData({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;
}

const _technicalModules = <_TechnicalModule>[
  _TechnicalModule(
    section: PwfTechnicalServiceSection.overview,
    title: 'مركز الخدمات التقنية للمنصة',
    shortTitle: 'الخدمات التقنية',
    description:
        'بوابة تشغيل موحدة للنسخ الاحتياطي، الصيانة، صحة النظام، النشر، والسجلات. تعتمد على جداول وRPCs محكومة، لا على إجراءات عشوائية من الواجهة.',
    route: AppRoutes.adminTechnicalServices,
    icon: Icons.admin_panel_settings_rounded,
    color: Color(0xFF0F4C81),
    tint: Color(0xFFE8F0FE),
    statusLabel: 'لوحة تشغيل محكومة',
    panels: [],
  ),
  _TechnicalModule(
    section: PwfTechnicalServiceSection.backup,
    title: 'النسخ الاحتياطي والاستعادة',
    shortTitle: 'Backup',
    description:
        'إنشاء طلبات نسخ احتياطي محكومة، عرض سجل النسخ، وتوثيق سياسات retention دون تشغيل export أو restore من Flutter.',
    route: AppRoutes.adminTechnicalServicesBackup,
    icon: Icons.backup_rounded,
    color: Color(0xFF166534),
    tint: Color(0xFFE7F7EC),
    statusLabel: 'طلبات موثقة — التنفيذ الخارجي مؤجل للاعتماد',
    panels: [
      _TechnicalPanelData(
        title: 'نطاق النسخ الاحتياطي',
        icon: Icons.storage_rounded,
        items: [
          'قاعدة البيانات: Supabase/PostgreSQL وفق سياسة المنصة، لا عبر service_role في Flutter.',
          'المرفقات: تحتاج bucket inventory وسياسة retention منفصلة.',
          'كل طلب backup يسجل في platform_technical.technical_service_requests.',
        ],
      ),
      _TechnicalPanelData(
        title: 'ضوابط التشغيل',
        icon: Icons.rule_rounded,
        items: [
          'لا يتم تنفيذ export أو restore من الواجهة.',
          'أي استعادة تحتاج approval_status وخطة rollback.',
          'سجل backup_registry يحتفظ بالبيانات الوصفية فقط، لا ملفات النسخة.',
        ],
      ),
    ],
  ),
  _TechnicalModule(
    section: PwfTechnicalServiceSection.maintenance,
    title: 'وضع الصيانة ونوافذ التشغيل',
    shortTitle: 'Maintenance',
    description:
        'جدولة نوافذ صيانة ورسائل عامة ومجالات تأثير دون إغلاق تلقائي للموقع.',
    route: AppRoutes.adminTechnicalServicesMaintenance,
    icon: Icons.construction_rounded,
    color: Color(0xFF92400E),
    tint: Color(0xFFFFF7E6),
    statusLabel: 'جدولة حقيقية — التفعيل يحتاج اعتماد',
    panels: [
      _TechnicalPanelData(
        title: 'مكونات الصيانة',
        icon: Icons.event_available_rounded,
        items: [
          'نافذة صيانة بعنوان ورسالة عربية وبداية ونهاية.',
          'قائمة affected_surfaces مثل public/admin/awqaf/media/services.',
          'الحالة الافتراضية planned ولا تتحول active تلقائيًا.',
        ],
      ),
      _TechnicalPanelData(
        title: 'ضوابط التفعيل',
        icon: Icons.rule_rounded,
        items: [
          'تفعيل maintenance mode الفعلي يحتاج backend flag مستقل.',
          'يجب استثناء health routes وحسابات super_admin.',
          'كل نافذة تسجل audit event عند الإنشاء.',
        ],
      ),
    ],
  ),
  _TechnicalModule(
    section: PwfTechnicalServiceSection.health,
    title: 'صحة النظام ومؤشرات التشغيل',
    shortTitle: 'System Health',
    description:
        'تحديث وعرض مؤشرات صحة من catalog/RPCs مثل PostGIS، دوال الأصول، ودوال المواقع.',
    route: AppRoutes.adminTechnicalServicesHealth,
    icon: Icons.monitor_heart_rounded,
    color: Color(0xFF0F766E),
    tint: Color(0xFFE6FFFA),
    statusLabel: 'Health RPC آمن',
    panels: [
      _TechnicalPanelData(
        title: 'مؤشرات الصحة',
        icon: Icons.query_stats_rounded,
        items: [
          'PostGIS schema = extensions.',
          'rpc_waqf_asset_detail_v1 موجود.',
          'core location RPCs موجودة.',
          'platform_role_permission_map موجودة.',
        ],
      ),
      _TechnicalPanelData(
        title: 'حدود الفحص',
        icon: Icons.api_rounded,
        items: [
          'لا يغير بيانات الأعمال.',
          'يستخدم catalog checks وto_regprocedure/to_regclass.',
          'يعيد الحالة healthy/degraded/blocked.',
        ],
      ),
    ],
  ),
  _TechnicalModule(
    section: PwfTechnicalServiceSection.deployment,
    title: 'النشر والإصدارات',
    shortTitle: 'Deployment',
    description:
        'تسجيل إصدارات Vercel وFlutter Web وربطها بـ commit/build status دون تنفيذ نشر من اللوحة.',
    route: AppRoutes.adminTechnicalServicesDeployment,
    icon: Icons.rocket_launch_rounded,
    color: Color(0xFF6D28D9),
    tint: Color(0xFFF3E8FF),
    statusLabel: 'Release records',
    panels: [
      _TechnicalPanelData(
        title: 'بيئة مثبتة',
        icon: Icons.terminal_rounded,
        items: [
          'Flutter 3.44.1 stable، Dart 3.12.1، DevTools 2.57.0.',
          'طريقة التشغيل: flutter run -d chrome.',
          'طريقة البناء: flutter build web.',
          'الاستضافة: Vercel على https://palwakf.vercel.app/#/home.',
        ],
      ),
      _TechnicalPanelData(
        title: 'Release gate',
        icon: Icons.fact_check_rounded,
        items: [
          'تسجيل release_tag وgit_commit_hash وdeploy_url.',
          'لا يتم تنفيذ deploy من Flutter.',
          'أي production approval يحتاج Browser evidence وrollback record.',
        ],
      ),
    ],
  ),
  _TechnicalModule(
    section: PwfTechnicalServiceSection.audit,
    title: 'السجلات والتدقيق التقني',
    shortTitle: 'Audit & Logs',
    description:
        'عرض أحداث التدقيق التقنية المرتبطة بالطلبات والصيانة والصحة والنشر.',
    route: AppRoutes.adminTechnicalServicesAudit,
    icon: Icons.manage_search_rounded,
    color: Color(0xFFB91C1C),
    tint: Color(0xFFFEE2E2),
    statusLabel: 'Audit-first',
    panels: [
      _TechnicalPanelData(
        title: 'أنواع السجلات',
        icon: Icons.list_alt_rounded,
        items: [
          'technical_request_created.',
          'maintenance_window_created.',
          'release_record_created.',
          'health_snapshot_refreshed.',
        ],
      ),
      _TechnicalPanelData(
        title: 'سياسة السجلات',
        icon: Icons.account_tree_rounded,
        items: [
          'لا delete من الواجهة.',
          'كل سجل يرتبط بـ actor_user_id عندما يتوفر auth.uid().',
          'payload يحفظ تفاصيل غير سيادية فقط.',
        ],
      ),
    ],
  ),
];

_TechnicalModule _moduleFor(PwfTechnicalServiceSection section) {
  return _technicalModules.firstWhere((module) => module.section == section);
}

Color _statusColor(String status) {
  switch (status) {
    case 'healthy':
    case 'ready':
    case 'completed':
    case 'approved':
      return const Color(0xFF166534);
    case 'degraded':
    case 'pending':
    case 'requested':
    case 'planned':
      return const Color(0xFF92400E);
    case 'blocked':
    case 'failed':
    case 'rejected':
      return const Color(0xFFB91C1C);
    default:
      return const Color(0xFF64748B);
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '-';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _RequestDialogResult {
  const _RequestDialogResult({
    required this.title,
    required this.description,
    required this.actionType,
    required this.riskLevel,
  });

  final String title;
  final String description;
  final String actionType;
  final String riskLevel;
}

Future<_RequestDialogResult?> _showRequestDialog(
  BuildContext context, {
  required String title,
  required String defaultAction,
  required String defaultRisk,
}) async {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final actionController = TextEditingController(text: defaultAction);
  var risk = defaultRisk;

  return showDialog<_RequestDialogResult>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'عنوان الطلب'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                  minLines: 2,
                  maxLines: 4,
                ),
                TextField(
                  controller: actionController,
                  decoration: const InputDecoration(labelText: 'نوع الإجراء'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: risk,
                  decoration: const InputDecoration(labelText: 'مستوى المخاطر'),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('low')),
                    DropdownMenuItem(value: 'medium', child: Text('medium')),
                    DropdownMenuItem(value: 'high', child: Text('high')),
                    DropdownMenuItem(value: 'critical', child: Text('critical')),
                  ],
                  onChanged: (value) => setState(() => risk = value ?? risk),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                Navigator.pop(
                  context,
                  _RequestDialogResult(
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    actionType: actionController.text.trim(),
                    riskLevel: risk,
                  ),
                );
              },
              child: const Text('تسجيل'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MaintenanceDialogResult {
  const _MaintenanceDialogResult({
    required this.title,
    required this.messageAr,
    required this.startsAt,
    required this.endsAt,
    required this.affectedSurfaces,
  });

  final String title;
  final String messageAr;
  final DateTime startsAt;
  final DateTime endsAt;
  final List<String> affectedSurfaces;
}

Future<_MaintenanceDialogResult?> _showMaintenanceDialog(BuildContext context) {
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  final surfacesController = TextEditingController(text: 'public,admin,awqaf');
  final now = DateTime.now();
  final starts = now.add(const Duration(days: 1));
  final ends = starts.add(const Duration(hours: 2));

  return showDialog<_MaintenanceDialogResult>(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('جدولة نافذة صيانة'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'العنوان'),
              ),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'الرسالة العامة'),
                minLines: 2,
                maxLines: 4,
              ),
              TextField(
                controller: surfacesController,
                decoration: const InputDecoration(
                  labelText: 'المساحات المتأثرة مفصولة بفواصل',
                ),
              ),
              const SizedBox(height: 10),
              Text('سيتم ضبط البداية: ${_formatDate(starts)} والنهاية: ${_formatDate(ends)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              Navigator.pop(
                context,
                _MaintenanceDialogResult(
                  title: titleController.text.trim(),
                  messageAr: messageController.text.trim(),
                  startsAt: starts,
                  endsAt: ends,
                  affectedSurfaces: surfacesController.text
                      .split(',')
                      .map((item) => item.trim())
                      .where((item) => item.isNotEmpty)
                      .toList(growable: false),
                ),
              );
            },
            child: const Text('تسجيل'),
          ),
        ],
      ),
    ),
  );
}

class _ReleaseDialogResult {
  const _ReleaseDialogResult({
    required this.releaseTag,
    required this.gitCommitHash,
    required this.deployUrl,
    required this.status,
  });

  final String releaseTag;
  final String gitCommitHash;
  final String deployUrl;
  final String status;
}

Future<_ReleaseDialogResult?> _showReleaseDialog(BuildContext context) {
  final tagController = TextEditingController(text: 'vercel-web-${DateTime.now().year}');
  final commitController = TextEditingController(text: '8729fcd');
  final urlController = TextEditingController(text: 'https://palwakf.vercel.app/#/home');
  var status = 'recorded';

  return showDialog<_ReleaseDialogResult>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تسجيل Release Record'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tagController,
                  decoration: const InputDecoration(labelText: 'Release tag'),
                ),
                TextField(
                  controller: commitController,
                  decoration: const InputDecoration(labelText: 'Git commit'),
                ),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(labelText: 'Deploy URL'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'الحالة'),
                  items: const [
                    DropdownMenuItem(value: 'recorded', child: Text('recorded')),
                    DropdownMenuItem(value: 'verified', child: Text('verified')),
                    DropdownMenuItem(value: 'failed', child: Text('failed')),
                  ],
                  onChanged: (value) => setState(() => status = value ?? status),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  _ReleaseDialogResult(
                    releaseTag: tagController.text.trim(),
                    gitCommitHash: commitController.text.trim(),
                    deployUrl: urlController.text.trim(),
                    status: status,
                  ),
                );
              },
              child: const Text('تسجيل'),
            ),
          ],
        ),
      ),
    ),
  );
}