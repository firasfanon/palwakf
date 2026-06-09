import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'web_homepage_management_screen.dart';

class HomeManagementScreen extends StatelessWidget {
  const HomeManagementScreen({super.key, this.initialSurface = 'home'});

  final String initialSurface;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebHomePageManagementScreen(initialSurface: initialSurface);
    } else {
      return WebHomePageManagementScreen(initialSurface: initialSurface);
    }
  }
}
