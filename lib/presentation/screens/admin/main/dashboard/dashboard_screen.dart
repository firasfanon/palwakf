import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'mobile_admin_dashboard.dart';
import 'web_admin_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebAdminDashboard();
    } else {
      return const MobileAdminDashboard();
    }
  }
}
