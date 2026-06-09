import 'package:flutter/material.dart';

import '../../data/models/document_intelligence_models.dart';

class DocumentJobStatusBadge extends StatelessWidget {
  const DocumentJobStatusBadge({super.key, required this.status});

  final DocumentJobStatus status;

  Color _background(BuildContext context) => switch (status) {
    DocumentJobStatus.draft => Colors.grey.shade200,
    DocumentJobStatus.machineProcessed => Colors.blue.shade50,
    DocumentJobStatus.needsReview => Colors.orange.shade50,
    DocumentJobStatus.reviewed => Colors.purple.shade50,
    DocumentJobStatus.approved => Colors.green.shade50,
    DocumentJobStatus.rejected => Colors.red.shade50,
  };

  Color _foreground(BuildContext context) => switch (status) {
    DocumentJobStatus.draft => Colors.grey.shade800,
    DocumentJobStatus.machineProcessed => Colors.blue.shade800,
    DocumentJobStatus.needsReview => Colors.orange.shade800,
    DocumentJobStatus.reviewed => Colors.purple.shade800,
    DocumentJobStatus.approved => Colors.green.shade800,
    DocumentJobStatus.rejected => Colors.red.shade800,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _background(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.labelAr,
        style: TextStyle(
          color: _foreground(context),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
