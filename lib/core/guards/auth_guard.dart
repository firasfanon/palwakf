// lib/core/guards/auth_guard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../app/routing/app_routes.dart';

class AuthGuard {
  /// Check if user is authenticated, redirect to login if not
  static Future<bool> checkAuth(BuildContext context, WidgetRef ref) async {
    final isAuthenticated = ref.read(isAuthenticatedProvider);

    if (!isAuthenticated) {
      // Redirect to login
      await AppRoutes.pushAndClearStack(context, AppRoutes.adminLogin);
      return false;
    }

    return true;
  }

  /// Check if user is admin
  static bool checkAdmin(WidgetRef ref) {
    return ref.read(isAdminProvider);
  }
}