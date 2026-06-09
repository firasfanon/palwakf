import 'package:flutter/material.dart';

enum PwfSisStatusTone { info, review, success, danger, restricted, neutral }

class PwfSisStatusBadge extends StatelessWidget {
  const PwfSisStatusBadge({
    super.key,
    required this.label,
    this.tone = PwfSisStatusTone.neutral,
    this.icon,
  });

  final String label;
  final PwfSisStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context, tone);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.$2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: colors.$3),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.$3,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, Color, Color) _colors(BuildContext context, PwfSisStatusTone tone) {
    final scheme = Theme.of(context).colorScheme;
    return switch (tone) {
      PwfSisStatusTone.info => (
        scheme.primary.withValues(alpha: .12),
        scheme.primary.withValues(alpha: .28),
        scheme.primary,
      ),
      PwfSisStatusTone.review => (
        scheme.secondary.withValues(alpha: .20),
        scheme.secondary.withValues(alpha: .42),
        Colors.brown.shade800,
      ),
      PwfSisStatusTone.success => (
        Colors.green.withValues(alpha: .12),
        Colors.green.withValues(alpha: .28),
        Colors.green.shade700,
      ),
      PwfSisStatusTone.danger => (
        scheme.error.withValues(alpha: .12),
        scheme.error.withValues(alpha: .28),
        scheme.error,
      ),
      PwfSisStatusTone.restricted => (
        Colors.deepPurple.withValues(alpha: .12),
        Colors.deepPurple.withValues(alpha: .28),
        Colors.deepPurple,
      ),
      PwfSisStatusTone.neutral => (
        scheme.surfaceContainerHighest,
        scheme.outlineVariant,
        scheme.onSurfaceVariant,
      ),
    };
  }
}
