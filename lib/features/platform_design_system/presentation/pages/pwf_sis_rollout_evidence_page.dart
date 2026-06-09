import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/palwakf_sis/pwf_sis_adaptive_workspace.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_metric_card.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_notice.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_responsive_wrap_grid.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_section_card.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_status_badge.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_system_hero.dart';
import '../../application/pwf_sis_rollout_plan.dart';
import 'pwf_sis_closure_review_page.dart';

class PwfSisRolloutEvidencePage extends StatelessWidget {
  const PwfSisRolloutEvidencePage({super.key});

  static const routePath = '/admin/platform/design-system/rollout-evidence';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 720;

    return Scaffold(
      appBar: AppBar(title: const Text('PWF-SIS — خطة التعميم والأدلة')),
      body: ListView(
        padding: EdgeInsets.all(compact ? 16 : 24),
        children: [
          PwfSisSystemHero(
            kicker: 'Controlled Rollout',
            title: 'تعميم PWF-SIS بشكل مضبوط لا جماعي',
            description:
                'هذه الصفحة تحول PWF-SIS من معرض مكونات إلى برنامج تعميم تدريجي: Pilot، أدلة إنتاج، تباين/rollback، responsive، وصلاحيات.',
            actions: [
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.fact_check_rounded),
                label: const Text('تجهيز أدلة UAT'),
              ),
              FilledButton.icon(
                onPressed: () => context.go(PwfSisClosureReviewPage.routePath),
                icon: const Icon(Icons.rule_folder_rounded),
                label: const Text('فحص الإغلاق'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.block_rounded),
                label: const Text('الإنتاج غير معتمد'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const PwfSisResponsiveWrapGrid(
            minItemWidth: 230,
            children: [
              PwfSisMetricCard(
                label: 'نمط التعميم',
                value: 'موجات',
                badge: 'controlled',
                tone: PwfSisStatusTone.info,
              ),
              PwfSisMetricCard(
                label: 'Pilot أولي',
                value: 'Awqaf',
                badge: 'pilot',
                tone: PwfSisStatusTone.review,
              ),
              PwfSisMetricCard(
                label: 'Database Wave B',
                value: 'محفوظ',
                badge: 'not run',
                tone: PwfSisStatusTone.restricted,
              ),
              PwfSisMetricCard(
                label: 'Production',
                value: 'غير معتمد',
                badge: 'gate',
                tone: PwfSisStatusTone.danger,
              ),
            ],
          ),
          const SizedBox(height: 16),
          PwfSisAdaptiveWorkspace(
            primary: const _RolloutWavesCard(),
            contextPanel: const _RolloutDecisionPanel(),
            mobileTabLabels: const ['الموجات', 'القرار', 'الأدلة'],
            mobileTabs: const [
              _RolloutWavesCard(),
              _RolloutDecisionPanel(),
              _EvidenceMatrixCard(),
            ],
          ),
          const SizedBox(height: 16),
          const _EvidenceMatrixCard(),
          const SizedBox(height: 16),
          const _RoleValidationCard(),
          const SizedBox(height: 16),
          const _ResponsiveEvidenceChecklist(),
        ],
      ),
    );
  }
}

class _RolloutWavesCard extends StatelessWidget {
  const _RolloutWavesCard();

  @override
  Widget build(BuildContext context) {
    return PwfSisSectionCard(
      title: 'موجات التعميم',
      subtitle: 'لا تعميم شامل قبل نجاح pilot وUAT لكل موجة.',
      child: _GateTable(items: PwfSisRolloutPlan.rolloutWaves),
    );
  }
}

class _EvidenceMatrixCard extends StatelessWidget {
  const _EvidenceMatrixCard();

  @override
  Widget build(BuildContext context) {
    return const PwfSisSectionCard(
      title: 'مصفوفة أدلة الإنتاج',
      subtitle: 'الأدلة المطلوبة قبل أي production approval.',
      child: _GateTable(items: PwfSisRolloutPlan.productionEvidence),
    );
  }
}

class _RoleValidationCard extends StatelessWidget {
  const _RoleValidationCard();

  @override
  Widget build(BuildContext context) {
    return const PwfSisSectionCard(
      title: 'Role-Based UI Validation',
      subtitle: 'تثبيت السلوك حسب الدور قبل التعميم.',
      child: _GateTable(items: PwfSisRolloutPlan.roleValidation),
    );
  }
}

class _RolloutDecisionPanel extends StatelessWidget {
  const _RolloutDecisionPanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PwfSisNotice(
          title: 'قرار PWF-SIS-05',
          message:
              'هذه الدفعة تخطط وتصلب pilot وتجهز الأدلة، لكنها لا تعتمد الإنتاج ولا تنفذ Database Wave B.',
          tone: PwfSisStatusTone.review,
        ),
        SizedBox(height: 12),
        PwfSisNotice(
          title: 'حدود التعميم',
          message:
              'Wave 1 محصور في Awqaf Pilot المرئي. لا ربط تشغيلي مع أوقاف سيستم الفعلي قبل baseline الخاص به.',
          tone: PwfSisStatusTone.info,
        ),
        SizedBox(height: 12),
        PwfSisNotice(
          title: 'Rollback إلزامي',
          message:
              'أي override بصري منشور يحتاج versioning، rollback، وcontrast gate. الفشل في أي منها blocker.',
          tone: PwfSisStatusTone.danger,
        ),
      ],
    );
  }
}

class _ResponsiveEvidenceChecklist extends StatelessWidget {
  const _ResponsiveEvidenceChecklist();

  @override
  Widget build(BuildContext context) {
    final cards = const [
      _EvidenceTile(
        title: 'Desktop 1440+',
        body: 'Component Gallery + Bridge + Rollout + Awqaf Pilot.',
        icon: Icons.desktop_windows_rounded,
      ),
      _EvidenceTile(
        title: 'Tablet 1024',
        body: 'تحقق من grid wrapping وعدم ظهور overflow أفقي.',
        icon: Icons.tablet_mac_rounded,
      ),
      _EvidenceTile(
        title: 'Mobile 390',
        body: 'تحول workspace إلى tabs، والجداول داخل scroll أفقي مضبوط.',
        icon: Icons.phone_android_rounded,
      ),
      _EvidenceTile(
        title: 'Console Review',
        body: 'لا render exceptions ولا hit-test layout errors.',
        icon: Icons.terminal_rounded,
      ),
    ];

    return PwfSisSectionCard(
      title: 'Responsive Browser Evidence',
      subtitle: 'نقاط تصوير إلزامية قبل rollout لأي نظام جديد.',
      child: PwfSisResponsiveWrapGrid(minItemWidth: 220, children: cards),
    );
  }
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GateTable extends StatelessWidget {
  const _GateTable({required this.items});

  final List<PwfSisRolloutGate> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('المجال')),
          DataColumn(label: Text('الدليل المطلوب')),
          DataColumn(label: Text('المالك')),
          DataColumn(label: Text('الحالة')),
          DataColumn(label: Text('سياسة المنع')),
        ],
        rows: [
          for (final item in items)
            DataRow(
              cells: [
                DataCell(SizedBox(width: 210, child: Text(item.area))),
                DataCell(
                  SizedBox(width: 310, child: Text(item.requiredEvidenceAr)),
                ),
                DataCell(SizedBox(width: 170, child: Text(item.ownerAr))),
                DataCell(
                  PwfSisStatusBadge(
                    label: item.status.labelAr,
                    tone: _toneFor(item.status),
                  ),
                ),
                DataCell(
                  SizedBox(width: 300, child: Text(item.blockerPolicyAr)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  PwfSisStatusTone _toneFor(PwfSisRolloutStatus status) {
    switch (status) {
      case PwfSisRolloutStatus.preserved:
        return PwfSisStatusTone.restricted;
      case PwfSisRolloutStatus.evidenceAccepted:
        return PwfSisStatusTone.success;
      case PwfSisRolloutStatus.readyForUat:
        return PwfSisStatusTone.info;
      case PwfSisRolloutStatus.pendingEvidence:
        return PwfSisStatusTone.review;
      case PwfSisRolloutStatus.conditionallyApproved:
        return PwfSisStatusTone.info;
      case PwfSisRolloutStatus.blocked:
      case PwfSisRolloutStatus.notApproved:
        return PwfSisStatusTone.danger;
    }
  }
}
