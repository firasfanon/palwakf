// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routing/app_routes.dart';
import '../../../core/access/access_profile.dart';
import '../../../core/access/access_provider.dart';
import '../../../core/access/admin_route_access_contract.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/enums/enums.dart';
import '../../../features/platform/dynamic_systems/data/models/pwf_dynamic_system_models.dart';
import '../../../features/platform/dynamic_systems/presentation/providers/pwf_dynamic_system_registry_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/developer_ui_provider.dart';
import '../admin/admin_panel_registry.dart';

class WebSidebar extends ConsumerStatefulWidget {
  const WebSidebar({super.key, this.currentRoute});

  final String? currentRoute;

  @override
  ConsumerState<WebSidebar> createState() => _WebSidebarState();
}

class _WebSidebarState extends ConsumerState<WebSidebar> {
  String _activeTab = 'main';

  @override
  void initState() {
    super.initState();
    _activeTab = AdminPanelRegistry.tabForRoute(widget.currentRoute).key;
  }

  @override
  void didUpdateWidget(covariant WebSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _activeTab = AdminPanelRegistry.tabForRoute(widget.currentRoute).key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final accessProfile = ref.watch(accessProfileProvider).valueOrNull;
    final dynamicSystems =
        ref.watch(visibleDynamicAdminSystemsProvider).valueOrNull ??
        const <PwfDynamicSystemModule>[];
    final visibleTabs = _visibleTabsForAccess(accessProfile, dynamicSystems);
    final effectiveTab = visibleTabs.any((tab) => tab.key == _activeTab)
        ? _activeTab
        : (visibleTabs.isNotEmpty ? visibleTabs.first.key : 'main');
    final groups = _visibleGroupsForTab(
      effectiveTab,
      accessProfile,
      dynamicSystems,
    );
    final showRoutes = ref.watch(developerShowRoutesProvider);
    final showPageNames = ref.watch(developerShowPageNamesProvider);
    final collapsed = ref.watch(adminSidebarCollapsedProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: collapsed ? 88 : 264,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        border: Border(
          left: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          children: [
            _buildHeader(
              collapsed: collapsed,
              showRoutes: showRoutes,
              showPageNames: showPageNames,
            ),
            const SizedBox(height: 8),
            _buildTabBar(
              tabs: visibleTabs,
              activeTabKey: effectiveTab,
              accessProfile: accessProfile,
              dynamicSystems: dynamicSystems,
              collapsed: collapsed,
            ),
            const SizedBox(height: 8),
            if (groups.isEmpty)
              _buildAccessEmptyState(collapsed: collapsed)
            else
              for (final group in groups) ...[
                _buildSidebarSection(
                  group,
                  showRoutes: showRoutes,
                  collapsed: collapsed,
                ),
                if (_visibleEntrySectionsForGroup(
                  group.id,
                  group.items,
                ).isNotEmpty)
                  _buildGroupedEntriesDropdown(
                    context,
                    group,
                    _visibleEntrySectionsForGroup(group.id, group.items),
                    collapsed: collapsed,
                    showRoutes: showRoutes,
                    showDescription: showPageNames,
                  )
                else
                  for (final item in group.items)
                    _buildNavItem(
                      context,
                      item,
                      collapsed: collapsed,
                      showRoutes: showRoutes,
                      showDescription: showPageNames,
                    ),
                const SizedBox(height: 6),
              ],
            _buildFooter(
              currentUser,
              collapsed: collapsed,
              showRoutes: showRoutes,
              showPageNames: showPageNames,
            ),
          ],
        ),
      ),
    );
  }

  List<AdminPanelTabItem> _visibleTabsForAccess(
    AccessProfile? profile,
    List<PwfDynamicSystemModule> dynamicSystems,
  ) {
    final tabs = AdminPanelRegistry.tabs
        .where(
          (tab) =>
              _visibleGroupsForTab(tab.key, profile, dynamicSystems).isNotEmpty,
        )
        .toList(growable: false);
    if (tabs.isNotEmpty) return tabs;
    return const [
      AdminPanelTabItem(
        key: 'main',
        label: 'الرئيسية',
        icon: Icons.dashboard_outlined,
      ),
    ];
  }

  List<AdminPanelGroup> _visibleGroupsForTab(
    String tabKey,
    AccessProfile? profile,
    List<PwfDynamicSystemModule> dynamicSystems,
  ) {
    final groups = AdminPanelRegistry.groupsForTab(tabKey)
        .map((group) => _filterGroupForAccess(group, profile))
        .where((group) => group.items.isNotEmpty)
        .toList(growable: true);

    if (tabKey == 'systems') {
      final dynamicGroup = _dynamicSystemsGroup(
        dynamicSystems,
        profile,
        sidebarOnly: true,
      );
      if (dynamicGroup.items.isNotEmpty) groups.add(dynamicGroup);
    }

    return groups;
  }

  AdminPanelGroup _filterGroupForAccess(
    AdminPanelGroup group,
    AccessProfile? profile,
  ) {
    final visibleItems = group.items
        .where((item) => _canShowSidebarEntry(item, profile, groupId: group.id))
        .toList(growable: false);
    return AdminPanelGroup(
      id: group.id,
      title: group.title,
      subtitle: group.subtitle,
      items: visibleItems,
    );
  }

  List<AdminPanelEntrySection> _visibleEntrySectionsForGroup(
    String groupId,
    List<AdminPanelEntry> visibleItems,
  ) {
    if (visibleItems.isEmpty) return const <AdminPanelEntrySection>[];
    final visibleRoutes = {
      for (final item in visibleItems) _normalizeRoute(item.route),
    };
    return AdminPanelRegistry.entrySectionsForGroup(groupId)
        .map((section) {
          final routes = section.routes
              .where((route) => visibleRoutes.contains(_normalizeRoute(route)))
              .toList(growable: false);
          if (routes.isEmpty) return null;
          return AdminPanelEntrySection(
            title: section.title,
            icon: section.icon,
            routes: routes,
          );
        })
        .whereType<AdminPanelEntrySection>()
        .toList(growable: false);
  }

  bool _canShowSidebarEntry(
    AdminPanelEntry item,
    AccessProfile? profile, {
    required String groupId,
  }) {
    final route = _normalizeRoute(item.route);
    if (_sidebarCommonRoutes.contains(route) && groupId == 'main') return true;
    if (profile == null || !profile.isActive) return false;
    if (profile.isSuperuser) return true;
    final dynamicSystemKey = _dynamicSystemKeyFromRoute(route);
    if (dynamicSystemKey != null)
      return profile.canAccessDynamicSystem(dynamicSystemKey);
    final contract = AdminRouteAccessContracts.contractFor(route);
    if (contract != null) return contract.allows(profile);
    return _allowsKnownUncontractedSidebarRoute(route, profile);
  }

  AdminPanelGroup _dynamicSystemsGroup(
    List<PwfDynamicSystemModule> systems,
    AccessProfile? profile, {
    required bool sidebarOnly,
  }) {
    final entries = <AdminPanelEntry>[];
    for (final system in systems) {
      if (!system.isActive) continue;
      if (sidebarOnly && !system.showInSidebar) continue;
      if (profile != null &&
          !profile.isSuperuser &&
          !profile.canAccessDynamicSystem(system.systemKey))
        continue;
      entries.add(
        AdminPanelEntry(
          label: system.nameAr,
          description: system.descriptionAr.isEmpty
              ? 'نظام ديناميكي مسجل في platform.system_registry.'
              : system.descriptionAr,
          route: system.routeForShell(),
          icon: system.icon,
        ),
      );
      for (final section in system.sections) {
        if (!section.isActive || !section.showInSidebar) continue;
        if (profile != null &&
            !profile.isSuperuser &&
            !profile.canAccessDynamicSection(
              system.systemKey,
              requiredPermissionKey: section.requiredPermissionKey,
            )) {
          continue;
        }
        entries.add(
          AdminPanelEntry(
            label: section.titleAr,
            description: section.descriptionAr.isEmpty
                ? 'قسم ديناميكي تابع لـ ${system.nameAr} من platform.system_sections.'
                : section.descriptionAr,
            route: section.routePath,
            icon: section.icon,
          ),
        );
      }
    }
    return AdminPanelGroup(
      id: 'dynamic_systems',
      title: 'الأنظمة والأقسام الديناميكية',
      subtitle:
          'تظهر من platform.system_registry وplatform.system_sections حسب الصلاحيات.',
      items: entries,
    );
  }

  String? _dynamicSystemKeyFromRoute(String route) {
    final segments = Uri.parse(route).pathSegments;
    if (segments.length >= 3 &&
        segments[0] == 'admin' &&
        segments[1] == 'systems') {
      return Uri.decodeComponent(segments[2]);
    }
    return null;
  }

  bool _allowsKnownUncontractedSidebarRoute(
    String route,
    AccessProfile profile,
  ) {
    if (profile.canManagePlatformAdmin()) return true;
    if (route == AppRoutes.adminData) {
      return profile.canAccessSystem(SystemKey.adminData);
    }
    if (route == AppRoutes.adminUnitPagesExecution) {
      return profile.hasRoleAtLeast(SystemKey.platformAdmin, UserRole.admin) ||
          profile.can(SystemKey.platformAdmin, Permission.manageHome);
    }
    if (route.startsWith('/admin/public-pages')) {
      return profile.hasRoleAtLeast(SystemKey.site, UserRole.user) ||
          profile.can(SystemKey.site, Permission.read) ||
          profile.can(SystemKey.site, Permission.manageSite);
    }
    return false;
  }

  String? _defaultRouteForTab(
    String tabKey,
    AccessProfile? profile,
    List<PwfDynamicSystemModule> dynamicSystems,
  ) {
    final groups = _visibleGroupsForTab(tabKey, profile, dynamicSystems);
    for (final group in groups) {
      if (group.items.isNotEmpty) return group.items.first.route;
    }
    return null;
  }

  String _normalizeRoute(String? route) {
    final value = (route ?? '').trim();
    if (value.isEmpty) return '';
    final noQuery = value.split('?').first;
    if (noQuery.length > 1 && noQuery.endsWith('/')) {
      return noQuery.substring(0, noQuery.length - 1);
    }
    return noQuery;
  }

  static const _sidebarCommonRoutes = <String>{
    AppRoutes.adminDashboard,
    AppRoutes.adminProfile,
    AppRoutes.adminMyActivity,
    AppRoutes.adminAssistant,
    AppRoutes.adminUsageGuide,
  };

  Widget _buildHeader({
    required bool collapsed,
    required bool showRoutes,
    required bool showPageNames,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C81), Color(0xFF0B1220)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEAB308).withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: collapsed ? 46 : 54,
                height: collapsed ? 46 : 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(AppConstants.appLogo, fit: BoxFit.contain),
                ),
              ),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'لوحة التحكم',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'PalWakf Admin',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFF8FAFC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: collapsed ? Alignment.center : Alignment.centerLeft,
            child: IconButton.filledTonal(
              onPressed: () =>
                  ref.read(adminSidebarCollapsedProvider.notifier).state =
                      !collapsed,
              icon: Icon(
                collapsed
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
              ),
              tooltip: collapsed ? 'توسيع السايد بار' : 'طي السايد بار',
            ),
          ),
          if (!collapsed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'إدارة المنصة\nوالأنظمة المتصلة',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.white,
                      height: 1.55,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (showPageNames || showRoutes) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (showPageNames)
                          const _SidebarHintChip(
                            label: 'أسماء الصفحات: ظاهرة',
                            icon: Icons.title_rounded,
                          ),
                        if (showRoutes)
                          const _SidebarHintChip(
                            label: 'المسارات: ظاهرة',
                            icon: Icons.route_rounded,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar({
    required List<AdminPanelTabItem> tabs,
    required String activeTabKey,
    required AccessProfile? accessProfile,
    required List<PwfDynamicSystemModule> dynamicSystems,
    required bool collapsed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = collapsed
              ? constraints.maxWidth
              : (constraints.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final tab in tabs)
                SizedBox(
                  width: itemWidth,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setState(() => _activeTab = tab.key);
                        final targetRoute = _defaultRouteForTab(
                          tab.key,
                          accessProfile,
                          dynamicSystems,
                        );
                        if (targetRoute != null &&
                            (widget.currentRoute ?? '') != targetRoute) {
                          context.go(targetRoute);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: activeTabKey == tab.key
                              ? const Color(0xFFEAB308)
                              : const Color(0xFF132238),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: activeTabKey == tab.key
                                ? const Color(0xFFEAB308)
                                : Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tab.icon,
                              size: 18,
                              color: activeTabKey == tab.key
                                  ? const Color(0xFF0B1220)
                                  : Colors.white,
                            ),
                            if (!collapsed) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  tab.label,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: activeTabKey == tab.key
                                        ? const Color(0xFF0B1220)
                                        : const Color(0xFFF8FAFC),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAccessEmptyState({required bool collapsed}) {
    if (collapsed) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF132238),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const Text(
        'لا توجد تبويبات إضافية مصرح بها لهذا المستخدم. استخدم لوحة التحكم أو نشاطي أو دليل الاستخدام.',
        style: TextStyle(color: Color(0xFFD7E3F6), fontSize: 12, height: 1.5),
      ),
    );
  }

  Widget _buildFooter(
    dynamic currentUser, {
    required bool collapsed,
    required bool showRoutes,
    required bool showPageNames,
  }) {
    final name = currentUser?.name ?? 'مستخدم';
    final role = currentUser?.role ?? '—';
    final trimmed = name.toString().trim();
    final initials = (trimmed.isNotEmpty ? trimmed.substring(0, 1) : 'U')
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFEAB308),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0B1220),
                  ),
                ),
              ),
              if (!collapsed) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.toString(),
                        style: const TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role.toString(),
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final enabled =
                        ref.watch(developerShowRoutesProvider) ||
                        ref.watch(developerShowPageNamesProvider);
                    return IconButton(
                      tooltip: enabled
                          ? 'إخفاء مؤشرات الصيانة'
                          : 'إظهار مؤشرات الصيانة',
                      onPressed: () {
                        final next = !enabled;
                        ref.read(developerShowRoutesProvider.notifier).state =
                            next;
                        ref
                                .read(developerShowPageNamesProvider.notifier)
                                .state =
                            next;
                      },
                      icon: Icon(
                        enabled
                            ? Icons.visibility_off_rounded
                            : Icons.developer_mode_rounded,
                        color: enabled
                            ? const Color(0xFFEAB308)
                            : Colors.white70,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          if (!collapsed &&
              showRoutes &&
              (widget.currentRoute ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.currentRoute!,
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 11.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebarSection(
    AdminPanelGroup group, {
    required bool showRoutes,
    required bool collapsed,
  }) {
    if (collapsed) return const SizedBox(height: 6);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          if (showRoutes) ...[
            const SizedBox(height: 4),
            Text(
              group.subtitle,
              style: TextStyle(
                fontSize: 11,
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.58),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupedEntriesDropdown(
    BuildContext context,
    AdminPanelGroup group,
    List<AdminPanelEntrySection> sections, {
    required bool collapsed,
    required bool showRoutes,
    required bool showDescription,
  }) {
    if (group.items.isEmpty) return const SizedBox.shrink();
    final parent = group.items.first;
    final byRoute = <String, AdminPanelEntry>{
      for (final item in group.items) item.route: item,
    };
    final current = widget.currentRoute ?? '';
    final isActive =
        current.startsWith(parent.route) ||
        sections.any(
          (section) => section.routes.any((route) => current.startsWith(route)),
        );

    if (collapsed) {
      return _buildNavItem(
        context,
        parent,
        collapsed: collapsed,
        showRoutes: showRoutes,
        showDescription: showDescription,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF133056) : const Color(0xFF132238),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? const Color(0xFFEAB308)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSurfaceServicesParentItem(
            context,
            parent,
            isActive: current == parent.route,
            showDescription: showDescription,
            showRoutes: showRoutes,
          ),
          const SizedBox(height: 8),
          for (final section in sections)
            _buildSidebarEntrySection(
              context,
              _SidebarEntrySection(
                title: section.title,
                icon: section.icon,
                routes: section.routes,
              ),
              entries: section.routes
                  .map((route) => byRoute[route])
                  .whereType<AdminPanelEntry>()
                  .toList(growable: false),
              showRoutes: showRoutes,
            ),
        ],
      ),
    );
  }

  Widget _buildMediaCenterDropdown(
    BuildContext context,
    AdminPanelGroup group, {
    required bool collapsed,
    required bool showRoutes,
    required bool showDescription,
  }) {
    if (group.items.isEmpty) return const SizedBox.shrink();
    final parent = group.items.first;
    final byRoute = <String, AdminPanelEntry>{
      for (final item in group.items) item.route: item,
    };
    final sections = <_SidebarEntrySection>[
      _SidebarEntrySection(
        title: 'النشر الإعلامي',
        icon: Icons.article_rounded,
        routes: const [
          AppRoutes.adminMediaCenterNews,
          AppRoutes.adminMediaCenterAnnouncements,
          AppRoutes.adminMediaCenterPressReleases,
          AppRoutes.adminMediaCenterOfficialStatements,
          AppRoutes.adminMediaCenterBreakingNews,
        ],
      ),
      _SidebarEntrySection(
        title: 'الأنشطة والفعاليات',
        icon: Icons.event_available_rounded,
        routes: const [
          AppRoutes.adminMediaCenterActivities,
          AppRoutes.adminMediaCenterEvents,
          AppRoutes.adminMediaCenterEditorialCalendar,
        ],
      ),
      _SidebarEntrySection(
        title: 'الاجتماعيات',
        icon: Icons.groups_2_rounded,
        routes: const [AppRoutes.adminMediaCenterSocialPosts],
      ),
      _SidebarEntrySection(
        title: 'الوسائط والحملات',
        icon: Icons.photo_library_rounded,
        routes: const [
          AppRoutes.adminMediaCenterPhotos,
          AppRoutes.adminMediaCenterVideos,
          AppRoutes.adminMediaCenterHeroSlider,
          AppRoutes.adminMediaCenterAwarenessCampaigns,
          AppRoutes.adminMediaCenterMediaLibrary,
        ],
      ),
      _SidebarEntrySection(
        title: 'الرصد والتوثيق',
        icon: Icons.shield_rounded,
        routes: const [
          AppRoutes.adminMediaCenterSanctitiesObservatory,
          AppRoutes.adminMediaCenterMediaReports,
          AppRoutes.adminMediaCenterMediaCoverage,
          AppRoutes.adminMediaCenterWaqfImpactStories,
          AppRoutes.adminMediaCenterFridaySermons,
        ],
      ),
      _SidebarEntrySection(
        title: 'الحوكمة الإعلامية',
        icon: Icons.policy_rounded,
        routes: const [AppRoutes.adminMediaCenterGovernance],
      ),
    ];
    final current = widget.currentRoute ?? '';
    final isActive =
        current.startsWith(AppRoutes.adminMediaCenter) ||
        sections.any(
          (section) => section.routes.any((route) => current.startsWith(route)),
        );

    if (collapsed) {
      return _buildNavItem(
        context,
        parent,
        collapsed: collapsed,
        showRoutes: showRoutes,
        showDescription: showDescription,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF133056) : const Color(0xFF132238),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? const Color(0xFFEAB308)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSurfaceServicesParentItem(
            context,
            parent,
            isActive: current == parent.route,
            showDescription: showDescription,
            showRoutes: showRoutes,
          ),
          const SizedBox(height: 8),
          for (final section in sections)
            _buildSidebarEntrySection(
              context,
              section,
              entries: section.routes
                  .map((route) => byRoute[route])
                  .whereType<AdminPanelEntry>()
                  .toList(growable: false),
              showRoutes: showRoutes,
            ),
        ],
      ),
    );
  }

  Widget _buildSurfacesServicesDropdown(
    BuildContext context,
    AdminPanelGroup group, {
    required bool collapsed,
    required bool showRoutes,
    required bool showDescription,
  }) {
    if (group.items.isEmpty) return const SizedBox.shrink();
    final parent = group.items.first;
    final byRoute = <String, AdminPanelEntry>{
      for (final item in group.items) item.route: item,
    };
    final sections = <_SidebarEntrySection>[
      _SidebarEntrySection(
        title: 'إدارة الخدمات العامة',
        icon: Icons.design_services_rounded,
        routes: const [
          AppRoutes.adminServicesPage,
          AppRoutes.adminComplaints,
          AppRoutes.adminZakat,
          AppRoutes.adminPrayerTimes,
          AppRoutes.adminQuran,
        ],
      ),
      _SidebarEntrySection(
        title: 'إدارة الخدمات الإلكترونية',
        icon: Icons.computer_rounded,
        routes: const [
          AppRoutes.adminEServicesPage,
          AppRoutes.adminSurfacesServicesEServicesPortal,
        ],
      ),
      _SidebarEntrySection(
        title: 'إدارة الخدمات السريعة',
        icon: Icons.miscellaneous_services_rounded,
        routes: const [AppRoutes.adminSurfacesServicesQuickServices],
      ),
      _SidebarEntrySection(
        title: 'إدارة الروابط',
        icon: Icons.link_rounded,
        routes: const [
          AppRoutes.adminSurfacesServicesQuickLinks,
          AppRoutes.adminSurfacesServicesImportantLinks,
        ],
      ),
      _SidebarEntrySection(
        title: 'إدارة البطاقات',
        icon: Icons.auto_awesome_rounded,
        routes: const [
          AppRoutes.adminSurfacesServicesFeatureHighlights,
          AppRoutes.adminSurfacesServicesMiniMapTeaser,
        ],
      ),
      _SidebarEntrySection(
        title: 'إدارة الإحصائيات',
        icon: Icons.bar_chart_rounded,
        routes: const [AppRoutes.adminSurfacesServicesStatistics],
      ),
      _SidebarEntrySection(
        title: 'المراجع الرسمية',
        icon: Icons.gavel_rounded,
        routes: const [AppRoutes.adminSurfacesServicesLegalReferences],
      ),
    ];
    final current = widget.currentRoute ?? '';
    final isActive =
        current.startsWith(AppRoutes.adminSurfacesServices) ||
        sections.any(
          (section) => section.routes.any((route) => current.startsWith(route)),
        );

    if (collapsed) {
      return _buildNavItem(
        context,
        parent,
        collapsed: collapsed,
        showRoutes: showRoutes,
        showDescription: showDescription,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF133056) : const Color(0xFF132238),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? const Color(0xFFEAB308)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSurfaceServicesParentItem(
            context,
            parent,
            isActive: current == parent.route,
            showDescription: showDescription,
            showRoutes: showRoutes,
          ),
          const SizedBox(height: 8),
          for (final section in sections)
            _buildSidebarEntrySection(
              context,
              section,
              entries: section.routes
                  .map((route) => byRoute[route])
                  .whereType<AdminPanelEntry>()
                  .toList(growable: false),
              showRoutes: showRoutes,
            ),
        ],
      ),
    );
  }

  Widget _buildSurfaceServicesParentItem(
    BuildContext context,
    AdminPanelEntry parent, {
    required bool isActive,
    required bool showDescription,
    required bool showRoutes,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.go(parent.route),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFEAB308).withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? const Color(0xFFEAB308).withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFEAB308).withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  parent.icon,
                  size: 19,
                  color: isActive ? const Color(0xFFEAB308) : Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parent.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF8FAFC),
                        fontWeight: FontWeight.w900,
                        fontSize: 12.8,
                      ),
                    ),
                    if (showDescription) ...[
                      const SizedBox(height: 4),
                      Text(
                        parent.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.8,
                          height: 1.35,
                          color: Color(0xFFD7E3F6),
                        ),
                      ),
                    ],
                    if (showRoutes) ...[
                      const SizedBox(height: 4),
                      Text(
                        parent.route,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarEntrySection(
    BuildContext context,
    _SidebarEntrySection section, {
    required List<AdminPanelEntry> entries,
    required bool showRoutes,
  }) {
    if (entries.isEmpty) return const SizedBox.shrink();
    final current = widget.currentRoute ?? '';
    final isActive = entries.any((entry) => current.startsWith(entry.route));

    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF0F2A49)
            : Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? const Color(0xFFEAB308).withValues(alpha: 0.28)
              : Colors.white.withValues(alpha: 0.055),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: isActive,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 2,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            iconColor: const Color(0xFFEAB308),
            collapsedIconColor: Colors.white70,
            leading: Icon(
              section.icon,
              size: 18,
              color: isActive ? const Color(0xFFEAB308) : Colors.white70,
            ),
            title: Text(
              section.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 12.3,
                fontWeight: FontWeight.w800,
              ),
            ),
            children: [
              for (final item in entries)
                _buildDropdownChildItem(context, item, showRoutes: showRoutes),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownChildItem(
    BuildContext context,
    AdminPanelEntry item, {
    required bool showRoutes,
  }) {
    final isActive = widget.currentRoute == item.route;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.go(item.route),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFEAB308).withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? const Color(0xFFEAB308).withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 18,
                color: isActive ? const Color(0xFFEAB308) : Colors.white70,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF8FAFC),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                    if (showRoutes) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.route,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    AdminPanelEntry item, {
    required bool collapsed,
    required bool showRoutes,
    required bool showDescription,
  }) {
    final isActive = widget.currentRoute == item.route;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.go(item.route),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF133056)
                  : const Color(0xFF132238),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isActive
                    ? const Color(0xFFEAB308)
                    : Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFFEAB308).withValues(alpha: 0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFEAB308).withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: isActive ? const Color(0xFFEAB308) : Colors.white,
                    size: 20,
                  ),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF8FAFC),
                          ),
                        ),
                        if (showDescription) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: Color(0xFFD7E3F6),
                            ),
                          ),
                        ],
                        if (showRoutes) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              item.route,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFFCBD5E1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (item.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB22222),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.badge.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarEntrySection {
  const _SidebarEntrySection({
    required this.title,
    required this.icon,
    required this.routes,
  });

  final String title;
  final IconData icon;
  final List<String> routes;
}

class _SidebarHintChip extends StatelessWidget {
  const _SidebarHintChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFFEAB308)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
