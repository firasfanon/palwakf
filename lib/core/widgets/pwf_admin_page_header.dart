import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routing/app_routes.dart';
import '../theme/palwakf_sis_breakpoints.dart';

class PwfAdminPageHeader extends StatelessWidget {
  const PwfAdminPageHeader({
    super.key,
    required this.title,
    this.actions = const [],
    this.showBackButton,
  });

  final String title;
  final List<Widget> actions;
  final bool? showBackButton;

  @override
  Widget build(BuildContext context) {
    final isMobile = PalWakfSisBreakpoints.of(context) == PalWakfSisDeviceClass.mobile;
    final shouldShowBack = showBackButton ?? isMobile;

    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (shouldShowBack) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 22),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.adminDashboard);
                }
              },
              tooltip: 'رجوع',
              style: IconButton.styleFrom(
                foregroundColor: const Color(0xFF374151),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'NotoSansArabic',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}
