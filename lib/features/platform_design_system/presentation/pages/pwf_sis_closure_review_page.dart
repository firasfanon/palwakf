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
import 'pwf_sis_rollout_evidence_page.dart';

class PwfSisClosureReviewPage extends StatelessWidget {
  const PwfSisClosureReviewPage({super.key});

  static const routePath = '/admin/platform/design-system/closure-review';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 720;

    return Scaffold(
      appBar: AppBar(title: const Text('PWF-SIS — فحص إغلاق المسار')),
      body: ListView(
        padding: EdgeInsets.all(compact ? 16 : 24),
        children: [
          PwfSisSystemHero(
            kicker: 'N2.45 Closure Review',
            title: 'فحص ما تبقى قبل إغلاق مسار PWF-SIS',
            description:
                'هذه الصفحة تجمع قرار Wave 1 Pilot والأدلة المقبولة والمتبقية. الهدف إغلاق المسار بقرار حاكم لا بتقدير عام.',
            actions: [
              FilledButton.icon(
                onPressed: () =>
                    context.go(PwfSisRolloutEvidencePage.routePath),
                icon: const Icon(Icons.fact_check_rounded),
                label: const Text('العودة لمصفوفة الأدلة'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.lock_outline_rounded),
                label: const Text('الإنتاج غير معتمد'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const PwfSisResponsiveWrapGrid(
            minItemWidth: 230,
            children: [
              PwfSisMetricCard(
                label: 'أدلة مقبولة',
                value: '3',
                badge: 'accepted',
                tone: PwfSisStatusTone.success,
              ),
              PwfSisMetricCard(
                label: 'أدلة متبقية',
                value: '3',
                badge: 'pending',
                tone: PwfSisStatusTone.review,
              ),
              PwfSisMetricCard(
                label: 'Wave 1 Pilot',
                value: 'مشروط',
                badge: 'pilot',
                tone: PwfSisStatusTone.info,
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
            primary: const _ClosureTableCard(),
            contextPanel: const _DecisionPanel(),
            mobileTabLabels: const ['الإغلاق', 'القرار', 'الأدوار'],
            mobileTabs: const [
              _ClosureTableCard(),
              _DecisionPanel(),
              _RoleEvidenceCard(),
            ],
          ),
          const SizedBox(height: 16),
          const _RoleEvidenceCard(),
          const SizedBox(height: 16),
          const _RemainingBeforeCloseCard(),
        ],
      ),
    );
  }
}

class _ClosureTableCard extends StatelessWidget {
  const _ClosureTableCard();

  @override
  Widget build(BuildContext context) {
    return const PwfSisSectionCard(
      title: 'مصفوفة إغلاق المسار',
      subtitle: 'الأدلة المقبولة والمتبقية في N2.45.',
      child: _ClosureTable(items: PwfSisRolloutPlan.closureItems),
    );
  }
}

class _RoleEvidenceCard extends StatelessWidget {
  const _RoleEvidenceCard();

  @override
  Widget build(BuildContext context) {
    return const PwfSisSectionCard(
      title: 'Role-Based UI Validation',
      subtitle:
          'لا اعتماد Wave 1 خارج pilot قبل إغلاق platform-admin وrestricted evidence.',
      child: _GateTable(items: PwfSisRolloutPlan.roleValidation),
    );
  }
}

class _DecisionPanel extends StatelessWidget {
  const _DecisionPanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PwfSisNotice(
          title: 'قرار Wave 0',
          message:
              'Wave 0 مقبولة داخل Platform Design System فقط: gallery/bridge/rollout/closure كمسارات إدارية.',
          tone: PwfSisStatusTone.success,
        ),
        SizedBox(height: 12),
        PwfSisNotice(
          title: 'قرار Wave 1 Pilot',
          message:
              'اعتماد مشروط لـ Awqaf Pilot كـ read-only visual pilot فقط. لا دمج تشغيلي ولا تعديل waqf_assets.',
          tone: PwfSisStatusTone.review,
        ),
        SizedBox(height: 12),
        PwfSisNotice(
          title: 'لم يغلق المسار كاملًا بعد',
          message:
              'المتبقي: mobile/tablet evidence، restricted-role evidence، ونص console review بعد فتح الصفحات الأربع.',
          tone: PwfSisStatusTone.danger,
        ),
      ],
    );
  }
}

class _RemainingBeforeCloseCard extends StatelessWidget {
  const _RemainingBeforeCloseCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      _RemainingTile(
        title: 'Mobile 390px',
        body: 'افتح الصفحات الأربع وتأكد من tabs/scroll وعدم وجود overflow.',
        icon: Icons.phone_android_rounded,
      ),
      _RemainingTile(
        title: 'Tablet 1024px',
        body: 'تحقق من التفاف البطاقات، الجداول، وعدم كسر shell الجانبي.',
        icon: Icons.tablet_mac_rounded,
      ),
      _RemainingTile(
        title: 'Restricted role',
        body:
            'مستخدم محدود لا يرى أدوات platform governance ولا يحصل على data leakage.',
        icon: Icons.lock_person_rounded,
      ),
      _RemainingTile(
        title: 'Console review',
        body:
            'سجل نصي يؤكد عدم وجود render/layout/hit-test exceptions بعد فتح الصفحات.',
        icon: Icons.terminal_rounded,
      ),
    ];

    return PwfSisSectionCard(
      title: 'المتبقي قبل الإغلاق النهائي',
      subtitle:
          'هذه العناصر تمنع إغلاق PWF-SIS كمسار كامل، لكنها لا تمنع حفظ baseline الحالي.',
      child: PwfSisResponsiveWrapGrid(minItemWidth: 220, children: items),
    );
  }
}

class _RemainingTile extends StatelessWidget {
  const _RemainingTile({
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

class _ClosureTable extends StatelessWidget {
  const _ClosureTable({required this.items});

  final List<PwfSisClosureItem> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('المجال')),
          DataColumn(label: Text('الدليل')),
          DataColumn(label: Text('الحالة')),
          DataColumn(label: Text('القرار')),
        ],
        rows: [
          for (final item in items)
            DataRow(
              cells: [
                DataCell(SizedBox(width: 210, child: Text(item.area))),
                DataCell(SizedBox(width: 330, child: Text(item.evidenceAr))),
                DataCell(
                  PwfSisStatusBadge(
                    label: item.status.labelAr,
                    tone: _toneFor(item.status),
                  ),
                ),
                DataCell(SizedBox(width: 320, child: Text(item.decisionAr))),
              ],
            ),
        ],
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
          DataColumn(label: Text('الدور')),
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
