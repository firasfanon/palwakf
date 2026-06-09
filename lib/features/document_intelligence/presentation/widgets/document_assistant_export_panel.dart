import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/document_intelligence_models.dart';
import '../providers/document_intelligence_providers.dart';

class DocumentAssistantExportPanel extends ConsumerStatefulWidget {
  const DocumentAssistantExportPanel({super.key, required this.detail});

  final DocumentJobDetail detail;

  @override
  ConsumerState<DocumentAssistantExportPanel> createState() =>
      _DocumentAssistantExportPanelState();
}

class _DocumentAssistantExportPanelState
    extends ConsumerState<DocumentAssistantExportPanel> {
  bool _busy = false;

  Future<void> _publishCandidate() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(documentIntelligenceRepositoryProvider)
          .publishAssistantKnowledgeCandidate(
            jobId: widget.detail.job.id,
            notes: 'ترشيح وثيقة معتمدة للمساعد الداخلي من مركز الوثائق.',
          );
      ref.invalidate(documentJobDetailProvider(widget.detail.job.id));
      ref.invalidate(documentProductionReadinessProvider);
      ref.invalidate(documentDashboardMetricsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم ترشيح الوثيقة للمساعد الداخلي.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر ترشيح الوثيقة للمساعد: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail.isAssistantReady
              ? 'الوثيقة معتمدة ومراجعة؛ يمكن ترشيحها كمصدر معرفة للمساعد الداخلي.'
              : 'لا تُرشح الوثيقة للمساعد قبل الاعتماد والمراجعة البشرية.',
        ),
        const SizedBox(height: 12),
        if (detail.assistantCitations.isNotEmpty)
          Text('استشهادات/ترشيحات مسجلة: ${detail.assistantCitations.length}')
        else
          const Text('لا توجد ترشيحات معرفة مسجلة بعد.'),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: !detail.isAssistantReady || _busy
              ? null
              : _publishCandidate,
          icon: const Icon(Icons.psychology_alt_outlined),
          label: Text(_busy ? 'جاري التسجيل...' : 'ترشيح للمساعد الداخلي'),
        ),
      ],
    );
  }
}
