import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pwf_role_aware_workspace_dashboard.dart';

/// Canonical administrative dashboard entrypoint.
///
/// The dashboard deliberately avoids generic, fabricated metrics and instead
/// renders a role, system and unit aware workspace from the authenticated
/// actor's effective authority contract.
class WebAdminDashboard extends ConsumerWidget {
  const WebAdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PwfRoleAwareWorkspaceDashboard();
  }
}
