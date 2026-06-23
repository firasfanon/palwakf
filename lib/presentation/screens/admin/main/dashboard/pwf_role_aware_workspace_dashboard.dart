import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PwfRoleAwareWorkspaceDashboard extends ConsumerWidget {
  const PwfRoleAwareWorkspaceDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Center(
        child: Text('Workspace Dashboard'),
      ),
    );
  }
}
