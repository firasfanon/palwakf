// lib/presentation/screens/public/mosques/mosques_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'mobile_mosques_screen.dart';
import 'web_mosques_details_screen.dart';

/// Platform-aware Mosques Screen Router
///
/// Automatically selects the appropriate implementation:
/// - Web: WebMosquesScreen (split map/list view, advanced filters)
/// - Mobile: MobileMosquesScreen (bottom nav, card layout)
class MosquesScreen extends StatelessWidget {
  const MosquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebMosquesScreen();
    } else {
      return const MobileMosquesScreen();
    }
  }
}