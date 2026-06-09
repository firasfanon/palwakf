import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../providers/document_intelligence_providers.dart';
import '../widgets/document_job_status_badge.dart';

class DocumentReviewQueuePage extends ConsumerWidget {
  const DocumentReviewQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(documentReviewQueueProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('طابور مراجعة الذكاء الوثائقي')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: queueAsync.when(
          data: (jobs) {
            if (jobs.isEmpty)
              return const Center(child: Text('لا توجد وظائف تنتظر المراجعة.'));
            return ListView.separated(
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Card(
                  child: ListTile(
                    onTap: () => context.go(
                      AppRoutes.adminDocumentIntelligenceReview(job.id),
                    ),
                    leading: const Icon(Icons.fact_check_outlined),
                    title: Text(job.documentTypePrimary ?? job.sourceSystem),
                    subtitle: Text(
                      '${job.mode.labelAr} • ${job.sensitivityLevel.labelAr}',
                    ),
                    trailing: DocumentJobStatusBadge(status: job.status),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('تعذر تحميل طابور المراجعة: $error')),
        ),
      ),
    );
  }
}
