import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PwfSisMediaCenterLowRiskAdoptionPage extends StatelessWidget {
  const PwfSisMediaCenterLowRiskAdoptionPage({super.key});

  static const routePath =
      '/admin/platform/design-system/media-center-low-risk-adoption';

  static const _routes = <_MediaCenterRouteTarget>[
    _MediaCenterRouteTarget(
      title: 'حوكمة المركز الإعلامي',
      route: '/admin/media-center/governance',
      risk: 'low-risk/read-only',
      decision: 'adopt-first',
      note: 'سطح حوكمة ومعلومات، لا يغير workflow.',
      icon: Icons.gpp_good_outlined,
    ),
    _MediaCenterRouteTarget(
      title: 'لوحة المركز الإعلامي',
      route: '/admin/media-center',
      risk: 'low-risk/dashboard',
      decision: 'adopt-first',
      note: 'مؤشرات وروابط؛ مناسب لتوحيد layout.',
      icon: Icons.dashboard_customize_outlined,
    ),
    _MediaCenterRouteTarget(
      title: 'مكتبة المواد الإعلامية',
      route: '/admin/media-center/media-library',
      risk: 'operational-preserved',
      decision: 'preserve-runtime',
      note: 'تبقى تشغيلية، ولا تتحول إلى read-only.',
      icon: Icons.folder_special_outlined,
    ),
    _MediaCenterRouteTarget(
      title: 'معرض الصور',
      route: '/admin/media-center/photos',
      risk: 'media-workspace',
      decision: 'adopt-after-console-check',
      note: 'تطبيق PWF-SIS دون تغيير upload/edit workflow.',
      icon: Icons.image_outlined,
    ),
    _MediaCenterRouteTarget(
      title: 'إدارة الفيديوهات',
      route: '/admin/media-center/videos',
      risk: 'media-workspace',
      decision: 'adopt-after-console-check',
      note: 'تطبيق بصري فقط دون تغيير الروابط أو النشر.',
      icon: Icons.video_library_outlined,
    ),
    _MediaCenterRouteTarget(
      title: 'جرد Wave 2',
      route: '/admin/platform/design-system/wave-2-media-inventory',
      risk: 'evidence',
      decision: 'already-pilot',
      note: 'صفحة جرد وأدلة ضمن PWF-SIS.',
      icon: Icons.inventory_2_outlined,
    ),
  ];

  static const _rules = <String>[
    'N2.64 لا يغير منطق النشر أو الأرشفة أو الحذف.',
    'الصفحات التشغيلية تبقى تحت RBAC الأصلي للمركز الإعلامي.',
    'PWF-SIS يطبق على الواجهة والتنظيم والاستجابة فقط.',
    'أي overflow أو console exception يمنع إغلاق الدفعة.',
    'لا SQL ولا Database Wave B ولا تعديل waqf_assets.',
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PWF-SIS — اعتماد المركز الإعلامي منخفض المخاطر'),
      ),
      body: ListView(
        padding: EdgeInsets.all(compact ? 16 : 24),
        children: [
          _Hero(compact: compact),
          const SizedBox(height: 16),
          const _Metrics(),
          const SizedBox(height: 16),
          _Panel(
            title: 'مسارات المركز الإعلامي ضمن N2.64',
            subtitle:
                'هذه الدفعة تجمع أسطح المركز الإعلامي منخفضة المخاطر وتثبت حدود الترحيل دون تغيير workflow.',
            children: [
              for (final target in _routes) ...[
                _RouteTargetCard(target: target),
                if (target != _routes.last) const SizedBox(height: 10),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'قواعد الترحيل',
            subtitle:
                'التطبيق هنا هو اعتماد بصري/تجريبي محكوم؛ ليس تفويضًا لتغيير إجراءات النشر.',
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
          const SizedBox(height: 16),
          _Panel(
            title: 'قرار N2.64',
            subtitle:
                'يُسمح بتعميم PWF-SIS على الأسطح منخفضة المخاطر فقط بعد evidence محلي نظيف.',
            children: const [
              _Notice(
                title: 'مسموح',
                message:
                    'حوكمة/لوحات/جرد/تنظيم بصري واستجابة على أسطح منخفضة المخاطر.',
                color: Color(0xFF047857),
                icon: Icons.check_circle_outline,
              ),
              SizedBox(height: 12),
              _Notice(
                title: 'محظور',
                message:
                    'تغيير publish/archive/delete/upload workflow أو تنفيذ SQL أو Database Wave B.',
                color: Color(0xFFB91C1C),
                icon: Icons.block_outlined,
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
            label: 'N2.64 Media Center Low-Risk',
            icon: Icons.photo_library_outlined,
            inverse: true,
          ),
          const SizedBox(height: 14),
          Text(
            'اعتماد PWF-SIS لأسطح المركز الإعلامي منخفضة المخاطر',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'هذه الدفعة لا تعطل التشغيل ولا تغير سير النشر؛ هدفها توحيد الواجهة، الاستجابة، وحواجز الأدلة قبل أي توسع.',
            style: TextStyle(color: Color(0xFFE0F2FE), height: 1.6),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => context.go('/admin/media-center/governance'),
                icon: const Icon(Icons.gpp_good_outlined),
                label: const Text('حوكمة المركز'),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    context.go('/admin/media-center/media-library'),
                icon: const Icon(Icons.folder_special_outlined),
                label: const Text('المكتبة التشغيلية'),
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
      _Metric('مسارات مراجعة', '6', Icons.route_outlined),
      _Metric('Workflow mutation', '0', Icons.lock_outline),
      _Metric('نطاق الدفعة', 'منخفض', Icons.verified_user_outlined),
      _Metric('الإنتاج', 'غير معتمد', Icons.gpp_maybe_outlined),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1050
            ? 4
            : constraints.maxWidth >= 720
            ? 2
            : 1;
        final itemWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - 12 * (columns - 1)) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: itemWidth,
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

class _RouteTargetCard extends StatelessWidget {
  const _RouteTargetCard({required this.target});

  final _MediaCenterRouteTarget target;

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
                target.route,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                target.note,
                style: const TextStyle(color: Color(0xFF334155), height: 1.45),
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

          final action = FilledButton.tonalIcon(
            onPressed: () => context.go(target.route),
            icon: Icon(target.icon),
            label: const Text('فتح'),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [body, const SizedBox(height: 10), action],
            );
          }

          return Row(
            children: [
              Expanded(child: body),
              const SizedBox(width: 12),
              action,
            ],
          );
        },
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
  });

  final String title;
  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(color: color, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon, this.inverse = false});

  final String label;
  final IconData icon;
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final fg = inverse ? Colors.white : const Color(0xFF0B3A70);
    final bg = inverse
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFF0B3A70).withValues(alpha: 0.08);

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

class _MediaCenterRouteTarget {
  const _MediaCenterRouteTarget({
    required this.title,
    required this.route,
    required this.risk,
    required this.decision,
    required this.note,
    required this.icon,
  });

  final String title;
  final String route;
  final String risk;
  final String decision;
  final String note;
  final IconData icon;
}

class _Metric {
  const _Metric(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}
