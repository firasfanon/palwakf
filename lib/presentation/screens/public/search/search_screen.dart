// lib/presentation/screens/public/search/search_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'mobile_search_screen.dart';
import 'web_search_screen.dart';

/// Platform-aware Search Screen Router
///
/// Automatically selects the appropriate implementation:
/// - Web: WebSearchScreen (with horizontal navbar, multi-column layout, advanced filters)
/// - Mobile: MobileSearchScreen (with vertical scrolling, single column, mobile-friendly search)
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebSearchScreen();
    } else {
      return const MobileSearchScreen();
    }
  }
}