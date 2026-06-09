import 'package:flutter/material.dart';

class PwfSisSystemHero extends StatelessWidget {
  const PwfSisSystemHero({
    super.key,
    required this.kicker,
    required this.title,
    required this.description,
    this.actions = const [],
  });

  final String kicker;
  final String title;
  final String description;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 700;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 20 : 26),
        gradient: LinearGradient(
          colors: [scheme.primaryContainer, scheme.primary, scheme.secondary],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 18 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kicker,
              style: TextStyle(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              softWrap: true,
              style:
                  (compact
                          ? Theme.of(context).textTheme.headlineSmall
                          : Theme.of(context).textTheme.headlineMedium)
                      ?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              softWrap: true,
              style: TextStyle(color: scheme.onPrimary.withValues(alpha: .86)),
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}
