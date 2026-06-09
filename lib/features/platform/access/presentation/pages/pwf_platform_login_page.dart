import 'package:flutter/material.dart';

/// Platform-owned login page shell.
///
/// The current web/mobile login implementations are still used as adapters by
/// `LoginScreen`. This shell documents and enforces that login UX is platform
/// owned, not system-owned. Full runtime wiring can move existing Web/Mobile
/// widgets behind this shell without changing system routes.
class PwfPlatformLoginPage extends StatelessWidget {
  const PwfPlatformLoginPage({
    super.key,
    required this.child,
    this.recoveryMode = false,
  });

  final Widget child;
  final bool recoveryMode;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
