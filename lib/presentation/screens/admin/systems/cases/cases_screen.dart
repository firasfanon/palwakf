import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'mobile_cases_screen.dart';
import 'web_cases_screen.dart';

class CasesScreen extends StatelessWidget {
  const CasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebCasesScreen();
    } else {
      return const MobileCasesScreen();
    }
  }
}
