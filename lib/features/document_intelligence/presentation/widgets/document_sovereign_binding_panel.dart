import 'package:flutter/material.dart';

import '../../data/models/document_intelligence_models.dart';

class DocumentSovereignBindingPanel extends StatelessWidget {
  const DocumentSovereignBindingPanel({super.key, required this.detail});

  final DocumentJobDetail detail;

  @override
  Widget build(BuildContext context) {
    final linksByType = <String, int>{};
    for (final link in detail.candidateLinks) {
      linksByType[link.entityType] = (linksByType[link.entityType] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusChip(
              label: detail.hasSovereignAnchor
                  ? 'يوجد رابط سيادي'
                  : 'ينقص رابط سيادي',
              ok: detail.hasSovereignAnchor,
            ),
            _StatusChip(
              label: detail.hasHumanReview
                  ? 'مراجعة بشرية موجودة'
                  : 'ينتظر مراجعة بشرية',
              ok: detail.hasHumanReview,
            ),
            _StatusChip(
              label: detail.isAssistantReady
                  ? 'جاهز للمساعد'
                  : 'غير جاهز للمساعد',
              ok: detail.isAssistantReady,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (linksByType.isEmpty)
          const Text(
            'لا توجد روابط مرشحة. أضف waqf_asset_id أو case_id أو task_id أو رابطًا سياديًا عند إنشاء الوظيفة.',
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: linksByType.entries.map((entry) {
              return Chip(
                label: Text(
                  '${DocumentIntelligenceLabels.entityType(entry.key)}: ${entry.value}',
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 8),
        const Text(
          'قاعدة الربط: waqf_assets هو الكيان التشغيلي المركزي، awqaf_system مصدر Master Data، وmustakshif للتحليل المكاني فقط.',
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.ok});

  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        ok ? Icons.check_circle_outline : Icons.error_outline,
        size: 18,
      ),
      label: Text(label),
    );
  }
}
