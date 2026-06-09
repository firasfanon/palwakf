import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../data/models/document_intelligence_models.dart';
import '../providers/document_intelligence_providers.dart';
import '../widgets/document_candidate_links_panel.dart';
import '../widgets/document_compare_panel.dart';
import '../widgets/document_assistant_export_panel.dart';
import '../widgets/document_engine_trace_panel.dart';
import '../widgets/document_sovereign_binding_panel.dart';
import '../widgets/document_workflow_timeline_panel.dart';
import '../widgets/document_job_status_badge.dart';
import '../widgets/document_structured_fields_editor.dart';
import '../widgets/document_uncertain_segments_list.dart';

class DocumentJobDetailPage extends ConsumerWidget {
  const DocumentJobDetailPage({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(documentJobDetailProvider(jobId));

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل وظيفة الذكاء الوثائقي')),
      body: detailAsync.when(
        data: (detail) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.job.documentTypePrimary ??
                                detail.job.sourceSystem,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('المعرف: ${detail.job.id}'),
                          Text(
                            'النظام المصدر: ${DocumentIntelligenceLabels.sourceSystem(detail.job.sourceSystem)}',
                          ),
                          Text('النمط: ${detail.job.mode.labelAr}'),
                        ],
                      ),
                    ),
                    DocumentJobStatusBadge(status: detail.job.status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DocumentComparePanel(
              originalLabel: _buildOriginalFileLabel(detail),
              processedLabel: _buildProcessedSummary(detail),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'أثر المحرك و Evidence UAT',
              child: DocumentEngineTracePanel(detail: detail),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'الربط السيادي مع أنظمة PalWakf',
              child: DocumentSovereignBindingPanel(detail: detail),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'سجل سير العمل والتدقيق',
              child: DocumentWorkflowTimelinePanel(detail: detail),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'ترشيح المعرفة للمساعد الداخلي',
              child: DocumentAssistantExportPanel(detail: detail),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'الحقول المستخرجة',
              child: DocumentStructuredFieldsEditor(
                fields: detail.structuredFields,
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'المقاطع غير المؤكدة',
              child: DocumentUncertainSegmentsList(
                items: detail.uncertainSegments,
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'الروابط المرشحة',
              child: DocumentCandidateLinksPanel(links: detail.candidateLinks),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'النصوص المستخرجة',
              child: detail.transcriptions.isEmpty
                  ? const Text('لا توجد نصوص معالجة محفوظة.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: detail.transcriptions.map((item) {
                        final pageNo = item['page_no']?.toString() ?? '-';
                        final fullText =
                            (item['full_text'] ?? item['printed_text'] ?? '')
                                .toString();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الصفحة $pageNo',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                fullText.isEmpty
                                    ? 'لا يوجد نص محفوظ.'
                                    : fullText,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go(
                    AppRoutes.adminDocumentIntelligenceReview(jobId),
                  ),
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('فتح شاشة المراجعة'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go(
                    AppRoutes.adminDocumentIntelligenceLinking(jobId),
                  ),
                  icon: const Icon(Icons.link_outlined),
                  label: const Text('شاشة الربط'),
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('تعذر تحميل التفاصيل: $error')),
      ),
    );
  }

  String _buildOriginalFileLabel(DocumentJobDetail detail) {
    final originals = detail.files
        .where((f) => f.fileRole == 'original')
        .toList();
    if (originals.isEmpty) return 'لا يوجد ملف أصلي مسجل';
    return originals
        .map((f) {
          final name = f.originalFileName ?? f.storagePath;
          final size = f.fileSizeBytes == null
              ? ''
              : ' • ${(f.fileSizeBytes! / 1024).toStringAsFixed(1)} KB';
          return '$name$size\n${f.storageBucket}/${f.storagePath}';
        })
        .join('\n\n');
  }

  String _buildProcessedSummary(DocumentJobDetail detail) {
    if (detail.transcriptions.isEmpty &&
        detail.structuredFields.isEmpty &&
        detail.candidateLinks.isEmpty) {
      return 'لا توجد مخرجات معالجة مسجلة';
    }
    return [
      'الصفحات المعالجة: ${detail.transcriptions.length}',
      'الحقول المستخرجة: ${detail.structuredFields.length}',
      'المقاطع غير المؤكدة: ${detail.uncertainSegments.length}',
      'الروابط المرشحة: ${detail.candidateLinks.length}',
    ].join('\n');
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

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
