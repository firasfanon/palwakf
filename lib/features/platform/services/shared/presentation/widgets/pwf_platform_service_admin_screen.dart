import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waqf/presentation/widgets/admin/admin_system_workspace_header.dart';

class PwfPlatformServiceAdminScreen extends StatelessWidget {
  const PwfPlatformServiceAdminScreen({
    super.key,
    required this.currentRoute,
    required this.title,
    required this.subtitle,
    required this.stats,
    required this.quickActions,
    required this.tabs,
  });

  final String currentRoute;
  final String title;
  final String subtitle;
  final List<PwfServiceAdminStat> stats;
  final List<PwfServiceAdminAction> quickActions;
  final List<PwfServiceAdminTab> tabs;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                                      .map(
                                        (item) => PwfAdminStatCard(item: item),
                                      )
                                      .toList(growable: false),
                                ),
                                const SizedBox(height: 16),
                                PwfAdminSectionCard(
                                  title: 'إجراءات تشغيلية',
                                  subtitle:
                                      'روابط عمل مباشرة داخل المنصة بدل الاكتفاء بتحويلات للواجهة العامة.',
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: quickActions
                                        .map(
                                          (action) => action.route == null
                                              ? OutlinedButton.icon(
                                                  onPressed: action.onPressed,
                                                  icon: Icon(action.icon),
                                                  label: Text(action.label),
                                                )
                                              : FilledButton.icon(
                                                  onPressed:
                                                      action.onPressed ??
                                                      () => context.go(
                                                        action.route!,
                                                      ),
                                                  icon: Icon(action.icon),
                                                  label: Text(action.label),
                                                ),
                                        )
                                        .toList(growable: false),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _PinnedTabBarDelegate(
                            TabBar(
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              labelColor: const Color(0xFF0F4C81),
                              unselectedLabelColor: const Color(0xFF6B7280),
                              indicatorColor: const Color(0xFF0F4C81),
                              tabs: tabs
                                  .map(
                                    (tab) => Tab(
                                      icon: Icon(tab.icon),
                                      text: tab.label,
                                    ),
                                  )
                                  .toList(growable: false),
                            ),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      children: tabs
                          .map(
                            (tab) => SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                24,
                              ),
                              child: tab.child,
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PwfServiceAdminTab {
  const PwfServiceAdminTab({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;
}

class PwfServiceAdminStat {
  const PwfServiceAdminStat({
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

class PwfServiceAdminAction {
  const PwfServiceAdminAction({
    required this.label,
    required this.icon,
    this.route,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final String? route;
  final VoidCallback? onPressed;
}

class PwfAdminSectionCard extends StatelessWidget {
  const PwfAdminSectionCard({
    super.key,
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
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
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class PwfAdminStatCard extends StatelessWidget {
  const PwfAdminStatCard({super.key, required this.item});

  final PwfServiceAdminStat item;

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
            const SizedBox(height: 12),
            Text(
              item.value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (item.hint != null) ...[
              const SizedBox(height: 6),
              Text(
                item.hint!,
                style: const TextStyle(color: Color(0xFF6B7280), height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PwfAdminInfoRow extends StatelessWidget {
  const PwfAdminInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF111827), height: 1.5),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

class PwfAdminBulletList extends StatelessWidget {
  const PwfAdminBulletList({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: Color(0xFF0F4C81),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item, style: const TextStyle(height: 1.6)),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class PwfAdminBadge extends StatelessWidget {
  const PwfAdminBadge({
    super.key,
    required this.label,
    this.color = const Color(0xFFE8F0FE),
    this.textColor = const Color(0xFF0F4C81),
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _PinnedTabBarDelegate extends SliverPersistentHeaderDelegate {
  _PinnedTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height + 12;

  @override
  double get maxExtent => tabBar.preferredSize.height + 12;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedTabBarDelegate oldDelegate) => false;
}
