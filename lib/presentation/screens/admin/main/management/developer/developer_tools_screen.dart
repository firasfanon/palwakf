import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/presentation/providers/developer_ui_provider.dart';
import 'package:waqf/presentation/widgets/admin/admin_panel_registry.dart';

enum _PlatformDevelopmentTodoStatus { done, active, deferred }

extension _PlatformDevelopmentTodoStatusX on _PlatformDevelopmentTodoStatus {
  String get labelAr {
    switch (this) {
      case _PlatformDevelopmentTodoStatus.done:
        return 'منجز';
      case _PlatformDevelopmentTodoStatus.active:
        return 'قيد المتابعة';
      case _PlatformDevelopmentTodoStatus.deferred:
        return 'مؤجل';
    }
  }

  Color get color {
    switch (this) {
      case _PlatformDevelopmentTodoStatus.done:
        return const Color(0xFF047857);
      case _PlatformDevelopmentTodoStatus.active:
        return const Color(0xFFB45309);
      case _PlatformDevelopmentTodoStatus.deferred:
        return const Color(0xFF64748B);
    }
  }
}

class _PlatformDevelopmentTodoItem {
  const _PlatformDevelopmentTodoItem({
    required this.title,
    required this.description,
    required this.status,
  });

  final String title;
  final String description;
  final _PlatformDevelopmentTodoStatus status;
}

class _PlatformDevelopmentMetric {
  const _PlatformDevelopmentMetric({
    required this.label,
    required this.value,
    required this.description,
    required this.icon,
  });

  final String label;
  final String value;
  final String description;
  final IconData icon;
}

const _platformDevelopmentAnalyzerMetrics = <_PlatformDevelopmentMetric>[
  _PlatformDevelopmentMetric(
    label: 'أخطاء التحليل',
    value: '0',
    description: 'لا توجد أخطاء error في آخر تحليل محلي مستلم.',
    icon: Icons.check_circle_outline_rounded,
  ),
  _PlatformDevelopmentMetric(
    label: 'تحذيرات وملاحظات',
    value: '112',
    description: 'تحذيرات info/warning مؤجلة حتى لا تعطل التطوير الوظيفي.',
    icon: Icons.fact_check_outlined,
  ),
  _PlatformDevelopmentMetric(
    label: 'حالة المسار',
    value: 'مستقر',
    description: 'تم إغلاق الأخطاء المانعة واستئناف التطوير التشغيلي.',
    icon: Icons.verified_outlined,
  ),
];

const _platformDevelopmentTodoItems = <_PlatformDevelopmentTodoItem>[
  _PlatformDevelopmentTodoItem(
    title: 'إغلاق أخطاء analyzer المانعة',
    description:
        'إغلاق platformViewRegistry، AsyncValue، AccessProfile.email، وrememberMe nullable.',
    status: _PlatformDevelopmentTodoStatus.done,
  ),
  _PlatformDevelopmentTodoItem(
    title: 'تثبيت TODO فعلي داخل المشروع',
    description:
        'تسجيل المنجزات والقرارات داخل docs/platform/todo وليس في المحادثة فقط.',
    status: _PlatformDevelopmentTodoStatus.done,
  ),
  _PlatformDevelopmentTodoItem(
    title: 'استئناف التطوير الوظيفي',
    description:
        'العودة لتطوير صفحات المنصة والواجهة العامة بعد استقرار الأخطاء المانعة.',
    status: _PlatformDevelopmentTodoStatus.active,
  ),
  _PlatformDevelopmentTodoItem(
    title: 'تنظيف التحذيرات غير المانعة',
    description:
        'تنظيف deprecated/info/warning على دفعات لاحقة دون ترقية حزم أو تغيير معماري واسع.',
    status: _PlatformDevelopmentTodoStatus.deferred,
  ),
  _PlatformDevelopmentTodoItem(
    title: 'UAT المتصفح حسب الدور',
    description:
        'اختبار السايدبار والمركز الإعلامي ومركز الخدمات والواجهة العامة بعد كل حزمة تشغيلية.',
    status: _PlatformDevelopmentTodoStatus.active,
  ),
];

class DeveloperToolsScreen extends ConsumerWidget {
  const DeveloperToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showRoutes = ref.watch(developerShowRoutesProvider);
    final showPageNames = ref.watch(developerShowPageNamesProvider);
    final entries = AdminPanelRegistry.allEntries;

    String buildExport() {
      final lines = <String>['PalWakf Admin Routes'];
      for (final group in AdminPanelRegistry.orderedGroups) {
        lines.add('');
        lines.add('[${group.title}]');
        for (final item in group.items) {
          lines.add('- ${item.label} => ${item.route}');
        }
      }
      return lines.join('\n');
    }

    String buildDevelopmentSummary() {
      final lines = <String>[
        'PalWakf Platform Development TODO',
        'Status: analyzer errors closed / functional development resumed',
        '',
        '[Analyzer]',
        for (final metric in _platformDevelopmentAnalyzerMetrics)
          '- ${metric.label}: ${metric.value} — ${metric.description}',
        '',
        '[TODO]',
        for (final item in _platformDevelopmentTodoItems)
          '- [${item.status.labelAr}] ${item.title}: ${item.description}',
      ];
      return lines.join('\n');
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المطور')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1220),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF1F2A44)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.developer_mode_rounded,
                        color: Color(0xFFEAB308),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'أدوات المطور والصيانة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'فعّل هذا الوضع لإظهار أسماء الصفحات ومساراتها داخل السايد بار ومساحات الوصول السريع، بهدف تسهيل الصيانة وتتبع الأخطاء والتنقل بين شاشات لوحة التحكم.',
                    style: TextStyle(color: Color(0xFFCBD5E1), height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _ToggleCard(
                        title: 'إظهار أسماء الصفحات',
                        subtitle:
                            'إظهار أسماء الشاشات والعناوين التنظيمية داخل عناصر التنقل.',
                        value: showPageNames,
                        onChanged: (v) =>
                            ref
                                    .read(
                                      developerShowPageNamesProvider.notifier,
                                    )
                                    .state =
                                v,
                        icon: Icons.title_rounded,
                      ),
                      _ToggleCard(
                        title: 'إظهار المسارات',
                        subtitle:
                            'إظهار route لكل شاشة داخل السايد بار وبطاقات الوصول السريع.',
                        value: showRoutes,
                        onChanged: (v) =>
                            ref
                                    .read(developerShowRoutesProvider.notifier)
                                    .state =
                                v,
                        icon: Icons.route_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: buildExport()),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'تم نسخ سجل أسماء الصفحات ومساراتها.',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy_all_rounded),
                        label: const Text('نسخ سجل الصفحات'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: buildDevelopmentSummary()),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم نسخ ملخص TODO التشغيلي.'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.assignment_turned_in_outlined),
                        label: const Text('نسخ TODO التشغيلي'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          ref
                                  .read(developerShowPageNamesProvider.notifier)
                                  .state =
                              true;
                          ref.read(developerShowRoutesProvider.notifier).state =
                              true;
                        },
                        icon: const Icon(Icons.visibility_rounded),
                        label: const Text('إظهار الكل'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          ref
                                  .read(developerShowPageNamesProvider.notifier)
                                  .state =
                              false;
                          ref.read(developerShowRoutesProvider.notifier).state =
                              false;
                        },
                        icon: const Icon(Icons.visibility_off_rounded),
                        label: const Text('إخفاء الكل'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _PlatformDevelopmentProgressPanel(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'فهرس صفحات لوحة التحكم',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'إجمالي العناصر المسجلة: ${entries.length}',
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 14),
                  for (final group in AdminPanelRegistry.orderedGroups) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.title,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          for (final item in group.items)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 18,
                                    color: const Color(0xFF0F4C81),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.label,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.route,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformDevelopmentProgressPanel extends StatelessWidget {
  const _PlatformDevelopmentProgressPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.assignment_turned_in_outlined,
                color: Color(0xFF0F4C81),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'سجل التطوير التشغيلي الحالي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'هذه بطاقة تشغيلية مختصرة لتثبيت ما أُغلق فعليًا بعد التحليل المحلي، وما يبقى قيد المتابعة دون تعطيل التطوير الوظيفي.',
            style: TextStyle(color: Color(0xFF64748B), height: 1.6),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final metric in _platformDevelopmentAnalyzerMetrics)
                _DevelopmentMetricCard(metric: metric),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              for (final item in _platformDevelopmentTodoItems)
                _DevelopmentTodoRow(item: item),
            ],
          ),
        ],
      ),
    );
  }
}

class _DevelopmentMetricCard extends StatelessWidget {
  const _DevelopmentMetricCard({required this.metric});

  final _PlatformDevelopmentMetric metric;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(metric.icon, color: const Color(0xFF0F4C81), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      metric.label,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                metric.value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                metric.description,
                style: const TextStyle(color: Color(0xFF64748B), height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DevelopmentTodoRow extends StatelessWidget {
  const _DevelopmentTodoRow({required this.item});

  final _PlatformDevelopmentTodoItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: item.status.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: item.status.color.withValues(alpha: 0.24),
              ),
            ),
            child: Text(
              item.status.labelAr,
              style: TextStyle(
                color: item.status.color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(color: Color(0xFF64748B), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  const _ToggleCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1F2937)),
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
                    color: const Color(0xFFEAB308).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFFEAB308)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Switch(value: value, onChanged: onChanged),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFFCBD5E1), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
