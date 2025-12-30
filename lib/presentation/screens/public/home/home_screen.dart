// lib/presentation/screens/public/home_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'mobile_home_screen.dart';
import 'web_home_screen.dart';

/// Platform-aware Home Screen Router
///
/// Automatically selects the appropriate implementation:
/// - Web: WebHomeScreen (with horizontal navbar, multi-column layout)
/// - Mobile: MobileHomeScreen (with bottom navigation, single column)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebHomeScreen();
    } else {
      return const MobileHomeScreen();
    }
  }
}