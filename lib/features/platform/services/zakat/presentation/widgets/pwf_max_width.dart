import 'package:flutter/material.dart';

class PwfMaxWidth extends StatelessWidget {
  const PwfMaxWidth({
    super.key,
    required this.child,
    this.maxWidth = 1400,
    this.horizontalPadding = 16,
  });

  final Widget child;
  final double maxWidth;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}
