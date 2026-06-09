import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PwfSisServicesPlatformContentAdoptionPage extends StatelessWidget {
  const PwfSisServicesPlatformContentAdoptionPage({super.key});

  static const routePath =
      '/admin/platform/design-system/services-platform-content-adoption';

  static const _targets = <_Target>[
    _Target(
      'مركز الخدمات',
      'platform_services',
      '/admin/platform/services',
      'medium-operational',
      'workflow-guard-required',
      'ترحيل بصري فقط مع الحفاظ على submit/transition/track workflow كما هو.',
      Icons.room_service_outlined,
    ),
    _Target(
      'طلبات الخدمات',
      'service_requests',
      '/admin/platform/services/requests',
      'workflow-sensitive',
      'role-uat-required',
      'لا تغيير لحالات الطلبات أو انتقالاتها؛ التعديل في layout فقط.',
      Icons.assignment_outlined,
    ),
    _Target(
      'نماذج الخدمات',
      'service_forms_registry',
      '/admin/platform/services/forms',
      'medium-operational',
      'console-check-required',
      'الحفاظ على سجل النماذج وقراءة RPCs دون تغيير العقود.',
      Icons.dynamic_form_outlined,
    ),
    _Target(
      'محتوى مراكز المنصة',
      'platform_content',
      '/admin/platform/centers',
      'editorial-workflow',
      'workflow-guard-required',
      'الحفاظ على draft/review/publish/archive وعدم تغيير visibility.',
      Icons.article_outlined,
    ),
    _Target(
      'عقود التكامل بين الأنظمة',
      'integration_contracts',
      '/admin/platform/cross-system-contracts',
      'read-only-contract',
      'adopt-first',
      'سطح read-only مناسب لأسلوب PWF-SIS دون تعديل العقود.',
      Icons.hub_outlined,
    ),
  ];

  static const _rules = <String>[
    'لا تغيير submit_request أو transition_request أو track_request.',
    'لا تغيير draft/review/publish/archive في platform_content.',
    'لا تعديل public visibility ولا SQL ولا Database Wave B.',
    'أي workflow أو RBAC تغيير خارج النطاق ويمنع إغلاق الدفعة.',
  ];

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Scaffold(
      appBar: AppBar(title: const Text('PWF-SIS — الخدمات ومحتوى المنصة')),
      body: ListView(
        padding: EdgeInsets.all(compact ? 16 : 24),
        children: [
          _Hero(compact: compact),
          const SizedBox(height: 16),
          const _Metrics(),
          const SizedBox(height: 16),
          _Panel(
            title: 'عائلات N2.65',
            subtitle:
                'ترحيل واجهات الخدمات ومحتوى المنصة مع حماية workflow وRBAC.',
            children: [
              for (final target in _targets) ...[
                _TargetCard(target: target),
                if (target != _targets.last) const SizedBox(height: 10),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'حواجز workflow',
            subtitle: 'اعتماد PWF-SIS ليس موافقة على تغيير عقود التشغيل.',
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
          const _DecisionPanel(),
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
      padding: EdgeInsets.all(compact ? 18 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3A70),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Chip(
            label: 'N2.65 Services + Platform Content',
            icon: Icons.account_tree_outlined,
            inverse: true,
          ),
          const SizedBox(height: 14),
          Text(
            'اعتماد PWF-SIS للخدمات ومحتوى المنصة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'ضبط واجهات الخدمات ومحتوى المنصة دون تغيير عقود RPC أو سير الطلبات أو النشر.',
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
                  '/admin/platform/design-system/media-center-low-risk-adoption',
                ),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('N2.64'),
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
      _Metric('عائلات مراجعة', '5', Icons.account_tree_outlined),
      _Metric('Workflow mutation', '0', Icons.lock_outline),
      _Metric('نطاق المخاطر', 'متوسط', Icons.verified_user_outlined),
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
  final _Target target;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  _Chip(
                    label: target.family,
                    icon: Icons.account_tree_outlined,
                  ),
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

class _DecisionPanel extends StatelessWidget {
  const _DecisionPanel();

  @override
  Widget build(BuildContext context) {
    return const _Panel(
      title: 'قرار N2.65',
      subtitle: 'اعتماد مشروط بعد format/analyzer/browser evidence.',
      children: [
        _Notice(
          title: 'مسموح',
          message: 'تحسين layout والبطاقات والتنظيم والـ responsive.',
          color: Color(0xFF047857),
          icon: Icons.check_circle_outline,
        ),
        SizedBox(height: 12),
        _Notice(
          title: 'محظور',
          message:
              'تغيير workflow أو RPC contracts أو public visibility أو SQL.',
          color: Color(0xFFB91C1C),
          icon: Icons.block_outlined,
        ),
      ],
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

class _Target {
  const _Target(
    this.title,
    this.family,
    this.route,
    this.risk,
    this.decision,
    this.note,
    this.icon,
  );

  final String title;
  final String family;
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
