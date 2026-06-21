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
    final activeWorkspace = visibleTabs.firstWhere(
      (tab) => tab.key == effectiveTab,
      orElse: () => visibleTabs.first,
    );
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
      width: collapsed ? 76 : 304,
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
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
          children: [
            _buildHeader(
              collapsed: collapsed,
              showRoutes: showRoutes,
              showPageNames: showPageNames,
            ),
            const SizedBox(height: 10),
            _buildTabBar(
              tabs: visibleTabs,
              activeTabKey: effectiveTab,
              collapsed: collapsed,
            ),
            if (!collapsed) ...[
              const SizedBox(height: 12),
              _buildWorkspaceCaption(activeWorkspace, groups),
            ],
            const SizedBox(height: 4),
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

  Widget _buildWorkspaceCaption(
    AdminPanelTabItem workspace,
    List<AdminPanelGroup> groups,
  ) {
    final subtitle = groups.length == 1
        ? groups.first.subtitle
        : 'اختر الباب المناسب ضمن الفئات المرتبة أدناه.';
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 2, 6, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workspace.label,
            style: const TextStyle(
              color: Color(0xFFF8FAFC),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11.3,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
      padding: EdgeInsets.symmetric(
        horizontal: collapsed ? 8 : 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF101C30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEAB308).withValues(alpha: 0.20),
        ),
      ),
      child: collapsed
          ? IconButton(
              tooltip: 'توسيع الشريط الجانبي',
              onPressed: () => ref
                  .read(adminSidebarCollapsedProvider.notifier)
                  .state = false,
              icon: SizedBox(
                width: 36,
                height: 36,
                child: Image.asset(AppConstants.appLogo, fit: BoxFit.contain),
              ),
            )
          : Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Image.asset(AppConstants.appLogo, fit: BoxFit.contain),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'لوحة التحكم',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'إدارة منصة PalWakf',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFFCBD5E1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'طي الشريط الجانبي',
                  onPressed: () => ref
                      .read(adminSidebarCollapsedProvider.notifier)
                      .state = true,
                  icon: const Icon(
                    Icons.keyboard_double_arrow_right_rounded,
                    color: Color(0xFFEAB308),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabBar({
    required List<AdminPanelTabItem> tabs,
    required String activeTabKey,
    required bool collapsed,
  }) {
    final activeTab = tabs.firstWhere(
      (tab) => tab.key == activeTabKey,
      orElse: () => tabs.first,
    );

    return PopupMenuButton<String>(
      tooltip: 'تغيير مساحة العمل',
      onSelected: (key) => setState(() => _activeTab = key),
      color: const Color(0xFF132238),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        for (final tab in tabs)
          PopupMenuItem<String>(
            value: tab.key,
            child: Row(
              children: [
                Icon(
                  tab.icon,
                  size: 19,
                  color: tab.key == activeTabKey
                      ? const Color(0xFFEAB308)
                      : const Color(0xFFCBD5E1),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tab.label,
                    style: TextStyle(
                      color: tab.key == activeTabKey
                          ? Colors.white
                          : const Color(0xFFE2E8F0),
                      fontWeight: tab.key == activeTabKey
                          ? FontWeight.w900
                          : FontWeight.w700,
                    ),
                  ),
                ),
                if (tab.key == activeTabKey)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: Color(0xFFEAB308),
                  ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: collapsed ? 0 : 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF132238),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisAlignment: collapsed
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(activeTab.icon, color: const Color(0xFFEAB308), size: 20),
            if (!collapsed) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  activeTab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontWeight: FontWeight.w900,
                    fontSize: 12.8,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFCBD5E1),
              ),
            ],
          ],
        ),
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
    if (collapsed) return const SizedBox(height: 4);
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
      child: Text(
        group.title,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          color: Color(0xFF94A3B8),
        ),
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
    final byRoute = <String, AdminPanelEntry>{
      for (final item in group.items) _normalizeRoute(item.route): item,
    };
    final sectionedRoutes = <String>{
      for (final section in sections)
        for (final route in section.routes) _normalizeRoute(route),
    };
    final hubItems = group.items
        .where((item) => !sectionedRoutes.contains(_normalizeRoute(item.route)))
        .toList(growable: false);

    if (collapsed) {
      final collapsedItem = hubItems.isNotEmpty ? hubItems.first : group.items.first;
      return _buildNavItem(
        context,
        collapsedItem,
        collapsed: true,
        showRoutes: showRoutes,
        showDescription: false,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF101B2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in hubItems) ...[
            _buildSurfaceServicesParentItem(
              context,
              item,
              isActive: _routeIsActive(item.route),
              showDescription: showDescription,
              showRoutes: showRoutes,
            ),
            const SizedBox(height: 6),
          ],
          for (final section in sections)
            _buildSidebarEntrySection(
              context,
              _SidebarEntrySection(
                title: section.title,
                icon: section.icon,
                routes: section.routes,
              ),
              entries: section.routes
                  .map((route) => byRoute[_normalizeRoute(route)])
                  .whereType<AdminPanelEntry>()
                  .toList(growable: false),
              showRoutes: showRoutes,
            ),
        ],
      ),
    );
  }

  bool _routeIsActive(String route) {
    final current = _normalizeRoute(widget.currentRoute);
    final candidate = _normalizeRoute(route);
    return current == candidate ||
        (candidate.isNotEmpty && current.startsWith('$candidate/'));
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
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go(parent.route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF173B66)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? const Color(0xFFEAB308).withValues(alpha: 0.62)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Icon(
                parent.icon,
                size: 18,
                color: isActive ? const Color(0xFFEAB308) : Colors.white,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  parent.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
                size: 18,
                color: Color(0xFF94A3B8),
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
    final isActive = entries.any((entry) => _routeIsActive(entry.route));

    return Container(
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF102B4A)
            : Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? const Color(0xFFEAB308).withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.045),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: isActive,
            maintainState: true,
            tilePadding: const EdgeInsets.symmetric(horizontal: 10),
            childrenPadding: const EdgeInsets.fromLTRB(7, 0, 7, 7),
            visualDensity: VisualDensity.compact,
            iconColor: const Color(0xFFEAB308),
            collapsedIconColor: const Color(0xFF94A3B8),
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
                fontSize: 12.1,
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
    final isActive = _routeIsActive(item.route);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.go(item.route),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFEAB308).withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 16,
                color: isActive ? const Color(0xFFEAB308) : Colors.white70,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFFE2E8F0),
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12.2,
                  ),
                ),
              ),
              if (item.badge != null)
                _buildBadge(item.badge!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(int value) {
    return Container(
      margin: const EdgeInsetsDirectional.only(start: 6),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFB22222),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
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
    final isActive = _routeIsActive(item.route);
    final tooltip = showDescription ? item.description : item.label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Tooltip(
        message: collapsed ? tooltip : '',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.go(item.route),
            child: Container(
              height: collapsed ? 48 : 46,
              padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 11),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF173B66)
                    : Colors.white.withValues(alpha: 0.025),
                borderRadius: BorderRadius.circular(12),
                border: BorderDirectional(
                  start: BorderSide(
                    color: isActive
                        ? const Color(0xFFEAB308)
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    item.icon,
                    size: 19,
                    color: isActive ? const Color(0xFFEAB308) : Colors.white70,
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.7,
                          fontWeight: isActive
                              ? FontWeight.w900
                              : FontWeight.w700,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    if (item.badge != null) _buildBadge(item.badge!),
                  ],
                ],
              ),
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
