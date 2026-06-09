import 'package:flutter/material.dart';

import '../../../../core/widgets/palwakf_sis/pwf_sis_adaptive_workspace.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_metric_card.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_notice.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_responsive_wrap_grid.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_section_card.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_status_badge.dart';
import '../../../../core/widgets/palwakf_sis/pwf_sis_system_hero.dart';

class PwfSisAwqafSystemPilotPage extends StatelessWidget {
  const PwfSisAwqafSystemPilotPage({super.key});

  static const routePath = '/admin/platform/design-system/awqaf-pilot';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 720;

    return Scaffold(
      appBar: AppBar(title: const Text('Awqaf System — PWF-SIS Pilot')),
      body: ListView(
        padding: EdgeInsets.all(compact ? 16 : 24),
        children: [
          PwfSisSystemHero(
            kicker: 'Awqaf System Pilot',
            title: 'أوقاف سيستم وفق PWF-SIS',
            description:
                'نموذج hardening لاختبار نظام الواجهات السيادي دون تغيير routing أو RBAC أو waqf_assets. هذا Pilot بصري/تشغيلي تجريبي فقط.',
            actions: [
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.dashboard_customize_rounded),
                label: const Text('معاينة مساحة العمل'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text('مصفوفة الصلاحيات'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const PwfSisResponsiveWrapGrid(
            minItemWidth: 230,
            children: [
              PwfSisMetricCard(
                label: 'أصول مسودة',
                value: '1',
                badge: 'draft',
                tone: PwfSisStatusTone.review,
              ),
              PwfSisMetricCard(
                label: 'روابط مرشحة',
                value: '2',
                badge: 'candidate',
              ),
              PwfSisMetricCard(
                label: 'موانع',
                value: '0',
                badge: 'blocked',
                tone: PwfSisStatusTone.success,
              ),
              PwfSisMetricCard(
                label: 'جاهزية Pilot',
                value: '9/9',
                badge: 'runtime',
                tone: PwfSisStatusTone.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          PwfSisAdaptiveWorkspace(
            primary: const _AwqafPilotWorkspace(),
            contextPanel: const _AwqafPilotEvidencePanel(),
            mobileTabLabels: const ['الملخص', 'العمل', 'الأدلة'],
            mobileTabs: const [
              _AwqafPilotMobileSummary(),
              _AwqafPilotWorkspace(),
              _AwqafPilotEvidencePanel(),
            ],
          ),
          const SizedBox(height: 16),
          const _AwqafPilotRoleMatrix(),
          const SizedBox(height: 16),
          const PwfSisNotice(
            title: 'حدود Pilot',
            message:
                'لا يوجد اعتماد أصول، لا تعديل waqf_assets، ولا اتصال تشغيلي مع baseline أوقاف سيستم الفعلي في هذه الصفحة.',
            tone: PwfSisStatusTone.danger,
          ),
        ],
      ),
    );
  }
}

class _AwqafPilotWorkspace extends StatelessWidget {
  const _AwqafPilotWorkspace();

  @override
  Widget build(BuildContext context) {
    return PwfSisSectionCard(
      title: 'مساحة العمل',
      subtitle:
          'نموذج منضبط لقائمة أصول/مراجعات دون أي تعديل فعلي على البيانات.',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('الأصل')),
            DataColumn(label: Text('الحالة')),
            DataColumn(label: Text('الدليل')),
            DataColumn(label: Text('الإجراء')),
          ],
          rows: [
            DataRow(
              cells: [
                const DataCell(
                  SizedBox(
                    width: 230,
                    child: Text('PWF-AST-DEMO-B001-LND-000003'),
                  ),
                ),
                const DataCell(
                  PwfSisStatusBadge(
                    label: 'draft',
                    tone: PwfSisStatusTone.review,
                  ),
                ),
                const DataCell(
                  SizedBox(
                    width: 220,
                    child: Text('Pilot evidence only — no mutation'),
                  ),
                ),
                DataCell(
                  TextButton(onPressed: () {}, child: const Text('معاينة')),
                ),
              ],
            ),
            DataRow(
              cells: [
                const DataCell(
                  SizedBox(
                    width: 230,
                    child: Text('PWF-AST-DEMO-JER001-MSQ-000002'),
                  ),
                ),
                const DataCell(
                  PwfSisStatusBadge(
                    label: 'review',
                    tone: PwfSisStatusTone.info,
                  ),
                ),
                const DataCell(
                  SizedBox(
                    width: 220,
                    child: Text('Responsive + role validation'),
                  ),
                ),
                DataCell(
                  TextButton(onPressed: () {}, child: const Text('تفاصيل')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AwqafPilotEvidencePanel extends StatelessWidget {
  const _AwqafPilotEvidencePanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PwfSisNotice(
          title: 'حماية Pilot',
          message:
              'هذه الصفحة لا تعدل waqf_assets ولا تعتمد أصولًا. الغرض اختبار PWF-SIS فقط.',
          tone: PwfSisStatusTone.info,
        ),
        SizedBox(height: 12),
        PwfSisNotice(
          title: 'Responsive Evidence',
          message:
              'يلزم تصوير desktop/tablet/mobile وإثبات عدم وجود overflow أو render exceptions.',
          tone: PwfSisStatusTone.review,
        ),
        SizedBox(height: 12),
        PwfSisNotice(
          title: 'Role Gate',
          message:
              'superuser/platform admin يرى pilot، restricted لا يرى أدوات الحوكمة.',
          tone: PwfSisStatusTone.restricted,
        ),
      ],
    );
  }
}

class _AwqafPilotMobileSummary extends StatelessWidget {
  const _AwqafPilotMobileSummary();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        PwfSisMetricCard(label: 'Pilot', value: 'آمن', badge: 'visual'),
        SizedBox(height: 12),
        PwfSisNotice(
          title: 'نمط موبايل',
          message: 'تظهر مساحة العمل ضمن تبويبات لتقليل الأوفرلود.',
        ),
      ],
    );
  }
}

class _AwqafPilotRoleMatrix extends StatelessWidget {
  const _AwqafPilotRoleMatrix();

  @override
  Widget build(BuildContext context) {
    return PwfSisSectionCard(
      title: 'Role-Based UI Validation للـ Pilot',
      subtitle: 'أدلة الدور المطلوبة قبل تعميم PWF-SIS على أي نظام إضافي.',
      child: const PwfSisResponsiveWrapGrid(
        minItemWidth: 220,
        maxColumns: 3,
        children: [
          _RoleCard(
            title: 'Superuser',
            status: 'allowed',
            body: 'يفتح صفحات PWF-SIS كاملة لأغراض الحوكمة والتصديق.',
            tone: PwfSisStatusTone.success,
          ),
          _RoleCard(
            title: 'Platform Admin',
            status: 'scoped',
            body: 'يرى الأدوات حسب manageSystems وسياق النظام.',
            tone: PwfSisStatusTone.info,
          ),
          _RoleCard(
            title: 'Restricted',
            status: 'hidden/forbidden',
            body: 'لا تظهر أدوات حوكمة PWF-SIS ولا أي بيانات تشغيلية حساسة.',
            tone: PwfSisStatusTone.danger,
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.status,
    required this.body,
    required this.tone,
  });

  final String title;
  final String status;
  final String body;
  final PwfSisStatusTone tone;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boundedHeight = constraints.hasBoundedHeight;
            final tightHeight = boundedHeight && constraints.maxHeight < 120;
            final titleStyle = Theme.of(context).textTheme.titleMedium;
            final bodyStyle = Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.2);

            final content = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerEnd,
                        child: PwfSisStatusBadge(label: status, tone: tone),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tightHeight ? 6 : 10),
                Text(
                  body,
                  maxLines: tightHeight ? 2 : 4,
                  overflow: TextOverflow.ellipsis,
                  style: bodyStyle,
                ),
              ],
            );

            if (!boundedHeight || !constraints.hasBoundedWidth) {
              return content;
            }

            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.topStart,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: content,
              ),
            );
          },
        ),
      ),
    );
  }
}
