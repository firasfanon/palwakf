import 'dart:math' as math;

import 'package:flutter/material.dart';

class PwfSisResponsiveWrapGrid extends StatelessWidget {
  const PwfSisResponsiveWrapGrid({
    super.key,
    required this.children,
    this.minItemWidth = 240,
    this.maxColumns = 4,
    this.spacing = 12,
    this.runSpacing = 12,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fallbackWidth = MediaQuery.sizeOf(context).width;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : fallbackWidth;
        final safeWidth = math.max(0.0, availableWidth);
        final calculatedColumns = safeWidth <= minItemWidth
            ? 1
            : ((safeWidth + spacing) / (minItemWidth + spacing)).floor();
        final columnCount = calculatedColumns.clamp(1, maxColumns);
        final totalSpacing = spacing * (columnCount - 1);
        final itemWidth = math.max(
          0.0,
          (safeWidth - totalSpacing) / columnCount,
        );

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
