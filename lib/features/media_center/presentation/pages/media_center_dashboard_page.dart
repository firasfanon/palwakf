// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/features/media_center/data/models/media_center_models.dart';
import 'package:waqf/features/media_center/presentation/providers/media_center_providers.dart';
import 'package:waqf/presentation/widgets/admin/admin_layout.dart';

class MediaCenterDashboardPage extends ConsumerWidget {
  const MediaCenterDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(mediaCenterDashboardProvider);

    return AdminLayout(
      currentRoute: AppRoutes.adminMediaCenter,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: dashboardAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                _MediaCenterErrorState(message: error.toString()),
            data: (state) => _MediaCenterDashboardBody(
              state: state,
              onRefresh: () async {
                ref.invalidate(mediaCenterDashboardProvider);
                await ref.read(mediaCenterDashboardProvider.future);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaCenterDashboardBody extends StatelessWidget {
  const _MediaCenterDashboardBody({
    required this.state,
    required this.onRefresh,
  });

  final MediaCenterDashboardState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: _MediaCenterHeader(state: state),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _MediaCenterTabsBar(),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _MediaCenterTabScroll(
                  onRefresh: onRefresh,
                  children: [
                    _MediaCenterServiceFirstWorkspace(
                      families: state.families,
                      events: state.editorialDecisionEvents,
                      noticeAr: state.noticeAr,
                    ),
                  ],
                ),
                _MediaCenterTabScroll(
                  onRefresh: onRefresh,
                  children: [
                    _MediaCenterWorkflowCard(steps: state.editorialWorkflow),
                    const SizedBox(height: 16),
                    _MediaCenterEditorialRolesMatrixCard(
                      roles: state.editorialRoles,
                    ),
                    const SizedBox(height: 16),
                    _MediaCenterPublishingGovernanceCard(
                      rules: state.publishingRules,
                    ),
                    const SizedBox(height: 16),
                    _MediaCenterGovernanceReadinessCard(
                      stages: state.governanceReadiness,
                    ),
                    const SizedBox(height: 16),
                    _MediaCenterLivePermissionUatCard(
                      scenarios: state.permissionUatScenarios,
                    ),
                    const SizedBox(height: 16),
                    _MediaCenterEditorialDecisionEventsCard(
                      events: state.editorialDecisionEvents,
                    ),
                  ],
                ),
                _MediaCenterTabScroll(
                  onRefresh: onRefresh,
                  children: [
                    _MediaCenterRuntimeUxCard(checks: state.runtimeUxChecks),
                    const SizedBox(height: 16),
                    _MediaCenterReadinessCard(stages: state.readinessStages),
                    const SizedBox(height: 16),
                    _MediaCenterFamiliesGrid(families: state.families),
                    const SizedBox(height: 16),
                    _MediaCenterPolicyCard(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaCenterTabScroll extends StatelessWidget {
  const _MediaCenterTabScroll({
    required this.children,
    required this.onRefresh,
  });

  final List<Widget> children;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: children,
      ),
    );
  }
}

class _MediaCenterServiceFirstWorkspace extends StatelessWidget {
  const _MediaCenterServiceFirstWorkspace({
    required this.families,
    required this.events,
    required this.noticeAr,
  });

  final List<MediaCenterFamilySummary> families;
  final List<MediaCenterEditorialDecisionEventSummary> events;
  final String? noticeAr;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1180;
        final primary = Column(
          children: [
            if (noticeAr != null) ...[
              _MediaCenterNotice(message: noticeAr!),
              const SizedBox(height: 14),
            ],
            _MediaCenterServicesHero(families: families),
            const SizedBox(height: 14),
            _MediaCenterServiceFamiliesGrid(families: families),
          ],
        );
        final secondary = Column(
          children: [
            _MediaCenterWorkQueuesCard(families: families),
            const SizedBox(height: 14),
            _MediaCenterScopeContractCard(),
            const SizedBox(height: 14),
            _MediaCenterRecentEditorialActivity(events: events),
          ],
        );

        if (!wide) {
          return Column(
            children: [primary, const SizedBox(height: 14), secondary],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: primary),
            const SizedBox(width: 14),
            Expanded(flex: 4, child: secondary),
          ],
        );
      },
    );
  }
}

class _MediaCenterTabsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: const Color(0xFF0B3A70),
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF475569),
        labelStyle: const TextStyle(fontWeight: FontWeight.w900),
        tabs: const [
          Tab(icon: Icon(Icons.dashboard_customize_outlined), text: 'الخدمات'),
          Tab(icon: Icon(Icons.fact_check_outlined), text: 'الحوكمة'),
          Tab(icon: Icon(Icons.analytics_outlined), text: 'التشخيص'),
        ],
      ),
    );
  }
}

class _MediaCenterHeader extends StatelessWidget {
  const _MediaCenterHeader({required this.state});

  final MediaCenterDashboardState state;

  @override
  Widget build(BuildContext context) {
    final closed = state.closedStages;
    final total = state.totalStages == 0 ? 1 : state.totalStages;
    final progress = closed / total;
    final uxClosed = state.closedRuntimeChecks;
    final uxTotal = state.totalRuntimeChecks == 0
        ? 1
        : state.totalRuntimeChecks;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 900;
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.perm_media_outlined,
                      color: Color(0xFF0B3A70),
                    ),
                  ),
                  Text(
                    'المركز الإعلامي',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  _StatusChip(
                    label: state.isReady && state.runtimeUxReady
                        ? 'جاهز تشغيليًا'
                        : 'يتطلب متابعة تشغيلية',
                    color: state.isReady && state.runtimeUxReady
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFB22222),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'لوحة خدمات إعلامية يومية؛ تبدأ بإنشاء وإدارة الأخبار والإعلانات والأنشطة والوسائط والعاجل والسلايدر، مع إبقاء الحوكمة والتشخيص في تبويبات ثانوية لا تعيق التشغيل.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4B5563),
                  height: 1.55,
                ),
              ),
            ],
          );
          final meters = SizedBox(
            width: compact ? double.infinity : 310,
            child: Column(
              children: [
                _ReadinessMeter(
                  title: 'جاهزية المركز',
                  closed: closed,
                  total: state.totalStages,
                  progress: progress,
                ),
                const SizedBox(height: 10),
                _ReadinessMeter(
                  title: 'فحوص التشغيل',
                  closed: uxClosed,
                  total: state.totalRuntimeChecks,
                  progress: uxClosed / uxTotal,
                ),
              ],
            ),
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 18), meters],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: title),
              const SizedBox(width: 20),
              meters,
            ],
          );
        },
      ),
    );
  }
}

class _ReadinessMeter extends StatelessWidget {
  const _ReadinessMeter({
    required this.title,
    required this.closed,
    required this.total,
    required this.progress,
  });

  final String title;
  final int closed;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final effectiveTotal = total == 0 ? 1 : total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 10),
          Text(
            '$closed / $effectiveTotal مغلق',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _MediaCenterServicesHero extends StatelessWidget {
  const _MediaCenterServicesHero({required this.families});

  final List<MediaCenterFamilySummary> families;

  @override
  Widget build(BuildContext context) {
    final featured = families.take(4).toList(growable: false);
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.add_circle_outline,
            title: 'خدمات المركز الإعلامي',
            subtitle:
                'ابدأ من الخدمة نفسها: إنشاء، إدارة، مراجعة، نشر، أو فتح المسار العام للتحقق.',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final family in featured)
                FilledButton.icon(
                  onPressed: () => context.go(family.adminRoute),
                  icon: Icon(_familyIcon(family.familyKey), size: 18),
                  label: Text(
                    _primaryActionLabel(family.familyKey, family.labelAr),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () =>
                    context.go('/admin/media-center/breaking-news'),
                icon: const Icon(Icons.priority_high_outlined, size: 18),
                label: const Text('نشر خبر عاجل'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/admin/media-center/hero-slider'),
                icon: const Icon(Icons.slideshow_outlined, size: 18),
                label: const Text('إدارة السلايدر'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.rule_folder_outlined, color: Color(0xFF0B3A70)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'القاعدة التشغيلية: الواجهة تعرض الخدمات أولًا، بينما تُطبق الصلاحيات والحوكمة والتدقيق في الخلفية ومن تبويباتها المتخصصة.',
                    style: TextStyle(color: Color(0xFF475569), height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaCenterServiceFamiliesGrid extends StatelessWidget {
  const _MediaCenterServiceFamiliesGrid({required this.families});

  final List<MediaCenterFamilySummary> families;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.apps_outlined,
            title: 'الخدمات الإعلامية',
            subtitle:
                'بطاقات عملية لكل عائلة إعلامية، بدل عرض الحوكمة كواجهة أولى.',
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1100 ? 3 : (width >= 720 ? 2 : 1);
              final spacing = 12.0;
              final cardWidth = (width - (spacing * (columns - 1))) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final family in families)
                    SizedBox(
                      width: cardWidth,
                      child: _MediaCenterServiceCard(family: family),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MediaCenterServiceCard extends StatelessWidget {
  const _MediaCenterServiceCard({required this.family});

  final MediaCenterFamilySummary family;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _familyIcon(family.familyKey),
                  color: const Color(0xFF0B3A70),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  family.labelAr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            family.runtimeNoteAr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF475569), height: 1.45),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => context.go(family.adminRoute),
                icon: const Icon(Icons.edit_note_outlined, size: 18),
                label: Text(_manageActionLabel(family.familyKey)),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go(family.publicRoute),
                icon: const Icon(Icons.open_in_new_outlined, size: 18),
                label: const Text('عرض عام'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MediaCenterWorkQueuesCard extends StatelessWidget {
  const _MediaCenterWorkQueuesCard({required this.families});

  final List<MediaCenterFamilySummary> families;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.pending_actions_outlined,
            title: 'قوائم العمل اليومية',
            subtitle:
                'اختصارات تشغيلية لحالات التحرير. الأرقام الحية تُربط لاحقًا من الجداول القائمة دون إنشاء جداول محتوى موازية.',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _QueueShortcut(
                title: 'مسودات',
                subtitle: 'مواد قيد الإدخال',
                icon: Icons.description_outlined,
              ),
              _QueueShortcut(
                title: 'بانتظار المراجعة',
                subtitle: 'تحتاج قرار مراجع',
                icon: Icons.rate_review_outlined,
              ),
              _QueueShortcut(
                title: 'معتمدة وغير منشورة',
                subtitle: 'جاهزة للنشر أو الجدولة',
                icon: Icons.verified_outlined,
              ),
              _QueueShortcut(
                title: 'منشورة حديثًا',
                subtitle: 'تحقق الظهور العام',
                icon: Icons.public_outlined,
              ),
              _QueueShortcut(
                title: 'تحتاج انتباه',
                subtitle: 'صورة/تصنيف/تاريخ/نطاق',
                icon: Icons.report_problem_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final family in families.take(6))
                ActionChip(
                  avatar: Icon(_familyIcon(family.familyKey), size: 18),
                  label: Text(family.labelAr),
                  onPressed: () => context.go(family.adminRoute),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QueueShortcut extends StatelessWidget {
  const _QueueShortcut({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0B3A70)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaCenterScopeContractCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.account_tree_outlined,
            title: 'نطاق النشر',
            subtitle:
                'يعرض للمحرر قاعدة الملكية مباشرة دون تحويل الصفحة إلى دليل تعليمات.',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _ScopePill(
                title: 'الوزارة',
                subtitle: 'الصفحة الرئيسية والمسارات العامة',
                icon: Icons.account_balance_outlined,
              ),
              _ScopePill(
                title: 'الوحدة/المديرية',
                subtitle: 'صفحة الوحدة ومحتواها الداخلي',
                icon: Icons.apartment_outlined,
              ),
              _ScopePill(
                title: 'إبراز مختصر',
                subtitle: 'عرض متبادل دون نقل الملكية',
                icon: Icons.auto_awesome_motion_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScopePill extends StatelessWidget {
  const _ScopePill({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3A70).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF0B3A70).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0B3A70)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0B3A70),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaCenterRecentEditorialActivity extends StatelessWidget {
  const _MediaCenterRecentEditorialActivity({required this.events});

  final List<MediaCenterEditorialDecisionEventSummary> events;

  @override
  Widget build(BuildContext context) {
    final recent = events.take(3).toList(growable: false);
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.history_toggle_off_outlined,
            title: 'آخر حركة تحريرية',
            subtitle: 'ملخص سريع فقط؛ التفاصيل الكاملة في تبويب الحوكمة.',
          ),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            const Text(
              'لا توجد قرارات تحريرية حديثة بعد. ستظهر هنا قرارات الاعتماد أو الرفض أو النشر عند تسجيلها.',
              style: TextStyle(color: Color(0xFF64748B), height: 1.5),
            )
          else
            for (final event in recent) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.task_alt_outlined,
                  color: Color(0xFF2E7D32),
                ),
                title: Text(
                  event.decisionLabelAr,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  '${event.contentFamily} · ${event.sourceRoute}',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ),
              const Divider(height: 1),
            ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: const Color(0xFF0B3A70)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF64748B), height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MediaCenterQuickActions extends StatelessWidget {
  const _MediaCenterQuickActions({required this.families});

  final List<MediaCenterFamilySummary> families;

  @override
  Widget build(BuildContext context) {
    final primary = families.take(5).toList(growable: false);
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجراءات تشغيل سريعة',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'هذه الاختصارات تنقل مباشرة إلى الشاشات التحريرية الأكثر استخدامًا، مع إبقاء كل عائلة تحت تبويب المركز الإعلامي.',
            style: TextStyle(color: Color(0xFF4B5563), height: 1.5),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final family in primary)
                FilledButton.icon(
                  onPressed: () => context.go(family.adminRoute),
                  icon: Icon(_familyIcon(family.familyKey), size: 18),
                  label: Text(family.labelAr),
                ),
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.adminMediaCenter),
                icon: const Icon(Icons.dashboard_customize_outlined, size: 18),
                label: const Text('لوحة المركز'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MediaCenterPolicyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'العقد التشغيلي',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const _PolicyBullet(
            text:
                'أخبار الوزارة وإعلاناتها وأنشطتها تُغذي الصفحة الرئيسية للوزارة. لا تُخلط ملكيتها مع محتوى الوحدات.',
          ),
          const _PolicyBullet(
            text:
                'أخبار الوحدة وإعلاناتها وأنشطتها تُعرض داخل صفحة الوحدة نفسها، ويمكن رفعها للمختصر العام وفق قرار تحريري.',
          ),
          const _PolicyBullet(
            text:
                'الفعاليات مرحلة انتقالية عبر public.activities مع فلترة، ولا يُنشأ جدول مستقل قبل قرار معماري صريح.',
          ),
          const _PolicyBullet(
            text:
                'كل اعتماد أو نشر أو إخفاء مهم يجب أن يترك أثرًا في Audit أو سجل التحرير.',
          ),
        ],
      ),
    );
  }
}

class _PolicyBullet extends StatelessWidget {
  const _PolicyBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF0B3A70),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(height: 1.5))),
        ],
      ),
    );
  }
}

class _MediaCenterEditorialRolesMatrixCard extends StatelessWidget {
  const _MediaCenterEditorialRolesMatrixCard({required this.roles});

  final List<MediaCenterEditorialRoleCapability> roles;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مصفوفة الأدوار التحريرية',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'تربط هذه المصفوفة رحلة التحرير بمفاتيح صلاحيات المنصة: من يستطيع إنشاء مسودة، ومن يراجع، ومن يعتمد، ومن ينشر أو يبرز محتوى الوحدة على الصفحة الرئيسية.',
            style: TextStyle(color: Color(0xFF4B5563), height: 1.5),
          ),
          const SizedBox(height: 14),
          if (roles.isEmpty)
            const Text(
              'لا توجد أدوار تحريرية بعد. طبّق migration حوكمة النشر ثم حدّث الصفحة.',
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1280
                    ? 3
                    : constraints.maxWidth >= 820
                    ? 2
                    : 1;
                final spacing = 12.0;
                final width = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - spacing * (columns - 1)) /
                          columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final role in roles)
                      SizedBox(
                        width: width,
                        child: _EditorialRoleCard(role: role),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _EditorialRoleCard extends StatelessWidget {
  const _EditorialRoleCard({required this.role});

  final MediaCenterEditorialRoleCapability role;

  @override
  Widget build(BuildContext context) {
    final color = role.canPublish || role.canCrossPublish
        ? const Color(0xFFB22222)
        : const Color(0xFF0B3A70);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.admin_panel_settings_outlined, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  role.labelAr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            role.descriptionAr,
            style: const TextStyle(color: Color(0xFF4B5563), height: 1.45),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniLabel(
                text: role.scopeLabelAr,
                color: const Color(0xFF0B3A70),
              ),
              _MiniLabel(
                text: '${role.requiredSystemKey}.${role.requiredPermissionKey}',
                color: const Color(0xFFB8860B),
              ),
              if (role.canCreateDraft)
                _MiniLabel(text: 'مسودة', color: const Color(0xFF2E7D32)),
              if (role.canReview)
                _MiniLabel(text: 'مراجعة', color: const Color(0xFF0B3A70)),
              if (role.canApprove)
                _MiniLabel(text: 'اعتماد', color: const Color(0xFF6D28D9)),
              if (role.canPublish)
                _MiniLabel(text: 'نشر', color: const Color(0xFFB22222)),
              if (role.canCrossPublish)
                _MiniLabel(
                  text: 'إبراز متبادل',
                  color: const Color(0xFFB8860B),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            role.sovereigntyNoteAr,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              height: 1.35,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaCenterPublishingGovernanceCard extends StatelessWidget {
  const _MediaCenterPublishingGovernanceCard({required this.rules});

  final List<MediaCenterPublishingGovernanceRule> rules;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حوكمة النشر والملكية',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'قواعد تمنع خلط ملكية محتوى الوزارة والوحدات، وتضبط متى يظهر محتوى الوحدة كإبراز مختصر في الصفحة الرئيسية، ومتى يظهر محتوى الوزارة داخل صفحة الوحدة.',
            style: TextStyle(color: Color(0xFF4B5563), height: 1.5),
          ),
          const SizedBox(height: 12),
          if (rules.isEmpty)
            const Text(
              'لا توجد قواعد نشر بعد. طبّق migration مصفوفة الأدوار وحوكمة النشر ثم حدّث الصفحة.',
            )
          else
            ...rules.map((rule) => _PublishingRuleTile(rule: rule)),
        ],
      ),
    );
  }
}

class _PublishingRuleTile extends StatelessWidget {
  const _PublishingRuleTile({required this.rule});

  final MediaCenterPublishingGovernanceRule rule;

  @override
  Widget build(BuildContext context) {
    final color = rule.requiresApproval
        ? const Color(0xFF0B3A70)
        : const Color(0xFF6B7280);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.policy_outlined, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.ruleTitleAr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rule.ruleDescriptionAr,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniLabel(
                      text: '${rule.sourceScopeKey} ← ${rule.targetScopeKey}',
                      color: const Color(0xFF0B3A70),
                    ),
                    _MiniLabel(
                      text: rule.requiredRoleKey,
                      color: const Color(0xFFB8860B),
                    ),
                    _MiniLabel(
                      text: rule.requiredActionKey,
                      color: const Color(0xFF2E7D32),
                    ),
                    if (rule.requiresAudit)
                      _MiniLabel(
                        text: 'Audit إلزامي',
                        color: const Color(0xFFB22222),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'سياسة التعارض: ${rule.conflictPolicyAr}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    height: 1.35,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusChip(
            label: rule.isActive ? 'مفعلة' : 'معطلة',
            color: rule.isActive
                ? const Color(0xFF2E7D32)
                : const Color(0xFFB22222),
          ),
        ],
      ),
    );
  }
}

class _MediaCenterGovernanceReadinessCard extends StatelessWidget {
  const _MediaCenterGovernanceReadinessCard({required this.stages});

  final List<MediaCenterGovernanceReadinessStage> stages;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'جاهزية حوكمة النشر',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          if (stages.isEmpty)
            const Text(
              'لا توجد مؤشرات حوكمة بعد. طبّق SQL الخاص بمصفوفة الأدوار ثم حدّث الصفحة.',
            )
          else
            ...stages.map((stage) => _GovernanceReadinessTile(stage: stage)),
        ],
      ),
    );
  }
}

class _GovernanceReadinessTile extends StatelessWidget {
  const _GovernanceReadinessTile({required this.stage});

  final MediaCenterGovernanceReadinessStage stage;

  @override
  Widget build(BuildContext context) {
    final color = stage.isClosed
        ? const Color(0xFF2E7D32)
        : const Color(0xFFB22222);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            stage.isClosed
                ? Icons.verified_outlined
                : Icons.rule_folder_outlined,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.stageTitleAr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stage.evidenceAr,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الإجراء التالي: ${stage.requiredNextActionAr}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusChip(label: stage.statusLabelAr, color: color),
        ],
      ),
    );
  }
}

class _MediaCenterLivePermissionUatCard extends StatelessWidget {
  const _MediaCenterLivePermissionUatCard({required this.scenarios});

  final List<MediaCenterPermissionUatScenario> scenarios;

  @override
  Widget build(BuildContext context) {
    final closed = scenarios.where((scenario) => scenario.isClosed).length;
    final total = scenarios.length;
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'UAT صلاحيات المستخدمين الفعليين',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              _StatusChip(
                label: total > 0 && closed == total
                    ? 'مغلق'
                    : '$closed / $total',
                color: total > 0 && closed == total
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFB22222),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'هذه اللوحة لا تعتبر جلسة SQL Editor مستخدمًا حيًا. الإغلاق الصحيح يتم بتسجيل نتائج مستخدمين مصادقين عبر RPC مخصص لكل سيناريو صلاحية.',
            style: TextStyle(color: Color(0xFF4B5563), height: 1.5),
          ),
          const SizedBox(height: 12),
          if (scenarios.isEmpty)
            const Text(
              'لا توجد سيناريوهات UAT بعد. طبّق migration صلاحيات المستخدمين ثم حدّث الصفحة.',
            )
          else
            ...scenarios.map(
              (scenario) => _PermissionUatScenarioTile(scenario: scenario),
            ),
        ],
      ),
    );
  }
}

class _PermissionUatScenarioTile extends StatelessWidget {
  const _PermissionUatScenarioTile({required this.scenario});

  final MediaCenterPermissionUatScenario scenario;

  @override
  Widget build(BuildContext context) {
    final color = scenario.isClosed
        ? const Color(0xFF2E7D32)
        : const Color(0xFFB22222);
    final actual = scenario.actualAllowed == null
        ? 'غير مسجل'
        : (scenario.actualAllowed! ? 'مسموح' : 'مرفوض');
    final expected = scenario.expectedAllowed ? 'متوقع: مسموح' : 'متوقع: مرفوض';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            scenario.isClosed
                ? Icons.verified_user_outlined
                : Icons.manage_accounts_outlined,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scenario.titleAr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scenario.evidenceAr,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniLabel(
                      text: scenario.roleKey,
                      color: const Color(0xFF0B3A70),
                    ),
                    _MiniLabel(
                      text: scenario.actionKey,
                      color: const Color(0xFFB8860B),
                    ),
                    if (scenario.unitSlug != null)
                      _MiniLabel(
                        text: scenario.unitSlug!,
                        color: const Color(0xFF6D28D9),
                      ),
                    _MiniLabel(text: expected, color: const Color(0xFF2E7D32)),
                    _MiniLabel(text: 'فعلي: $actual', color: color),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'الإجراء التالي: ${scenario.requiredNextActionAr}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    height: 1.35,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusChip(label: scenario.statusLabelAr, color: color),
        ],
      ),
    );
  }
}

class _MediaCenterEditorialDecisionEventsCard extends StatelessWidget {
  const _MediaCenterEditorialDecisionEventsCard({required this.events});

  final List<MediaCenterEditorialDecisionEventSummary> events;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'قرارات التحرير المسجلة',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              _StatusChip(
                label: events.isEmpty
                    ? 'بانتظار أول قرار'
                    : 'مسجل: ${events.length}',
                color: events.isEmpty
                    ? const Color(0xFFB22222)
                    : const Color(0xFF2E7D32),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'يعرض آخر قرارات الاعتماد/النشر/الرفض/الأرشفة المسجلة عبر rpc_media_center_record_editorial_event_v1، ولا يغير جداول المحتوى الأصلية.',
            style: TextStyle(color: Color(0xFF4B5563), height: 1.5),
          ),
          const SizedBox(height: 12),
          if (events.isEmpty)
            const Text(
              'لا توجد قرارات تحريرية بعد. سجّل أول قرار فعلي عند اعتماد أو نشر مادة إعلامية.',
            )
          else
            ...events.map((event) => _EditorialDecisionEventTile(event: event)),
        ],
      ),
    );
  }
}

class _EditorialDecisionEventTile extends StatelessWidget {
  const _EditorialDecisionEventTile({required this.event});

  final MediaCenterEditorialDecisionEventSummary event;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3A70).withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0B3A70).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.fact_check_outlined, color: Color(0xFF0B3A70)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.decisionLabelAr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.notes.isEmpty ? 'لا توجد ملاحظات إضافية.' : event.notes,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniLabel(
                      text: event.contentFamily,
                      color: const Color(0xFF0B3A70),
                    ),
                    _MiniLabel(
                      text: event.actionKey,
                      color: const Color(0xFFB8860B),
                    ),
                    _MiniLabel(
                      text:
                          '${event.fromStatus ?? 'غير محدد'} ← ${event.toStatus}',
                      color: const Color(0xFF2E7D32),
                    ),
                    if (event.unitSlug != null)
                      _MiniLabel(
                        text: event.unitSlug!,
                        color: const Color(0xFF6D28D9),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  event.sourceRoute,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    height: 1.35,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaCenterWorkflowCard extends StatelessWidget {
  const _MediaCenterWorkflowCard({required this.steps});

  final List<MediaCenterEditorialWorkflowStep> steps;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سير التحرير والاعتماد',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'المسار المعياري لأي مادة إعلامية: إدخال مضبوط، مراجعة بشرية، اعتماد، نشر، ثم أرشفة عند الحاجة. هذا المسار تنظيمي فوق الجداول الحالية وليس جدول محتوى بديلًا.',
            style: TextStyle(color: Color(0xFF4B5563), height: 1.5),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1100
                  ? 5
                  : constraints.maxWidth >= 760
                  ? 3
                  : 1;
              final spacing = 10.0;
              final width = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final step in steps)
                    SizedBox(
                      width: width,
                      child: _WorkflowStepCard(step: step),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WorkflowStepCard extends StatelessWidget {
  const _WorkflowStepCard({required this.step});

  final MediaCenterEditorialWorkflowStep step;

  @override
  Widget build(BuildContext context) {
    final color = step.isRequired
        ? const Color(0xFF0B3A70)
        : const Color(0xFF6B7280);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                step.isRequired
                    ? Icons.verified_user_outlined
                    : Icons.inventory_2_outlined,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  step.titleAr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            step.descriptionAr,
            style: const TextStyle(color: Color(0xFF4B5563), height: 1.45),
          ),
          const SizedBox(height: 8),
          _MiniLabel(text: step.allowedActionsAr, color: color),
          const SizedBox(height: 6),
          Text(
            'الدليل: ${step.requiredEvidenceAr}',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              height: 1.4,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaCenterRuntimeUxCard extends StatelessWidget {
  const _MediaCenterRuntimeUxCard({required this.checks});

  final List<MediaCenterRuntimeUxCheck> checks;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'فحوص تجربة التشغيل',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'هذه الفحوص تربط الصقل البصري والتشغيلي بمؤشرات قابلة للمتابعة بعد كل تعديل على routes أو المحتوى أو واجهات النشر.',
            style: TextStyle(color: Color(0xFF4B5563), height: 1.5),
          ),
          const SizedBox(height: 12),
          if (checks.isEmpty)
            const Text(
              'لا توجد فحوص تشغيل بعد. طبّق migration الصقل التشغيلي ثم حدّث الصفحة.',
            )
          else
            ...checks.map((check) => _RuntimeUxCheckTile(check: check)),
        ],
      ),
    );
  }
}

class _RuntimeUxCheckTile extends StatelessWidget {
  const _RuntimeUxCheckTile({required this.check});

  final MediaCenterRuntimeUxCheck check;

  @override
  Widget build(BuildContext context) {
    final color = check.isClosed
        ? const Color(0xFF2E7D32)
        : const Color(0xFFB22222);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            check.isClosed
                ? Icons.check_circle_outline
                : Icons.rule_folder_outlined,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  check.titleAr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  check.evidenceAr,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الإجراء التالي: ${check.requiredNextActionAr}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusChip(label: check.statusLabelAr, color: color),
        ],
      ),
    );
  }
}

class _MediaCenterFamiliesGrid extends StatelessWidget {
  const _MediaCenterFamiliesGrid({required this.families});

  final List<MediaCenterFamilySummary> families;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'صفحات المركز الإعلامي المجمعة',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1280
                  ? 3
                  : constraints.maxWidth >= 820
                  ? 2
                  : 1;
              final spacing = 12.0;
              final width = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: families
                    .map(
                      (family) => SizedBox(
                        width: width,
                        child: _FamilyCard(family: family),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FamilyCard extends StatelessWidget {
  const _FamilyCard({required this.family});

  final MediaCenterFamilySummary family;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.go(family.adminRoute),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0B3A70).withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF0B3A70).withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _familyIcon(family.familyKey),
                  color: const Color(0xFF0B3A70),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    family.labelAr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              family.storageOrTableAr,
              style: const TextStyle(color: Color(0xFF4B5563), height: 1.45),
            ),
            const SizedBox(height: 8),
            Text(
              'المسؤول التحريري: ${family.editorialOwnerAr}',
              style: const TextStyle(
                color: Color(0xFF4B5563),
                height: 1.45,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'المسار: ${family.defaultWorkflowAr}',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                height: 1.45,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(
                  label: family.statusAr,
                  color: const Color(0xFF0B3A70),
                ),
                _MiniLabel(
                  text: family.publicRoute,
                  color: const Color(0xFFB8860B),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              family.runtimeNoteAr,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                height: 1.35,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaCenterReadinessCard extends StatelessWidget {
  const _MediaCenterReadinessCard({required this.stages});

  final List<MediaCenterReadinessStage> stages;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'جاهزية SQL/RPC وUAT',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (stages.isEmpty)
            const Text(
              'لا توجد بيانات readiness بعد. طبّق SQL الخاص بالمركز الإعلامي ثم حدّث الصفحة.',
            )
          else
            ...stages.map((stage) => _ReadinessStageTile(stage: stage)),
        ],
      ),
    );
  }
}

class _ReadinessStageTile extends StatelessWidget {
  const _ReadinessStageTile({required this.stage});

  final MediaCenterReadinessStage stage;

  @override
  Widget build(BuildContext context) {
    final color = stage.isClosed
        ? const Color(0xFF2E7D32)
        : const Color(0xFFB22222);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            stage.isClosed
                ? Icons.check_circle_outline
                : Icons.pending_actions_outlined,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.stageTitleAr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stage.evidenceAr,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الإجراء التالي: ${stage.requiredNextActionAr}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusChip(label: stage.statusLabelAr, color: color),
        ],
      ),
    );
  }
}

class _MediaCenterNotice extends StatelessWidget {
  const _MediaCenterNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF92400E)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF78350F), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  const _MiniLabel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _MediaCenterErrorState extends StatelessWidget {
  const _MediaCenterErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('تعذر تحميل المركز الإعلامي: $message'),
        ),
      ),
    );
  }
}

String _primaryActionLabel(String familyKey, String labelAr) {
  switch (familyKey) {
    case 'news':
      return 'إنشاء خبر';
    case 'announcements':
      return 'إنشاء إعلان';
    case 'activities':
      return 'إضافة نشاط';
    case 'events':
      return 'إضافة فعالية';
    case 'photos':
      return 'رفع صور';
    case 'videos':
      return 'إضافة فيديو';
    case 'breaking_news':
      return 'خبر عاجل';
    case 'friday_sermons':
      return 'إضافة خطبة';
    case 'hero_slider':
      return 'إضافة شريحة';
    default:
      return 'إدارة $labelAr';
  }
}

String _manageActionLabel(String familyKey) {
  switch (familyKey) {
    case 'news':
      return 'إدارة الأخبار';
    case 'announcements':
      return 'إدارة الإعلانات';
    case 'activities':
      return 'إدارة الأنشطة';
    case 'events':
      return 'إدارة الفعاليات';
    case 'photos':
      return 'إدارة الصور';
    case 'videos':
      return 'إدارة الفيديوهات';
    case 'breaking_news':
      return 'إدارة العاجل';
    case 'friday_sermons':
      return 'إدارة الخطب';
    case 'hero_slider':
      return 'إدارة السلايدر';
    default:
      return 'إدارة';
  }
}

IconData _familyIcon(String familyKey) {
  switch (familyKey) {
    case 'news':
      return Icons.newspaper_outlined;
    case 'announcements':
      return Icons.campaign_outlined;
    case 'activities':
      return Icons.event_note_outlined;
    case 'events':
      return Icons.celebration_outlined;
    case 'photos':
      return Icons.photo_library_outlined;
    case 'videos':
      return Icons.ondemand_video_outlined;
    case 'breaking_news':
      return Icons.priority_high_outlined;
    case 'friday_sermons':
      return Icons.mic_none_outlined;
    case 'hero_slider':
      return Icons.slideshow_outlined;
    default:
      return Icons.perm_media_outlined;
  }
}
