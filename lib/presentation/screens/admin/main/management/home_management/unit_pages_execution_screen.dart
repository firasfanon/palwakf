import 'package:flutter/material.dart';

import 'unit_surfaces_management_screen.dart';

/// Compatibility entry point for the retired unit-pages execution workspace.
///
/// Publication and composition are now reconciled in [UnitSurfacesManagementScreen]
/// so this route cannot maintain an independent legacy publication state.
class UnitPagesExecutionScreen extends StatelessWidget {
  const UnitPagesExecutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnitSurfacesManagementScreen();
  }
}
