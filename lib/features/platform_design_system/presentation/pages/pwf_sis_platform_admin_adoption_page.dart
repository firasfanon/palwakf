import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PwfSisPlatformAdminAdoptionPage extends StatelessWidget {
  const PwfSisPlatformAdminAdoptionPage({super.key});

  static const routePath =
      '/admin/platform/design-system/platform-admin-adoption';

  static const _pageTargets = <_AdoptionTarget>[
    _AdoptionTarget(
      title: 'Database Domain Migration',
      path:
          'lib/features/platform/database_migration/presentation/pages/pwf_database_domain_migration_page.dart',
      decision: 'N2.63',
      risk: 'low-platform-admin',
    ),
    _AdoptionTarget(
      title: 'Dynamic System Home',
      path:
          'lib/features/platform/dynamic_systems/presentation/pages/pwf_dynamic_system_home_page.dart',
      decision: 'N2.63',
      risk: 'low-platform-admin',
    ),
    _AdoptionTarget(
      title: 'Dynamic System Page',
      path:
          'lib/features/platform/dynamic_systems/presentation/pages/pwf_dynamic_system_page.dart',
      decision: 'N2.63',
      risk: 'low-platform-admin',
    ),
    _AdoptionTarget(
      title: 'Platform System Operations',
      path:
          'lib/features/platform/dynamic_systems/presentation/pages/pwf_platform_system_operations_page.dart',
      decision: 'N2.63',
      risk: 'low-platform-admin',
    ),
    _AdoptionTarget(
      title: 'Usage Guide',
      path:
          'lib/presentation/screens/admin/main/usage_guide/usage_guide_screen.dart',
      decision: 'N2.63',
      risk: 'low-platform-admin',
    ),
  ];

  static const _rules = <String>[
    'هذه الدفعة لا تلمس Media Center runtime ولا الخدمات ولا الأنظمة الحساسة.',
    'الترحيل يكون لعائلة Platform Admin منخفضة المخاطر فقط.',
    'أي صفحة لا تطابق قواعد PWF-SIS تسجل في evidence ولا ترحل بصمت.',
    'لا SQL ولا Database Wave B ولا تعديل waqf_assets.',
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;

    return Scaffold(
      appBar: AppBar(title: const Text('PWF-SIS — اعتماد صفحات إدارة المنصة')),
      body: ListView(
        padding: EdgeInsets.all(compact ? 16 : 24),
        children: [
          _Hero(compact: compact),
          const SizedBox(height: 16),
          const _Metrics(),
          const SizedBox(height: 16),
          _Panel(
            title: 'صفحات N2.63 المرشحة',
            subtitle:
                'هذه الصفحات مصنفة low-platform-admin حسب جرد N2.62، وهي أول عائلة ترحيل جماعي.',
            children: [
              for (final target in _pageTargets) ...[
                _TargetCard(target: target),
                if (target != _pageTargets.last) const SizedBox(height: 10),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'قواعد الاعتماد',
            subtitle:
                'تمنع هذه القواعد تحويل التعميم إلى تصليح صفحة بصفحة أو لمس الأنظمة الحساسة.',
            children: [
              for (final rule in _rules)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: Color(0xFF047857),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rule,
                          style: const TextStyle(
                            height: 1.45,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 18 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3A70),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Chip(
            label: 'N2.63 Bulk Migration',
            icon: Icons.dashboard_customize_outlined,
            inverse: true,
          ),
          const SizedBox(height: 14),
          Text(
            'اعتماد PWF-SIS لصفحات إدارة المنصة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'هذه الصفحة تجمع نتائج جرد N2.62 وتثبت أن الترحيل الأول محصور في صفحات Platform Admin منخفضة المخاطر فقط.',
            style: TextStyle(color: Color(0xFFE0F2FE), height: 1.6),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => context.go('/admin/platform/design-system'),
                icon: const Icon(Icons.palette_outlined),
                label: const Text('نظام الواجهات'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go(
                  '/admin/platform/design-system/wave-2-media-inventory',
                ),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('جرد Wave 2'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics();

  @override
  Widget build(BuildContext context) {
    const metrics = [
      _Metric('صفحات مرشحة', '5', Icons.description_outlined),
      _Metric('مسارات مرشحة', '13', Icons.route_outlined),
      _Metric('نطاق المخاطر', 'منخفض', Icons.verified_user_outlined),
      _Metric('الإنتاج', 'غير معتمد', Icons.gpp_maybe_outlined),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1050
            ? 4
            : constraints.maxWidth >= 720
            ? 2
            : 1;
        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - 12 * (columns - 1)) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: width,
                child: _MetricCard(metric: metric),
              ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(metric.icon, color: const Color(0xFF0B3A70)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF64748B), height: 1.5),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({required this.target});

  final _AdoptionTarget target;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final body = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                target.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                target.path,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(label: target.risk, icon: Icons.shield_outlined),
                  _Chip(label: target.decision, icon: Icons.flag_outlined),
                ],
              ),
            ],
          );

          const status = _Chip(
            label: 'جاهز للاعتماد',
            icon: Icons.check_circle_outline,
            color: Color(0xFF047857),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [body, const SizedBox(height: 10), status],
            );
          }

          return Row(
            children: [
              Expanded(child: body),
              const SizedBox(width: 12),
              status,
            ],
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    this.color = const Color(0xFF0B3A70),
    this.inverse = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final fg = inverse ? Colors.white : color;
    final bg = inverse
        ? Colors.white.withValues(alpha: 0.12)
        : color.withValues(alpha: 0.08);

    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdoptionTarget {
  const _AdoptionTarget({
    required this.title,
    required this.path,
    required this.decision,
    required this.risk,
  });

  final String title;
  final String path;
  final String decision;
  final String risk;
}

class _Metric {
  const _Metric(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}
