import 'package:flutter/material.dart';

import '../../data/models/document_intelligence_models.dart';

class DocumentWorkflowTimelinePanel extends StatelessWidget {
  const DocumentWorkflowTimelinePanel({super.key, required this.detail});

  final DocumentJobDetail detail;

  @override
  Widget build(BuildContext context) {
    final events = detail.auditEvents
        .map(DocumentWorkflowEvent.fromMap)
        .toList();
    if (events.isEmpty) {
      return const Text('لا توجد أحداث تدقيق مسجلة لهذه الوثيقة بعد.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: events.take(12).map((event) {
        final when = event.createdAt == null
            ? 'وقت غير محدد'
            : event.createdAt!.toLocal().toString();
        return ListTile(
          dense: true,
          leading: const Icon(Icons.timeline_outlined),
          title: Text(
            event.eventLabelAr.isEmpty ? event.eventType : event.eventLabelAr,
          ),
          subtitle: Text(when),
        );
      }).toList(),
    );
  }
}
