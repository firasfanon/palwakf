import 'package:flutter/material.dart';

import '../../data/models/document_intelligence_models.dart';

class DocumentCandidateLinksPanel extends StatelessWidget {
  const DocumentCandidateLinksPanel({super.key, required this.links});

  final List<DocumentCandidateLink> links;

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) {
      return const Text(
        'لا توجد روابط مرشحة. أضف معرفًا سياديًا مثل معرف الأصل الوقفي أو القضية أو المهمة لتوليد روابط قابلة للمراجعة.',
      );
    }
    return Column(
      children: links.map((link) {
        final subtitleParts = <String>[
          'الكيان: ${DocumentIntelligenceLabels.entityType(link.entityType)}',
          'المعرف: ${link.entityId}',
          'الثقة: ${DocumentIntelligenceLabels.confidenceShort(link.confidence)}',
          if (link.score != null)
            'الدرجة: ${(link.score! * 100).toStringAsFixed(0)}%',
          if (link.matchBasis.isNotEmpty)
            'الأساس: ${link.matchBasis.join(' • ')}',
        ];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.link_outlined),
            title: Text(
              link.displayLabel ??
                  DocumentIntelligenceLabels.entityType(link.entityType),
            ),
            subtitle: Text(subtitleParts.join('\n')),
            isThreeLine: true,
            trailing: link.requiresReview
                ? const Icon(Icons.rule_folder_outlined)
                : const Icon(Icons.check_circle_outline),
          ),
        );
      }).toList(),
    );
  }
}
