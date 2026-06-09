import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/document_intelligence_providers.dart';

class DocumentDashboardMetricsPanel extends ConsumerWidget {
  const DocumentDashboardMetricsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(documentDashboardMetricsProvider);
    return metricsAsync.when(
      data: (metrics) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricTile(
              title: 'كل الوظائف',
              value: metrics.totalJobs.toString(),
              icon: Icons.inventory_2_outlined,
            ),
            _MetricTile(
              title: 'بانتظار مراجعة',
              value: metrics.needsReview.toString(),
              icon: Icons.rule_folder_outlined,
            ),
            _MetricTile(
              title: 'معتمدة',
              value: metrics.approved.toString(),
              icon: Icons.verified_outlined,
            ),
            _MetricTile(
              title: 'روابط سيادية',
              value: metrics.withSovereignLinks.toString(),
              icon: Icons.link_outlined,
            ),
            _MetricTile(
              title: 'Evidence UAT',
              value: metrics.withUatEvidence.toString(),
              icon: Icons.science_outlined,
            ),
            _MetricTile(
              title: 'إغلاق العائلات',
              value: '${metrics.closedFileFamilies}/4',
              icon: Icons.task_alt_outlined,
            ),
          ],
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: LinearProgressIndicator(),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('تعذر تحميل مؤشرات المركز: $error'),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
  }
}
