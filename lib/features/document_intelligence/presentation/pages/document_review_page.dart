import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/document_intelligence_providers.dart';
import '../widgets/document_candidate_links_panel.dart';
import '../widgets/document_review_action_bar.dart';
import '../widgets/document_structured_fields_editor.dart';
import '../widgets/document_uncertain_segments_list.dart';

class DocumentReviewPage extends ConsumerStatefulWidget {
  const DocumentReviewPage({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<DocumentReviewPage> createState() => _DocumentReviewPageState();
}

class _DocumentReviewPageState extends ConsumerState<DocumentReviewPage> {
  final _notesController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit(String status) async {
    setState(() => _busy = true);
    try {
      final repo = ref.read(documentIntelligenceRepositoryProvider);
      await repo.submitReview(
        jobId: widget.jobId,
        reviewStatus: status,
        notes: _notesController.text.trim(),
      );
      ref.invalidate(documentJobDetailProvider(widget.jobId));
      ref.invalidate(documentReviewQueueProvider);
      ref.invalidate(documentDashboardMetricsProvider);
      ref.invalidate(documentFileTypeUatCoverageProvider);
      ref.invalidate(documentProductionReadinessProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ قرار المراجعة.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر حفظ المراجعة: $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reprocess() async {
    setState(() => _busy = true);
    try {
      final repo = ref.read(documentIntelligenceRepositoryProvider);
      await repo.requestReprocess(
        jobId: widget.jobId,
        metadataPatch: {'requested_from_review': true},
      );
      ref.invalidate(documentJobDetailProvider(widget.jobId));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم طلب إعادة المعالجة.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر طلب إعادة المعالجة: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(documentJobDetailProvider(widget.jobId));

    return Scaffold(
      appBar: AppBar(title: const Text('مراجعة الوظيفة')),
      body: detailAsync.when(
        data: (detail) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.job.documentTypePrimary ?? detail.job.sourceSystem,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('النمط: ${detail.job.mode.labelAr}'),
                    Text('الحساسية: ${detail.job.sensitivityLevel.labelAr}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الحقول المستخرجة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    DocumentStructuredFieldsEditor(
                      fields: detail.structuredFields,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المقاطع غير المؤكدة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    DocumentUncertainSegmentsList(
                      items: detail.uncertainSegments,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الروابط المرشحة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    DocumentCandidateLinksPanel(links: detail.candidateLinks),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'ملاحظات المراجع',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            IgnorePointer(
              ignoring: _busy,
              child: DocumentReviewActionBar(
                onApprove: () => _submit('approved'),
                onReject: () => _submit('rejected'),
                onReprocess: _reprocess,
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('تعذر تحميل بيانات المراجعة: $error')),
      ),
    );
  }
}
