import 'package:flutter/material.dart';

import '../../data/models/document_intelligence_models.dart';

class DocumentUncertainSegmentsList extends StatelessWidget {
  const DocumentUncertainSegmentsList({super.key, required this.items});

  final List<DocumentUncertainSegment> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text('لا توجد مقاطع غير مؤكدة.');
    }
    return Column(
      children: items.map((item) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(item.rawText),
            subtitle: Text(
              'الصفحة ${item.pageNo} • ${_reasonLabel(item.reason)}',
            ),
            leading: const Icon(Icons.help_outline),
            trailing: Chip(label: Text(_confidenceLabel(item.confidence))),
          ),
        );
      }).toList(),
    );
  }

  String _reasonLabel(String reason) =>
      DocumentIntelligenceLabels.uncertaintyReason(reason);

  String _confidenceLabel(String value) =>
      DocumentIntelligenceLabels.confidenceShort(value);
}
