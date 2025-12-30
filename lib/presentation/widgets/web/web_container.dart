// lib/presentation/widgets/web/web_container.dart
import 'package:flutter/material.dart';

/// Web container with maximum width constraint
/// Keeps content centered and prevents overflow on ultra-wide screens
class WebContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const WebContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: padding,
        child: child,
      ),
    );
  }
}