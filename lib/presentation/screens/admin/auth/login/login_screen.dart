// lib/presentation/screens/admin/login_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:waqf/features/platform/access/presentation/pages/pwf_platform_login_page.dart';
import 'mobile_login_screen.dart';
import 'web_login_screen.dart';

/// Platform-aware Admin Login Screen Router
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const PwfPlatformLoginPage(child: WebLoginScreen());
    } else {
      return const PwfPlatformLoginPage(child: MobileLoginScreen());
    }
  }
}
