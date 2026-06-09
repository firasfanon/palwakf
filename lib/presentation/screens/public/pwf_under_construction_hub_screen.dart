import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';

/// Web-only replacement for the legacy under-construction screen.
/// Provides quick navigation to completed public pages so users don't get stuck.
class PwfUnderConstructionHubScreen extends StatelessWidget {
  const PwfUnderConstructionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قيد الإنشاء'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.handyman, size: 42),
                  const SizedBox(height: 12),
                  const Text(
                    'هذه الصفحة قيد التطوير',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'يمكنك الانتقال مباشرة إلى الصفحات المنجزة:',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _NavButton(
                    label: 'وحدة الشكاوى',
                    icon: Icons.report_gmailerrorred,
                    onTap: () => context.go(AppRoutes.complaints),
                  ),
                  const SizedBox(height: 10),
                  _NavButton(
                    label: 'مواقيت الصلاة',
                    icon: Icons.schedule,
                    onTap: () => context.go(AppRoutes.prayerTimes),
                  ),
                  const SizedBox(height: 10),
                  _NavButton(
                    label: 'التبرع للأوقاف (الزكاة)',
                    icon: Icons.volunteer_activism,
                    onTap: () => context.go(AppRoutes.zakat),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: const Icon(Icons.home),
                    label: const Text('العودة للرئيسية'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
    );
  }
}
