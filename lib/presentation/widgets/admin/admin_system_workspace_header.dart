import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/developer_ui_provider.dart';
import 'admin_gateway_strip.dart';
import 'admin_panel_registry.dart';

class AdminSystemWorkspaceHeader extends ConsumerWidget {
  const AdminSystemWorkspaceHeader({
    super.key,
    required this.currentRoute,
    required this.fallbackTitle,
    required this.fallbackSubtitle,
  });

  final String currentRoute;
  final String fallbackTitle;
  final String fallbackSubtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = AdminPanelRegistry.entryForRoute(currentRoute);
    final title = entry?.label ?? fallbackTitle;
    final subtitle = entry?.description ?? fallbackSubtitle;
    final showRoutes = ref.watch(developerShowRoutesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _WorkspaceChip(
                    icon: Icons.widgets_outlined,
                    label: 'الأنظمة',
                  ),
                  _WorkspaceChip(
                    icon: Icons.hub_outlined,
                    label: 'سجل مركزي موحّد',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                  height: 1.55,
                ),
              ),
              if (showRoutes) ...[
                const SizedBox(height: 10),
                SelectableText(
                  currentRoute,
                  style: const TextStyle(
                    color: Color(0xFF0F4C81),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        AdminGatewayStrip(
          title: 'الأنظمة المرتبطة',
          subtitle:
              'تنقّل بين الأنظمة الإدارية من نفس السجل المركزي بدل القوائم المتفرقة.',
          cards: AdminPanelRegistry.quickAccessForSystemPages(
            excludeRoute: currentRoute,
          ),
        ),
      ],
    );
  }
}

class _WorkspaceChip extends StatelessWidget {
  const _WorkspaceChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0F4C81)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0F4C81),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
