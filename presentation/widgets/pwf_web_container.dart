import 'package:flutter/material.dart';

/// Matches the HTML `.container` sizing:
/// - max-width: 1400px
/// - horizontal padding: 20px
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
    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
