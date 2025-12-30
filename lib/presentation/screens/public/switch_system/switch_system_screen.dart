import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/constants/app_constants.dart';

/// A lightweight transition screen shown when the user moves
/// from the public website to another service system.
///
/// Example route: /switch/mustakshif
class SwitchSystemScreen extends StatefulWidget {
  final String systemKeySlug;

  const SwitchSystemScreen({
    super.key,
    required this.systemKeySlug,
  });

  @override
  State<SwitchSystemScreen> createState() => _SwitchSystemScreenState();
}

class _SwitchSystemScreenState extends State<SwitchSystemScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Small delay to communicate the transition without feeling like a splash.
    _timer = Timer(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      context.go(_destinationFor(widget.systemKeySlug));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _titleFor(widget.systemKeySlug);
    final subtitle = 'جارٍ فتح النظام الخدمي…';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppConstants.islamicGreen.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.open_in_new,
                      size: 40,
                      color: AppConstants.islamicGreen,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppConstants.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  if (kIsWeb) ...[
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.home),
                      child: const Text('العودة للموقع الرئيسي'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _titleFor(String slug) {
    switch (slug.trim().toLowerCase()) {
      case 'mustakshif':
        return 'مستكشف الوقف';
      case 'admin-data':
        return 'البيانات الإدارية';
      case 'lands':
        return 'نظام الأراضي';
      case 'properties':
        return 'نظام الأملاك';
      case 'cases':
        return 'نظام القضايا';
      case 'tasks':
        return 'نظام المهام';
      case 'mosques':
        return 'نظام المساجد';
      case 'billing':
        return 'نظام الفوترة';
      default:
        return 'نظام الخدمات';
    }
  }

  static String _destinationFor(String slug) {
    switch (slug.trim().toLowerCase()) {
      case 'mustakshif':
        return AppRoutes.mustakshif;
      case 'admin-data':
        return AppRoutes.adminData;
      case 'lands':
        return AppRoutes.lands;
      case 'properties':
        return AppRoutes.properties;
      case 'cases':
        return AppRoutes.cases;
      case 'tasks':
        return AppRoutes.tasks;
      case 'mosques':
        return AppRoutes.mosquesSystem;
      case 'billing':
        return AppRoutes.billing;
      default:
        return AppRoutes.home;
    }
  }
}
