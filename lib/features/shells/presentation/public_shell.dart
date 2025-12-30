import 'package:flutter/material.dart';

/// Public shell wrapper (Header/Footer can be moved here progressively).
/// For now, we keep it lightweight to avoid duplicating existing UI in screens.
class PublicShell extends StatelessWidget {
  final Widget child;
  const PublicShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
