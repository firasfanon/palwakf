// lib/presentation/widgets/admin/admin_layout.dart
import 'package:flutter/material.dart';

import '../web/web_sidebar.dart';

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
    return Row(
      children: [
        // FIXED SIDEBAR - Always 280px
        WebSidebar(currentRoute: currentRoute),
        // MAIN CONTENT
        Expanded(child: child),
      ],
    );
  }
}
class NavItem {
  final IconData icon;
  final String label;
  final String route;

  const NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}