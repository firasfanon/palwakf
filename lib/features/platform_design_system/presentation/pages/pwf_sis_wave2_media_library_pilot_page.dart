import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';

class PwfSisWave2MediaLibraryPilotPage extends StatelessWidget {
  const PwfSisWave2MediaLibraryPilotPage({super.key});

  static const routePath =
      '/admin/platform/design-system/wave-2/media-library-pilot';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    final padding = compact ? 16.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PWF-SIS — Pilot مكتبة المواد الإعلامية'),
      ),
      body: ListView(
        padding: EdgeInsets.all(padding),
        children: [
          _HeroBlock(compact: compact),
          const SizedBox(height: 16),
          _MetricsGrid(compact: compact),
          const SizedBox(height: 16),
          const _DecisionBlock(),
          const SizedBox(height: 16),
          const _PreviewItemsBlock(),
          const SizedBox(height: 16),
          const _GateRulesBlock(),
        ],
      ),
    );
  }
}

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          onPressed: () => context.go(AppRoutes.adminMediaCenterMediaLibrary),
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('فتح الصفحة التشغيلية الأصلية'),
        ),
        OutlinedButton.icon(
          onPressed: () => context.go(
            '/admin/platform/design-system/wave-2-media-inventory',
          ),
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('جرد Wave 2'),
        ),
      ],
    );

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
          const _SoftChip(
            label: 'Wave 2 Separate Pilot',
            icon: Icons.route_outlined,
            inverse: true,
          ),
          const SizedBox(height: 14),
          Text(
            'Pilot بصري منفصل لمكتبة المواد الإعلامية',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'هذه الصفحة ليست صفحة التشغيل الأصلية. الغرض هو اختبار PWF-SIS بصريًا وبوضع قراءة فقط دون تعطيل عمل المركز الإعلامي أو تعديل بياناته.',
            style: TextStyle(color: Color(0xFFE0F2FE), height: 1.6),
          ),
          const SizedBox(height: 18),
          actions,
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    const metrics = [
      _PilotMetric('نطاق التجربة', 'منفصل', Icons.call_split_outlined),
      _PilotMetric('إجراءات كتابة', '0', Icons.lock_outline),
      _PilotMetric('التشغيل الأصلي', 'محفوظ', Icons.verified_outlined),
      _PilotMetric('الإنتاج', 'غير معتمد', Icons.gpp_maybe_outlined),
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

  final _PilotMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
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

class _DecisionBlock extends StatelessWidget {
  const _DecisionBlock();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'قرار N2.61 SuperBatch',
      subtitle:
          'تجميع دفعات PWF-SIS المتبقية في مسار واحد: تثبيت الفصل بين التشغيل والـ Pilot، تجهيز evidence gate، وعدم توسيع Wave 2 قبل الاختبار.',
      children: const [
        _Notice(
          title: 'حفظ التشغيل الأصلي',
          message:
              'تبقى /admin/media-center/media-library صفحة تشغيلية كاملة حسب صلاحيات المركز الإعلامي.',
          color: Color(0xFF047857),
          icon: Icons.check_circle_outline,
        ),
        SizedBox(height: 12),
        _Notice(
          title: 'Pilot منفصل',
          message:
              'هذا المسار مخصص للمعاينة البصرية فقط ولا ينفذ أي إضافة أو تحرير أو نشر أو أرشفة أو حذف.',
          color: Color(0xFFB45309),
          icon: Icons.visibility_outlined,
        ),
      ],
    );
  }
}

class _PreviewItemsBlock extends StatelessWidget {
  const _PreviewItemsBlock();

  @override
  Widget build(BuildContext context) {
    const items = [
      _PilotItem('حزمة الهوية البصرية الرسمية', 'Brand Kit', 'الإعلام المركزي'),
      _PilotItem('قالب خبر رسمي معتمد', 'Template', 'فريق التحرير'),
      _PilotItem('دليل استخدام المواد الإعلامية', 'Guide', 'حوكمة المركز'),
    ];

    return _Panel(
      title: 'معاينة مواد إعلامية — قراءة فقط',
      subtitle:
          'بيانات توضيحية لا ترتبط بعمليات إنتاجية، وتستخدم فقط لاختبار layout وresponsive.',
      children: [
        for (final item in items) ...[
          _PilotItemCard(item: item),
          if (item != items.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _PilotItemCard extends StatelessWidget {
  const _PilotItemCard({required this.item});

  final _PilotItem item;

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
          final textBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SoftChip(label: item.kind, icon: Icons.category_outlined),
                  _SoftChip(label: item.owner, icon: Icons.apartment_outlined),
                  const _SoftChip(
                    label: 'قراءة فقط',
                    icon: Icons.visibility_outlined,
                    color: Color(0xFF92400E),
                  ),
                ],
              ),
            ],
          );

          const mask = _SoftChip(
            label: 'إجراءات الكتابة غير موجودة',
            icon: Icons.lock_outline,
            color: Color(0xFFB45309),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [textBlock, const SizedBox(height: 10), mask],
            );
          }

          return Row(
            children: [
              Expanded(child: textBlock),
              const SizedBox(width: 12),
              mask,
            ],
          );
        },
      ),
    );
  }
}

class _GateRulesBlock extends StatelessWidget {
  const _GateRulesBlock();

  @override
  Widget build(BuildContext context) {
    const rules = [
      'المسار التشغيلي الأصلي يبقى: /admin/media-center/media-library.',
      'المسار التجريبي المنفصل هو: /admin/platform/design-system/wave-2/media-library-pilot.',
      'أي write affordance يظهر في Pilot يعتبر blocker قبل توسيع Wave 2.',
      'لا SQL، لا Database Wave B، ولا تعديل waqf_assets ضمن هذه الدفعة.',
    ];

    return _Panel(
      title: 'بوابة منع الخلط بين Pilot والتشغيل',
      subtitle:
          'قواعد تمنع أن يتحول الاختبار البصري إلى تعطيل صفحة تشغيلية أو تعديل بيانات.',
      children: [
        for (final rule in rules)
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

class _SoftChip extends StatelessWidget {
  const _SoftChip({
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

class _PilotMetric {
  const _PilotMetric(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _PilotItem {
  const _PilotItem(this.title, this.kind, this.owner);

  final String title;
  final String kind;
  final String owner;
}
