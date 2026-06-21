import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routing/app_routes.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/widgets/web/web_sidebar.dart';
import '../../../core/layout/pwf_global_layout_contract.dart';
import 'pwf_admin_operational_context_bar.dart';

/// Platform admin shell wrapper.
/// IMPORTANT: Sidebar must be rendered ONLY here (single unified sidebar).
/// Admin pages must be content-only (no nested sidebars).
class PlatformAdminShell extends ConsumerWidget {
  final Widget child;
  final String location;

  const PlatformAdminShell({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.of(context).size.width;

    // Mobile/Small: keep route content bounded without fixed sidebar.
    if (w < PwfGlobalLayoutContract.adminShellBreakpoint) {
      return Material(
        color: PwfGlobalLayoutContract.pageBackground,
        child: Column(
          children: [
            PwfAdminOperationalContextBar(location: location, compact: true),
            Expanded(child: PwfAdminRouteBoundary(child: child)),
          ],
        ),
      );
    }

    final user = ref.watch(currentUserProvider);

    // The desktop shell owns a shared Material boundary. WebSidebar contains
    // PopupMenuButton, IconButton and InkWell controls; placing the boundary
    // here keeps every shell-level interactive control inside Material without
    // changing routes, access rules or page content.
    return Material(
      color: const Color(0xFFF8FAFC),
      child: Row(
        children: [
          WebSidebar(currentRoute: location),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                _AdminTopStrip(currentUser: user),
                PwfAdminOperationalContextBar(location: location),
                Expanded(child: PwfAdminRouteBoundary(child: child)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTopStrip extends ConsumerWidget {
  const _AdminTopStrip({required this.currentUser});

  final dynamic currentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName =
        (currentUser?.displayName ?? currentUser?.name ?? 'مستخدم').toString();
    final username = (currentUser?.username ?? '').toString().trim();
    final scopeLabel =
        (currentUser?.scopeLabel ??
                currentUser?.unitNameAr ??
                currentUser?.department ??
                'مركزي')
            .toString();
    final roleLabel =
        (currentUser?.operationalRoleLabelAr ??
                (currentUser?.role ?? '').toString())
            .toString();

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: const Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: Color(0xFF0F4C81),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (roleLabel.trim().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FE),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          roleLabel,
                          style: const TextStyle(
                            color: Color(0xFF0F4C81),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${username.isNotEmpty ? '@$username — ' : ''}الوحدة: $scopeLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.home);
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
