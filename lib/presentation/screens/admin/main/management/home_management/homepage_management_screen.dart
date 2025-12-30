import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'web_homepage_management_screen.dart';


class HomeManagementScreen extends StatelessWidget {
  const HomeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebHomePageManagementScreen();
    } else {
      return const WebHomePageManagementScreen();
    }
  }
}
