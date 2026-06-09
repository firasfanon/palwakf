import 'package:flutter/material.dart';

import '../../../core/layout/pwf_global_layout_contract.dart';

/// Public shell wrapper.
///
/// Platform Development 10L binds all public routes to the global finite layout
/// contract. The shell remains lightweight and does not add a second page-level
/// scroll owner; individual public pages keep owning their own sections.
class PublicShell extends StatelessWidget {
  final Widget child;
  const PublicShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    PwfGlobalLayoutCertificationMarker.debugMark('public-shell');
    return PwfPublicRouteBoundary(child: child);
  }
}
