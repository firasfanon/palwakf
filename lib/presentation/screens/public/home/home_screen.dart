// lib/presentation/screens/public/home_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'mobile_home_screen.dart';

// New Home (HTML-extraction-driven) for Web.
import '../../../../features/platform/home/presentation/screens/pwf_home_web_screen.dart';

/// Platform-aware Home Screen Router
///
/// Automatically selects the appropriate implementation:
/// - Web: WebHomeScreen (with horizontal navbar, multi-column layout)
/// - Mobile: MobileHomeScreen (with bottom navigation, single column)
class HomeScreen extends StatelessWidget {
  final String unitSlug;
  final String? unitTitle;

  const HomeScreen({super.key, this.unitSlug = 'home', this.unitTitle});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Adopt the new visual identity on Web.
      return PwfHomeWebScreen(unitSlug: unitSlug);
    } else {
      return MobileHomeScreen(unitSlug: unitSlug, unitTitle: unitTitle);
    }
  }
}
