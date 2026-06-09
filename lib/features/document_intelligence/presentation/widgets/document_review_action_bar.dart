import 'package:flutter/material.dart';

class DocumentReviewActionBar extends StatelessWidget {
  const DocumentReviewActionBar({
    super.key,
    required this.onApprove,
    required this.onReject,
    required this.onReprocess,
  });

  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onReprocess;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: onApprove,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('اعتماد'),
        ),
        OutlinedButton.icon(
          onPressed: onReject,
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('رفض'),
        ),
        OutlinedButton.icon(
          onPressed: onReprocess,
          icon: const Icon(Icons.refresh_outlined),
          label: const Text('إعادة معالجة'),
        ),
      ],
    );
  }
}
