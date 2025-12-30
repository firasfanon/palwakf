import 'package:flutter/material.dart';

/// Platform admin shell wrapper.
/// Later: move sidebar/topbar here and keep pages content-only.
class PlatformAdminShell extends StatelessWidget {
  final Widget child;
  const PlatformAdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
