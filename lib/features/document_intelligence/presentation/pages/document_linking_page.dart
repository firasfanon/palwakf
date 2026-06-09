import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/document_intelligence_models.dart';
import '../providers/document_intelligence_providers.dart';

class DocumentLinkingPage extends ConsumerStatefulWidget {
  const DocumentLinkingPage({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<DocumentLinkingPage> createState() =>
      _DocumentLinkingPageState();
}

class _DocumentLinkingPageState extends ConsumerState<DocumentLinkingPage> {
  final _notesController = TextEditingController();
  final Map<String, _LinkDecision> _decisions = <String, _LinkDecision>{};
  bool _submitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit(List<DocumentCandidateLink> links) async {
    final approved = <Map<String, dynamic>>[];
    final rejected = <Map<String, dynamic>>[];

    for (final link in links) {
      final decision = _decisions[_linkKey(link)] ?? _LinkDecision.defer;
      if (decision == _LinkDecision.approve) {
        approved.add(link.toReviewPayload());
      } else if (decision == _LinkDecision.reject) {
        rejected.add(link.toReviewPayload());
      }
    }

    if (approved.isEmpty && rejected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اختر اعتمادًا أو رفضًا لرابط واحد على الأقل.'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final repo = ref.read(documentIntelligenceRepositoryProvider);
      await repo.submitReview(
        jobId: widget.jobId,
        reviewStatus: 'reviewed',
        notes: _notesController.text.trim().isEmpty
            ? 'مراجعة روابط مرشحة من شاشة الربط.'
            : _notesController.text.trim(),
        approvedLinks: approved,
        rejectedLinks: rejected,
      );
      ref.invalidate(documentCandidateLinksProvider(widget.jobId));
      ref.invalidate(documentJobDetailProvider(widget.jobId));
      ref.invalidate(documentJobsProvider);
      ref.invalidate(documentReviewQueueProvider);
      ref.invalidate(documentDashboardMetricsProvider);
      ref.invalidate(documentFileTypeUatCoverageProvider);
      ref.invalidate(documentProductionReadinessProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ مراجعة الربط: ${approved.length} اعتماد / ${rejected.length} رفض.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر حفظ مراجعة الربط: $error')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _linkKey(DocumentCandidateLink link) {
    if (link.id.isNotEmpty) return link.id;
    return '${link.entityType}:${link.entityId}';
  }

  @override
  Widget build(BuildContext context) {
    final linksAsync = ref.watch(documentCandidateLinksProvider(widget.jobId));

    return Scaffold(
      appBar: AppBar(title: const Text('مراجعة ربط الكيانات المرشحة')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: linksAsync.when(
          data: (links) {
            if (links.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد روابط مرشحة قابلة للمراجعة. أضف معرفات UUID سيادية عند إنشاء الوظيفة، مثل waqf_asset_id أو case_id.',
                ),
              );
            }
            return ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'قرار الربط',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'اعتمد فقط الروابط التي تمثل علاقة صحيحة مع مصدر سيادي. الرفض لا يحذف الرابط، بل يوثق قرار المراجع.',
                        ),
                        const SizedBox(height: 16),
                        ...links.map(_buildLinkDecisionTile),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'ملاحظات الربط',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.icon(
                            onPressed: _submitting
                                ? null
                                : () => _submit(links),
                            icon: const Icon(Icons.save_as_outlined),
                            label: Text(
                              _submitting
                                  ? 'جاري الحفظ...'
                                  : 'حفظ قرارات الربط',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('تعذر تحميل الروابط المرشحة: $error')),
        ),
      ),
    );
  }

  Widget _buildLinkDecisionTile(DocumentCandidateLink link) {
    final key = _linkKey(link);
    final decision = _decisions[key] ?? _LinkDecision.defer;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    link.displayLabel ??
                        DocumentIntelligenceLabels.entityType(link.entityType),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(
                    DocumentIntelligenceLabels.confidenceShort(link.confidence),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              '${DocumentIntelligenceLabels.entityType(link.entityType)} • ${link.entityId}',
            ),
            if (link.matchBasis.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('أساس الترشيح: ${link.matchBasis.join(' • ')}'),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('اعتماد'),
                  selected: decision == _LinkDecision.approve,
                  onSelected: (_) =>
                      setState(() => _decisions[key] = _LinkDecision.approve),
                ),
                ChoiceChip(
                  label: const Text('رفض'),
                  selected: decision == _LinkDecision.reject,
                  onSelected: (_) =>
                      setState(() => _decisions[key] = _LinkDecision.reject),
                ),
                ChoiceChip(
                  label: const Text('تأجيل'),
                  selected: decision == _LinkDecision.defer,
                  onSelected: (_) =>
                      setState(() => _decisions[key] = _LinkDecision.defer),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _LinkDecision { approve, reject, defer }
