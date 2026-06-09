import 'package:flutter/material.dart';

import 'pwf_sis_status_badge.dart';

class PwfSisNotice extends StatelessWidget {
  const PwfSisNotice({
    super.key,
    required this.title,
    required this.message,
    this.tone = PwfSisStatusTone.info,
    this.action,
  });

  final String title;
  final String message;
  final PwfSisStatusTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final color = _toneColor(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(message),
                  if (action != null) ...[const SizedBox(height: 10), action!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _toneColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (tone) {
      PwfSisStatusTone.danger => scheme.error,
      PwfSisStatusTone.review => scheme.secondary,
      PwfSisStatusTone.success => Colors.green,
      PwfSisStatusTone.restricted => Colors.deepPurple,
      _ => scheme.primary,
    };
  }
}
