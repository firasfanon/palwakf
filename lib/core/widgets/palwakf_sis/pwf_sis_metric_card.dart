import 'package:flutter/material.dart';

import 'pwf_sis_status_badge.dart';

class PwfSisMetricCard extends StatelessWidget {
  const PwfSisMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.badge,
    this.tone = PwfSisStatusTone.info,
  });

  final String label;
  final String value;
  final String? badge;
  final PwfSisStatusTone tone;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          PositionedDirectional(
            start: 16,
            end: 16,
            top: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boundedHeight = constraints.hasBoundedHeight;
                final tightHeight = boundedHeight && constraints.maxHeight < 92;
                final content = Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (badge != null)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: PwfSisStatusBadge(label: badge!, tone: tone),
                      ),
                    SizedBox(height: tightHeight ? 4 : 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        value,
                        textDirection: TextDirection.ltr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: tightHeight ? 24.0 : null,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    SizedBox(height: tightHeight ? 2 : 4),
                    Text(
                      label,
                      maxLines: tightHeight ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.15),
                    ),
                  ],
                );

                if (!boundedHeight || !constraints.hasBoundedWidth) {
                  return content;
                }

                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                    child: content,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
