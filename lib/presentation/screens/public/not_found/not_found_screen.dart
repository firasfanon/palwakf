import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'mobile_not_found_screen.dart';
import 'web_not_found_screen.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebNotFoundScreen ();
    } else {
      return const MobileNotFoundScreen();
    }
  }
}
