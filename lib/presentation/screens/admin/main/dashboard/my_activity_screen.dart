import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/user_dashboard_provider.dart';

class MyActivityScreen extends ConsumerWidget {
  const MyActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractAsync = ref.watch(currentUserDashboardContractProvider);
    final activityAsync = ref.watch(currentUserActivityLogsProvider);
    final sessionsAsync = ref.watch(currentUserSessionLogsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('سجل نشاطي وجلساتي')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: contractAsync.when(
            data: (contract) {
              if (contract == null) {
                return const Center(
                  child: Text('تعذر تحميل بيانات المستخدم الحالية.'),
                );
              }
              return ListView(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سجل القراءة فقط للمستخدم',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'هذه الصفحة تعرض للمستخدم أنظمته المتاحة وسجل نشاطه وجلساته الخاصة فقط. لا تمنح أي صلاحيات على تعديل السجلات أو حذفها أو إخفائها. الإدارة الكاملة للسجل تبقى لمدير النظام ضمن RBAC/RLS.',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _Badge(
                                label: 'المستخدم',
                                value: contract.displayName,
                              ),
                              _Badge(
                                label: 'الدور',
                                value: contract.policyRoleLabelAr,
                              ),
                              _Badge(
                                label: 'النطاق',
                                value: contract.scopeLabel,
                              ),
                              _Badge(
                                label: 'الأنظمة',
                                value: '${contract.systems.length}',
                              ),
                              _Badge(
                                label: 'الوصولات السريعة',
                                value: '${contract.quickActions.length}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (contract.isSuperuser) ...[
                    const SizedBox(height: 16),
                    const _UniversalAuthorityNotice(),
                  ],
                  const SizedBox(height: 16),
                  _SectionBlock(
                    title: 'الأنظمة المتاحة حاليًا',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: contract.systems.map((entry) {
                        return Container(
                          width: 220,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(_systemIcon(entry.systemKey)),
                              const SizedBox(height: 8),
                              Text(
                                entry.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'الدور: ${contract.isSuperuser ? 'سوبر يوزر سيادي' : entry.role.name}',
                              ),
                              Text(
                                'الصلاحيات: ${entry.grantedPermissions.length}',
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionBlock(
                    title: 'آخر الحركات',
                    child: activityAsync.when(
                      data: (rows) {
                        if (rows.isEmpty) {
                          return const Text(
                            'لا توجد حركات محفوظة بعد، أو أن جدول السجل السيادي لم يُفعّل بعد.',
                          );
                        }
                        return Column(
                          children: rows.map((row) {
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.bolt_outlined),
                              title: Text(
                                row.title.isNotEmpty ? row.title : 'حركة',
                              ),
                              subtitle: Text(
                                [
                                  if (row.route?.isNotEmpty == true) row.route!,
                                  row.createdAt.toLocal().toString(),
                                ].join(' • '),
                              ),
                              trailing: Text(row.status),
                            );
                          }).toList(),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('تعذر تحميل سجل النشاط: $e'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionBlock(
                    title: 'آخر الجلسات',
                    child: sessionsAsync.when(
                      data: (rows) {
                        if (rows.isEmpty) {
                          return const Text(
                            'لا توجد جلسات محفوظة بعد، أو ما زال المصدر الحالي يعتمد على Session Supabase فقط.',
                          );
                        }
                        return Column(
                          children: rows.map((row) {
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.login_outlined),
                              title: Text(row.status),
                              subtitle: Text(
                                [
                                  if ((row.systemKey ?? '').isNotEmpty)
                                    row.systemKey!,
                                  row.startedAt.toLocal().toString(),
                                  if (row.userAgent?.isNotEmpty == true)
                                    row.userAgent!,
                                ].join(' • '),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('تعذر تحميل سجل الجلسات: $e'),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('تعذر تحميل الصفحة: $e')),
          ),
        ),
      ),
    );
  }
}


class _UniversalAuthorityNotice extends StatelessWidget {
  const _UniversalAuthorityNotice();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFEAF4FF),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.verified_user_outlined),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'السلطة السيادية مفعلة لهذا الحساب: كل الوحدات وكل الأنظمة متاحة على مستوى الواجهة. تبقى عمليات الكتابة التخصصية خاضعة لعقود الـRPC الخاصة بكل نظام.',
                style: TextStyle(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionBlock({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final String value;

  const _Badge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text('$label: $value'),
    );
  }
}

IconData _systemIcon(dynamic systemKey) {
  final key = systemKey.toString();
  switch (key) {
    case 'SystemKey.platformAdmin':
      return Icons.admin_panel_settings_outlined;
    case 'SystemKey.mustakshif':
      return Icons.map_outlined;
    case 'SystemKey.cases':
      return Icons.gavel_outlined;
    case 'SystemKey.tasks':
      return Icons.task_alt_outlined;
    case 'SystemKey.billing':
      return Icons.receipt_long_outlined;
    case 'SystemKey.mosques':
      return Icons.mosque_outlined;
    case 'SystemKey.zakat':
      return Icons.volunteer_activism_outlined;
    case 'SystemKey.prayerTimes':
      return Icons.access_time_outlined;
    case 'SystemKey.quran':
      return Icons.menu_book_outlined;
    case 'SystemKey.lands':
    case 'SystemKey.properties':
      return Icons.landscape_outlined;
    case 'SystemKey.site':
      return Icons.public_outlined;
    case 'SystemKey.adminData':
      return Icons.account_tree_outlined;
    default:
      return Icons.widgets_outlined;
  }
}
