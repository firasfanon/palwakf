import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../data/models/document_intelligence_models.dart';
import '../providers/document_intelligence_providers.dart';
import '../widgets/document_dashboard_metrics_panel.dart';
import '../widgets/document_file_type_readiness_panel.dart';
import '../widgets/document_production_readiness_panel.dart';
import '../widgets/document_rbac_policy_panel.dart';
import '../widgets/document_job_status_badge.dart';

class DocumentIntelligenceDashboardPage extends ConsumerWidget {
  const DocumentIntelligenceDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(documentJobsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('مركز الوثائق والذكاء الوثائقي')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'مركز الوثائق',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'نقطة تشغيل موحدة لرفع الوثائق، توليد حقول مراجعة، كشف المقاطع غير المؤكدة، واقتراح روابط سيادية مع waqf_assets والقضايا والمهام والسجلات المالية.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const DocumentDashboardMetricsPanel(),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () =>
                      context.go(AppRoutes.adminDocumentIntelligenceNew),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('إنشاء job جديد'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go(
                    AppRoutes.adminDocumentIntelligenceReviewQueue,
                  ),
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('طابور المراجعة'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const DocumentFileTypeReadinessPanel(),
            const SizedBox(height: 24),
            const DocumentProductionReadinessPanel(),
            const SizedBox(height: 24),
            const _DashboardSectionCard(
              title: 'سياسات الصلاحيات والحراسة',
              child: DocumentRbacPolicyPanel(),
            ),
            const SizedBox(height: 24),
            const Text(
              'آخر الوظائف',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            jobsAsync.when(
              data: (jobs) {
                if (jobs.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('لا توجد وظائف حتى الآن.'),
                    ),
                  );
                }
                return Column(
                  children: jobs.take(10).map((job) {
                    return Card(
                      child: ListTile(
                        onTap: () => context.go(
                          AppRoutes.adminDocumentIntelligenceJob(job.id),
                        ),
                        title: Text(
                          job.documentTypePrimary ?? job.sourceSystem,
                        ),
                        subtitle: Text(
                          '${job.mode.labelAr} • ${DocumentIntelligenceLabels.sourceSystem(job.sourceSystem)}',
                        ),
                        leading: const Icon(Icons.description_outlined),
                        trailing: DocumentJobStatusBadge(status: job.status),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('تعذر تحميل البيانات: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSectionCard extends StatelessWidget {
  const _DashboardSectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
