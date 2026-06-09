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
import 'pwf_sis_rollout_evidence_page.dart';
import 'pwf_sis_wave2_media_inventory_page.dart';

class PwfSisWave2ScopePage extends StatelessWidget {
  const PwfSisWave2ScopePage({super.key});

  static const routePath = '/admin/platform/design-system/wave-2-scope';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 720;

    return Scaffold(
      appBar: AppBar(title: const Text('PWF-SIS — قرار Wave 2')),
      body: ListView(
        padding: EdgeInsets.all(compact ? 16 : 24),
        children: [
          PwfSisSystemHero(
            kicker: 'Controlled Wave 2 Scope',
            title: 'قرار نطاق Wave 2 واختيار المرشح التشغيلي',
            description:
                'هذه الصفحة لا تعمم PWF-SIS على كل الأنظمة. هي تقفل نطاق موجة واحدة صغيرة، تختار مرشحًا منخفض المخاطر، وتحدد أدلة responsive/RBAC/console قبل أي تطبيق لاحق.',
            actions: [
              FilledButton.icon(
                onPressed: () =>
                    context.go(PwfSisRolloutEvidencePage.routePath),
                icon: const Icon(Icons.fact_check_rounded),
                label: const Text('مصفوفة الأدلة'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go(PwfSisClosureReviewPage.routePath),
                icon: const Icon(Icons.assignment_turned_in_rounded),
                label: const Text('فحص الإغلاق'),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    context.go(PwfSisWave2MediaInventoryPage.routePath),
                icon: const Icon(Icons.route_rounded),
                label: const Text('جرد مسارات Media'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const PwfSisResponsiveWrapGrid(
            minItemWidth: 220,
            children: [
              PwfSisMetricCard(
                label: 'مرشح مختار',
                value: 'Media',
                badge: 'wave 2',
                tone: PwfSisStatusTone.info,
              ),
              PwfSisMetricCard(
                label: 'نطاق التنفيذ',
                value: 'read-only',
                badge: 'visual',
                tone: PwfSisStatusTone.restricted,
              ),
              PwfSisMetricCard(
                label: 'إنتاج',
                value: 'غير معتمد',
                badge: 'gate',
                tone: PwfSisStatusTone.danger,
              ),
              PwfSisMetricCard(
                label: 'Database Wave B',
                value: 'محفوظ',
                badge: 'not run',
                tone: PwfSisStatusTone.review,
              ),
            ],
          ),
          const SizedBox(height: 16),
          PwfSisAdaptiveWorkspace(
            primary: const _CandidateSelectionCard(),
            contextPanel: const _Wave2DecisionPanel(),
            mobileTabLabels: const ['المرشحون', 'القرار', 'المخاطر'],
            mobileTabs: const [
              _CandidateSelectionCard(),
              _Wave2DecisionPanel(),
              _RiskMatrixCard(),
            ],
          ),
          const SizedBox(height: 16),
          const _RiskMatrixCard(),
          const SizedBox(height: 16),
          const _EvidenceExpansionCard(),
          const SizedBox(height: 16),
          const _ProductionReassessmentCard(),
        ],
      ),
    );
  }
}

class _Wave2DecisionPanel extends StatelessWidget {
  const _Wave2DecisionPanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PwfSisNotice(
          title: 'قرار Wave 2',
          message:
              'اختيار Media Center كمرشح Wave 2 فقط، وبنطاق read-only visual pilot. لا تعديل workflow، لا publish، لا archive، ولا delete.',
          tone: PwfSisStatusTone.info,
        ),
        SizedBox(height: 12),
        PwfSisNotice(
          title: 'منع التعميم الجماعي',
          message:
              'Cases/Billing/Mustakshif/Tasks/Services مؤجلة أو محجوبة حتى تقدم أدلة مستقلة لكل نظام.',
          tone: PwfSisStatusTone.review,
        ),
        SizedBox(height: 12),
        PwfSisNotice(
          title: 'Production Gate',
          message:
              'لا اعتماد إنتاجي. Wave 2 جاهزة للتخطيط وUAT فقط، ولا تطبق على runtime قبل نتيجة analyzer/browser/RBAC/console.',
          tone: PwfSisStatusTone.danger,
        ),
      ],
    );
  }
}

class _CandidateSelectionCard extends StatelessWidget {
  const _CandidateSelectionCard();

  @override
  Widget build(BuildContext context) {
    return const PwfSisSectionCard(
      title: 'Candidate Systems Selection',
      subtitle:
          'اختيار نظام واحد فقط لموجة Wave 2؛ لا يوجد rollout شامل على كل الأنظمة.',
      child: _GateTable(items: PwfSisRolloutPlan.wave2CandidateSystems),
    );
  }
}

class _RiskMatrixCard extends StatelessWidget {
  const _RiskMatrixCard();

  @override
  Widget build(BuildContext context) {
    return const PwfSisSectionCard(
      title: 'Rollout Risk Matrix',
      subtitle:
          'المخاطر الحاكمة قبل أي تطبيق مرئي على Media Center أو أي مرشح لاحق.',
      child: _GateTable(items: PwfSisRolloutPlan.wave2RiskMatrix),
    );
  }
}

class _EvidenceExpansionCard extends StatelessWidget {
  const _EvidenceExpansionCard();

  @override
  Widget build(BuildContext context) {
    return const PwfSisSectionCard(
      title: 'Responsive / Role Evidence Expansion',
      subtitle:
          'توسيع الأدلة المطلوبة من PWF-SIS العام إلى أدلة مستقلة للمرشح المختار.',
      child: _GateTable(items: PwfSisRolloutPlan.wave2EvidenceExpansion),
    );
  }
}

class _ProductionReassessmentCard extends StatelessWidget {
  const _ProductionReassessmentCard();

  @override
  Widget build(BuildContext context) {
    return const PwfSisSectionCard(
      title: 'Production Gate Reassessment',
      subtitle:
          'إعادة تقييم البوابة الإنتاجية بعد إغلاق Wave 0 وWave 1 كـ pilot فقط.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PwfSisNotice(
            title: 'ما هو معتمد',
            message:
                'Wave 0 مغلقة لمسارات Platform Design System، وWave 1 مغلقة كـ Awqaf read-only visual pilot فقط.',
            tone: PwfSisStatusTone.success,
          ),
          SizedBox(height: 12),
          PwfSisNotice(
            title: 'ما هو مسموح الآن',
            message:
                'تجهيز Media Center كمرشح Wave 2 بصفحات read-only visual pilot وأدلة UAT، دون تفعيل إنتاجي.',
            tone: PwfSisStatusTone.info,
          ),
          SizedBox(height: 12),
          PwfSisNotice(
            title: 'ما هو ممنوع',
            message:
                'لا تعميم على الأنظمة، لا تعديل waqf_assets، لا Database Wave B، لا publish/rollback حقيقي، ولا إنتاج قبل أدلة مستقلة.',
            tone: PwfSisStatusTone.danger,
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
          DataColumn(label: Text('المجال')),
          DataColumn(label: Text('الدليل / السبب')),
          DataColumn(label: Text('المالك')),
          DataColumn(label: Text('الحالة')),
          DataColumn(label: Text('سياسة المنع')),
        ],
        rows: [
          for (final item in items)
            DataRow(
              cells: [
                DataCell(SizedBox(width: 220, child: Text(item.area))),
                DataCell(
                  SizedBox(width: 340, child: Text(item.requiredEvidenceAr)),
                ),
                DataCell(SizedBox(width: 190, child: Text(item.ownerAr))),
                DataCell(
                  PwfSisStatusBadge(
                    label: item.status.labelAr,
                    tone: _toneFor(item.status),
                  ),
                ),
                DataCell(
                  SizedBox(width: 340, child: Text(item.blockerPolicyAr)),
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
