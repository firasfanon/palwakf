// lib/presentation/screens/admin/login_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'mobile_login_screen.dart';
import 'web_login_screen.dart';

/// Platform-aware Admin Login Screen Router
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const WebLoginScreen();
    } else {
      return const MobileLoginScreen();
    }
  }
}