import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/presentation/widgets/admin/admin_system_workspace_header.dart';

class PwfPlatformServiceAdminWorkspace extends StatelessWidget {
  const PwfPlatformServiceAdminWorkspace({
    super.key,
    required this.currentRoute,
    required this.title,
    required this.subtitle,
    required this.stats,
    required this.quickActions,
    required this.workstreams,
    required this.governanceNotes,
  });

  final String currentRoute;
  final String title;
  final String subtitle;
  final List<PwfPlatformAdminStat> stats;
  final List<PwfPlatformAdminAction> quickActions;
  final List<PwfPlatformAdminPanel> workstreams;
  final List<String> governanceNotes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSystemWorkspaceHeader(
            currentRoute: currentRoute,
            fallbackTitle: title,
            fallbackSubtitle: subtitle,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: stats
                .map((item) => _StatCard(item: item))
                .toList(growable: false),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'إجراءات سريعة',
            subtitle: 'نقاط دخول أولية لاستكمال إدارة الخدمة داخل المنصة.',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: quickActions
                  .map(
                    (action) => FilledButton.icon(
                      onPressed: action.route == null
                          ? null
                          : () => context.go(action.route!),
                      icon: Icon(action.icon),
                      label: Text(action.label),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'مسارات العمل',
            subtitle:
                'المكوّنات التي يجب أن يبنى فوقها الاستكمال الإداري لاحقًا.',
            child: Column(
              children: workstreams
                  .map(
                    (panel) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _WorkstreamCard(panel: panel),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'حوكمة وملاحظات',
            subtitle: 'تذكير بما يجب أن يظل خاضعًا لعقد المنصة وسياساتها.',
            child: Column(
              children: governanceNotes
                  .map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.check_circle_outline,
                              size: 18,
                              color: Color(0xFF0F4C81),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              note,
                              style: const TextStyle(
                                color: Color(0xFF374151),
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}

class PwfPlatformAdminStat {
  const PwfPlatformAdminStat({
    required this.label,
    required this.value,
    required this.icon,
    this.hint,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? hint;
}

class PwfPlatformAdminAction {
  const PwfPlatformAdminAction({
    required this.label,
    required this.icon,
    this.route,
  });

  final String label;
  final IconData icon;
  final String? route;
}

class PwfPlatformAdminPanel {
  const PwfPlatformAdminPanel({
    required this.title,
    required this.description,
    required this.bullets,
    required this.icon,
  });

  final String title;
  final String description;
  final List<String> bullets;
  final IconData icon;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final PwfPlatformAdminStat item;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 260),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: const Color(0xFF0F4C81)),
            ),
            const SizedBox(height: 14),
            Text(
              item.value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
            if (item.hint != null) ...[
              const SizedBox(height: 6),
              Text(
                item.hint!,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF6B7280), height: 1.6),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _WorkstreamCard extends StatelessWidget {
  const _WorkstreamCard({required this.panel});

  final PwfPlatformAdminPanel panel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F4C81).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(panel.icon, color: const Color(0xFF0F4C81)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  panel.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            panel.description,
            style: const TextStyle(color: Color(0xFF4B5563), height: 1.6),
          ),
          const SizedBox(height: 10),
          ...panel.bullets.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 14,
                      color: Color(0xFFB22222),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bullet,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
