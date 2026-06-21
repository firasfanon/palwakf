import 'package:flutter/material.dart';

/// Matches the HTML `.container` sizing while remaining safe on narrow web
/// viewports such as DevTools-docked browser UAT.
class PwfWebContainer extends StatelessWidget {
  const PwfWebContainer({
    super.key,
    required this.child,
    this.maxWidth = 1400,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth &&
                constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final horizontalLimit = availableWidth < 300
            ? 8.0
            : availableWidth < 480
            ? 12.0
            : 20.0;
        final effectivePadding = EdgeInsets.fromLTRB(
          padding.left.clamp(0.0, horizontalLimit).toDouble(),
          padding.top,
          padding.right.clamp(0.0, horizontalLimit).toDouble(),
          padding.bottom,
        );

        return Padding(
          padding: effectivePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
