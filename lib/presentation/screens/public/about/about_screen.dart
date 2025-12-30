// lib/presentation/screens/public/about/about_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'mobile_about_screen.dart';
import 'web_about_screen.dart';

/// Platform-aware About Screen Router
///
/// Automatically selects the appropriate implementation:
/// - Web: WebAboutScreen (with horizontal navbar, multi-column layout)
/// - Mobile: MobileAboutScreen (with vertical scrolling, single column)
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebAboutScreen();
    } else {
      return const MobileAboutScreen();
    }
  }
}