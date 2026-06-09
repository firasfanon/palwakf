import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/palwakf_sis/pwf_sis_metric_card.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_notice.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_responsive_wrap_grid.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_section_card.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_status_badge.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_system_hero.dart';
import '../../../../app/routing/app_routes.dart';
import '../../application/pwf_sis_rollout_plan.dart';
import 'pwf_sis_rollout_evidence_page.dart';
import 'pwf_sis_wave2_scope_page.dart';

class PwfSisWave2MediaInventoryPage extends StatelessWidget {
  const PwfSisWave2MediaInventoryPage({super.key});

  static const routePath =
      '/admin/platform/design-system/wave-2-media-inventory';

  static const _routes = <_MediaRouteInventoryItem>[
    _MediaRouteInventoryItem(
      labelAr: 'لوحة المركز الإعلامي',
      route: AppRoutes.adminMediaCenter,
      ownerAr: 'Media Center Owner',
      riskAr: 'متوسط',
      decisionAr: 'مرشح read-only visual pilot',
      tone: PwfSisStatusTone.info,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'الأخبار',
      route: AppRoutes.adminMediaCenterNews,
      ownerAr: 'Editorial Desk',
      riskAr: 'متوسط',
      decisionAr: 'فحص عرض فقط؛ لا publish/delete',
      tone: PwfSisStatusTone.review,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'الإعلانات',
      route: AppRoutes.adminMediaCenterAnnouncements,
      ownerAr: 'Editorial Desk',
      riskAr: 'متوسط',
      decisionAr: 'فحص عرض فقط؛ لا publish/delete',
      tone: PwfSisStatusTone.review,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'الأنشطة',
      route: AppRoutes.adminMediaCenterActivities,
      ownerAr: 'Media Operations',
      riskAr: 'متوسط',
      decisionAr: 'read-only visual pilot',
      tone: PwfSisStatusTone.info,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'الفعاليات',
      route: AppRoutes.adminMediaCenterEvents,
      ownerAr: 'Media Operations',
      riskAr: 'متوسط',
      decisionAr: 'read-only visual pilot',
      tone: PwfSisStatusTone.info,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'الصور',
      route: AppRoutes.adminMediaCenterPhotos,
      ownerAr: 'Media Library',
      riskAr: 'منخفض',
      decisionAr: 'أفضل مرشح لتجربة visual-only',
      tone: PwfSisStatusTone.success,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'الفيديوهات',
      route: AppRoutes.adminMediaCenterVideos,
      ownerAr: 'Media Library',
      riskAr: 'منخفض',
      decisionAr: 'أفضل مرشح لتجربة visual-only',
      tone: PwfSisStatusTone.success,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'الأخبار العاجلة',
      route: AppRoutes.adminMediaCenterBreakingNews,
      ownerAr: 'Editorial Desk',
      riskAr: 'مرتفع',
      decisionAr: 'مؤجل؛ حساسية نشر فورية',
      tone: PwfSisStatusTone.danger,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'خطب الجمعة',
      route: AppRoutes.adminMediaCenterFridaySermons,
      ownerAr: 'Content Desk',
      riskAr: 'متوسط',
      decisionAr: 'فحص عرض فقط',
      tone: PwfSisStatusTone.review,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'السلايدر / الهيرو',
      route: AppRoutes.adminMediaCenterHeroSlider,
      ownerAr: 'Homepage Owner',
      riskAr: 'مرتفع',
      decisionAr: 'مؤجل؛ يؤثر على الواجهة العامة',
      tone: PwfSisStatusTone.danger,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'الاجتماعيات',
      route: AppRoutes.adminMediaCenterSocialPosts,
      ownerAr: 'Social Desk',
      riskAr: 'متوسط',
      decisionAr: 'read-only visual pilot',
      tone: PwfSisStatusTone.info,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'البيانات الصحفية',
      route: AppRoutes.adminMediaCenterPressReleases,
      ownerAr: 'Official Communications',
      riskAr: 'مرتفع',
      decisionAr: 'مؤجل؛ محتوى رسمي حساس',
      tone: PwfSisStatusTone.danger,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'التصريحات الرسمية',
      route: AppRoutes.adminMediaCenterOfficialStatements,
      ownerAr: 'Official Communications',
      riskAr: 'مرتفع',
      decisionAr: 'مؤجل؛ محتوى رسمي حساس',
      tone: PwfSisStatusTone.danger,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'حملات التوعية',
      route: AppRoutes.adminMediaCenterAwarenessCampaigns,
      ownerAr: 'Campaigns Owner',
      riskAr: 'متوسط',
      decisionAr: 'read-only visual pilot بعد evidence',
      tone: PwfSisStatusTone.review,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'تقويم التحرير',
      route: AppRoutes.adminMediaCenterEditorialCalendar,
      ownerAr: 'Editorial Workflow Owner',
      riskAr: 'مرتفع',
      decisionAr: 'مؤجل؛ workflow scheduling',
      tone: PwfSisStatusTone.danger,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'مكتبة الوسائط',
      route: AppRoutes.adminMediaCenterMediaLibrary,
      ownerAr: 'Media Library',
      riskAr: 'منخفض',
      decisionAr: 'مرشح آمن للعرض فقط',
      tone: PwfSisStatusTone.success,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'مرصد حماية المقدسات',
      route: AppRoutes.adminMediaCenterSanctitiesObservatory,
      ownerAr: 'Sanctities Observatory Owner',
      riskAr: 'مرتفع',
      decisionAr: 'مؤجل؛ سياق حساس',
      tone: PwfSisStatusTone.danger,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'تقارير إعلامية',
      route: AppRoutes.adminMediaCenterMediaReports,
      ownerAr: 'Reporting Owner',
      riskAr: 'متوسط',
      decisionAr: 'read-only visual pilot بعد evidence',
      tone: PwfSisStatusTone.review,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'تغطيات إعلامية',
      route: AppRoutes.adminMediaCenterMediaCoverage,
      ownerAr: 'Coverage Owner',
      riskAr: 'متوسط',
      decisionAr: 'read-only visual pilot بعد evidence',
      tone: PwfSisStatusTone.review,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'قصص أثر الوقف',
      route: AppRoutes.adminMediaCenterWaqfImpactStories,
      ownerAr: 'Waqf Impact Content Owner',
      riskAr: 'متوسط',
      decisionAr: 'read-only visual pilot بعد evidence',
      tone: PwfSisStatusTone.review,
    ),
    _MediaRouteInventoryItem(
      labelAr: 'حوكمة المركز الإعلامي',
      route: AppRoutes.adminMediaCenterGovernance,
      ownerAr: 'Platform Governance',
      riskAr: 'منخفض',
      decisionAr: 'مناسب كمرجع policy-only',
      tone: PwfSisStatusTone.success,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720;
    final total = _routes.length;
    final safe = _routes
        .where((item) => item.tone == PwfSisStatusTone.success)
        .length;
    final deferred = _routes
        .where((item) => item.tone == PwfSisStatusTone.danger)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('PWF-SIS — جرد مسارات Media Center')),
      body: ListView(
        padding: EdgeInsets.all(compact ? 16 : 24),
        children: [
          PwfSisSystemHero(
            kicker: 'Wave 2 Evidence Intake',
            title: 'جرد مسارات المركز الإعلامي قبل قرار التنفيذ',
            description:
                'هذه الصفحة تجمع مسارات Media Center وتفصل بين المرشحين الآمنين بصريًا والمسارات المؤجلة. لا يوجد تطبيق فعلي لـ PWF-SIS على runtime الإعلامي في هذه الدفعة.',
            actions: [
              FilledButton.icon(
                onPressed: () => context.go(PwfSisWave2ScopePage.routePath),
                icon: const Icon(Icons.rule_folder_rounded),
                label: const Text('قرار Wave 2'),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    context.go(PwfSisRolloutEvidencePage.routePath),
                icon: const Icon(Icons.fact_check_rounded),
                label: const Text('مصفوفة الأدلة'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PwfSisResponsiveWrapGrid(
            minItemWidth: 220,
            children: [
              PwfSisMetricCard(
                label: 'مسارات مفهرسة',
                value: '$total',
                badge: 'inventory',
                tone: PwfSisStatusTone.info,
              ),
              PwfSisMetricCard(
                label: 'مرشحون آمنون مبدئيًا',
                value: '$safe',
                badge: 'visual-only',
                tone: PwfSisStatusTone.success,
              ),
              PwfSisMetricCard(
                label: 'مؤجلون بسبب المخاطر',
                value: '$deferred',
                badge: 'blocked/defer',
                tone: PwfSisStatusTone.danger,
              ),
              const PwfSisMetricCard(
                label: 'قرار التنفيذ',
                value: 'تأجيل',
                badge: 'defer',
                tone: PwfSisStatusTone.review,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const PwfSisSectionCard(
            title: 'قرار N2.51',
            subtitle:
                'استيعاب الأدلة والجرد لا يكفيان لتطبيق Wave 2 على Media Center runtime.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PwfSisNotice(
                  title: 'قرار التنفيذ',
                  message:
                      'Wave 2 مؤجلة للتنفيذ. يسمح فقط بتجهيز Pilot visual/read-only منفصل للمركز الإعلامي بعد أدلة analyzer/browser/role/console خاصة بـ Media Center.',
                  tone: PwfSisStatusTone.review,
                ),
                SizedBox(height: 12),
                PwfSisNotice(
                  title: 'الحدود الحاكمة',
                  message:
                      'لا publish، لا archive، لا delete، لا تعديل workflow، لا تغيير public visibility، ولا نقل جداول media_center ضمن هذه الدفعة.',
                  tone: PwfSisStatusTone.danger,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InventoryTable(routes: _routes),
          const SizedBox(height: 16),
          const PwfSisSectionCard(
            title: 'أدلة التنفيذ المطلوبة قبل N2.52',
            subtitle: 'لا يبدأ التطبيق الفعلي إلا بعد هذه الأدلة.',
            child: _GateTable(items: PwfSisRolloutPlan.wave2ExecutionEvidence),
          ),
        ],
      ),
    );
  }
}

class _InventoryTable extends StatelessWidget {
  const _InventoryTable({required this.routes});

  final List<_MediaRouteInventoryItem> routes;

  @override
  Widget build(BuildContext context) {
    return PwfSisSectionCard(
      title: 'Media Center Route Inventory',
      subtitle: 'جرد مسارات GoRouter/Media Center حسب المخاطر وحدود Wave 2.',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('المسار')),
            DataColumn(label: Text('الاسم')),
            DataColumn(label: Text('المالك')),
            DataColumn(label: Text('الخطر')),
            DataColumn(label: Text('القرار')),
          ],
          rows: [
            for (final item in routes)
              DataRow(
                cells: [
                  DataCell(SizedBox(width: 280, child: Text(item.route))),
                  DataCell(SizedBox(width: 180, child: Text(item.labelAr))),
                  DataCell(SizedBox(width: 220, child: Text(item.ownerAr))),
                  DataCell(
                    PwfSisStatusBadge(label: item.riskAr, tone: item.tone),
                  ),
                  DataCell(SizedBox(width: 300, child: Text(item.decisionAr))),
                ],
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
                DataCell(SizedBox(width: 220, child: Text(item.area))),
                DataCell(
                  SizedBox(width: 360, child: Text(item.requiredEvidenceAr)),
                ),
                DataCell(SizedBox(width: 200, child: Text(item.ownerAr))),
                DataCell(
                  PwfSisStatusBadge(
                    label: item.status.labelAr,
                    tone: _toneFor(item.status),
                  ),
                ),
                DataCell(
                  SizedBox(width: 360, child: Text(item.blockerPolicyAr)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  PwfSisStatusTone _toneFor(PwfSisRolloutStatus status) {
    return switch (status) {
      PwfSisRolloutStatus.preserved => PwfSisStatusTone.neutral,
      PwfSisRolloutStatus.evidenceAccepted => PwfSisStatusTone.success,
      PwfSisRolloutStatus.readyForUat => PwfSisStatusTone.info,
      PwfSisRolloutStatus.pendingEvidence => PwfSisStatusTone.review,
      PwfSisRolloutStatus.conditionallyApproved => PwfSisStatusTone.info,
      PwfSisRolloutStatus.blocked => PwfSisStatusTone.danger,
      PwfSisRolloutStatus.notApproved => PwfSisStatusTone.danger,
    };
  }
}

class _MediaRouteInventoryItem {
  const _MediaRouteInventoryItem({
    required this.labelAr,
    required this.route,
    required this.ownerAr,
    required this.riskAr,
    required this.decisionAr,
    required this.tone,
  });

  final String labelAr;
  final String route;
  final String ownerAr;
  final String riskAr;
  final String decisionAr;
  final PwfSisStatusTone tone;
}
