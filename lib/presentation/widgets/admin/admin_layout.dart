// lib/presentation/widgets/admin/admin_layout.dart
// NOTE: Sidebar is rendered by PlatformAdminShell only.
// This layout is kept for backward compatibility and must NOT render a sidebar.
import 'package:flutter/material.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const AdminLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final String route;

  const NavItem({required this.icon, required this.label, required this.route});
}
