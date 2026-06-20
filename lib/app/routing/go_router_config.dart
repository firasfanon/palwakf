import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/access/access_provider.dart';
import '../../core/access/access_profile.dart';
import '../../core/access/admin_route_access_contract.dart';
import '../../core/enums/enums.dart';
import '../../features/shells/presentation/forbidden_screen.dart';
import '../../features/platform/access/presentation/pages/pwf_forgot_password_page.dart';
import '../../features/platform/access/presentation/pages/pwf_recovery_callback_page.dart';
import '../../features/platform/access/presentation/pages/pwf_reset_password_page.dart';
import '../../features/platform/access/domain/pwf_access_reason.dart';
import '../../features/platform/access/application/pwf_route_access_guard.dart';
import '../../features/shells/presentation/platform_admin_shell.dart';
import '../../features/shells/presentation/public_shell.dart';
import '../../features/shells/presentation/system_dashboard_placeholder.dart';
import '../../features/shells/presentation/system_shell.dart';
import '../../presentation/screens/admin/auth/login/login_screen.dart';
import '../../presentation/screens/admin/auth/profile/profile_screen.dart';
import '../../presentation/screens/admin/main/dashboard/dashboard_screen.dart';
import '../../presentation/screens/admin/main/dashboard/my_activity_screen.dart';
import '../../presentation/screens/admin/content/reports/reports_screen.dart';
import '../../presentation/screens/admin/main/management/breaking_news_management/breaking_news_management_screen.dart';
import '../../presentation/screens/admin/main/management/hero_slider_management/hero_slider_management_screen.dart';
import '../../presentation/screens/admin/main/management/home_management/homepage_management_screen.dart';
import '../../presentation/screens/admin/main/management/home_management/unit_pages_execution_screen.dart';
import '../../presentation/screens/admin/main/management/home_management/system_surfaces_management_screen.dart';
import '../../presentation/screens/admin/main/management/home_management/unit_surfaces_management_screen.dart';
import '../../presentation/screens/admin/main/management/friday_sermons_management/friday_sermons_management_screen.dart';
import '../../presentation/screens/admin/systems/cases/cases_screen.dart';
import '../../presentation/screens/admin/systems/documents/documents_screen.dart';
import '../../presentation/screens/admin/systems/waqf_lands/waqf_lands_screen.dart';
import '../../presentation/screens/public/about/about_screen.dart';
import '../../presentation/screens/public/activities/activities_screen.dart';
import '../../presentation/screens/public/announcements_screen.dart';
import '../../presentation/screens/public/contact/contact_screen.dart';
import '../../presentation/screens/public/eservices_screen.dart';
import '../../presentation/screens/public/friday_sermon_screen.dart';
import '../../presentation/screens/public/mosques/mosques_screen.dart';
import '../../presentation/screens/public/news/news_screen.dart';
import '../../presentation/screens/public/not_found/not_found_screen.dart';
import '../../presentation/screens/public/projects_screen.dart';
import '../../presentation/screens/public/search/search_screen.dart';
import '../../presentation/screens/public/services/services_screen.dart';
import '../../presentation/screens/public/social_services/social_services_screen.dart';
import '../../presentation/screens/public/structure_screen.dart';
import '../../presentation/screens/public/minister_screen.dart';
import '../../presentation/screens/public/former_ministers_screen.dart';
import '../../presentation/screens/public/vision_mission_screen.dart';
import '../../presentation/screens/public/switch_system/switch_system_screen.dart';
import '../../presentation/screens/public/under_construction_screen.dart';

// New HTML-identity Web pages (home_new)
import '../../features/platform/home/presentation/screens/pages/pwf_news_pages.dart';
import '../../features/platform/home/presentation/screens/pages/pwf_announcements_pages.dart';
import '../../features/platform/home/presentation/screens/pages/pwf_activities_pages.dart';
import '../../features/platform/home/presentation/screens/pages/pwf_misc_pages.dart';
import '../../features/platform/home/presentation/screens/pages/pwf_content_pages.dart';
import '../../features/platform/home/presentation/screens/pages/pwf_platform_frontend_pages.dart';

import 'app_routes.dart';
import 'router_refresh_notifier.dart';
import 'unit_routes.dart';
import 'unit_path_utils.dart';
import 'public_route_canonicalization.dart';
import '../../core/unit/pwf_unit_slug_registry.dart';
import '../../data/models/news_article.dart';
import '../../presentation/screens/public/news_details/news_detail_route_screen.dart';
import '../../presentation/screens/public/unit/unit_home_screen.dart';
import '../../presentation/screens/admin/main/management/users_management/users_management_screen.dart';
import '../../presentation/screens/admin/main/management/mosques_management/mosques_management_screen.dart';
import '../../presentation/screens/admin/main/management/org_units_management/org_units_management_screen.dart';
import '../../presentation/screens/admin/main/management/settings/settings_screen.dart';
import '../../presentation/screens/admin/main/management/developer/developer_tools_screen.dart';
import '../../presentation/screens/admin/main/management/shared_content/shared_content_management_screen.dart';
import '../../features/document_intelligence/presentation/pages/document_intelligence_dashboard_page.dart';
import '../../features/document_intelligence/presentation/pages/document_job_create_page.dart';
import '../../features/document_intelligence/presentation/pages/document_job_detail_page.dart';
import '../../features/document_intelligence/presentation/pages/document_review_queue_page.dart';
import '../../features/document_intelligence/presentation/pages/document_review_page.dart';
import '../../features/document_intelligence/presentation/pages/document_linking_page.dart';
import '../../features/media_center/presentation/pages/media_center_dashboard_page.dart';
import '../../features/media_center_mobile/presentation/pages/media_center_mobile_app_page.dart';
import '../../features/media_center_mobile/presentation/pages/media_center_mobile_operational_home_page.dart';
import '../../features/media_center_public/presentation/pages/official_media_detail_page.dart';
import '../../features/media_center_mobile/presentation/pages/media_center_quick_publish_page.dart';
import '../../features/media_center_mobile/presentation/pages/media_center_local_drafts_page.dart';
import '../../features/platform/media_center/presentation/pages/media_center_operational_pages.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../features/platform/assistant/assistant_core/data/services/chat_route_context_service.dart';
import '../../features/platform/home/presentation/screens/pwf_web_page_scaffold.dart';
import '../../features/platform/assistant/internal_assistant/data/models/assistant_context.dart';
import '../../features/platform/assistant/internal_assistant/presentation/pages/internal_assistant_page.dart';
import '../../features/platform/assistant/public_chatbot/presentation/pages/public_chatbot_page.dart';

// Zakat / Prayer Times / Quran (Public + Systems)
import '../../features/platform/governance/complaints/presentation/screens/pwf_complaints_screen.dart';
import '../../features/platform/governance/complaints/presentation/screens/admin/pwf_admin_complaints_screen.dart';
import '../../features/platform/services/zakat/presentation/screens/pwf_zakat_public_screen.dart';
import '../../features/platform/services/prayer_times/presentation/screens/pwf_prayer_times_public_screen.dart';
import '../../features/platform/services/quran/presentation/screens/pwf_quran_public_screen.dart';
import '../../features/platform/services/zakat/presentation/screens/admin/pwf_zakat_admin_dashboard_screen.dart';
import '../../features/platform/services/prayer_times/presentation/screens/admin/pwf_prayer_times_admin_dashboard_screen.dart';
import '../../features/platform/services/quran/presentation/screens/admin/pwf_quran_admin_dashboard_screen.dart';
import '../../features/platform/home/presentation/screens/admin/pwf_public_pages_admin_screens.dart';
import '../../features/platform/home/presentation/screens/admin/pwf_surfaces_services_admin_hub_screen.dart';
import '../../presentation/screens/admin/main/usage_guide/usage_guide_screen.dart';
import '../../features/tasks_system/presentation/pages/tasks_dashboard_page.dart';
import '../../features/tasks_system/presentation/pages/task_form_page.dart';
import '../../features/tasks_system/presentation/pages/task_detail_page.dart';
import '../../features/platform/awqaf_integration/presentation/pages/awqaf_waqf_assets_integration_intake_page.dart';
import '../../features/platform/integration_contracts/presentation/pages/pwf_cross_system_integration_page.dart';
import '../../features/platform/dynamic_systems/presentation/pages/pwf_dynamic_system_page.dart';
import '../../features/platform/dynamic_systems/presentation/pages/pwf_dynamic_system_home_page.dart';
import '../../features/platform/dynamic_systems/presentation/pages/pwf_dynamic_system_registry_admin_page.dart';
import '../../features/platform/dynamic_systems/presentation/pages/pwf_platform_system_operations_page.dart';
import '../../features/platform/technical_services/presentation/pages/pwf_technical_services_page.dart';
import '../../features/platform/database_migration/presentation/pages/pwf_database_domain_migration_page.dart';
import '../../features/platform_design_system/presentation/routes/pwf_sis_routes.dart';

part 'route_groups/common_routes_group.dart';
part 'route_groups/public_routes_group.dart';
part 'route_groups/auth_routes_group.dart';
part 'route_groups/admin_routes_group.dart';
part 'route_groups/system_routes_group.dart';

class GoRouterConfig {
  static GoRouter build(Ref ref) {
    final refresh = GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
      onEvent: () {
        // Session identity and JWT changes may change the self-authority DTO.
        // Clear only local cache; server-side authorization remains authoritative.
        ref.read(accessRepositoryProvider).clearCache();
        ref.invalidate(accessProfileProvider);
      },
    );

    return GoRouter(
      // Official sites should land directly on the ministry home.
      initialLocation: AppRoutes.home,
      refreshListenable: refresh,
      debugLogDiagnostics: true,
      redirect: (context, state) async {
        final location = state.uri.path;
        final canonicalPublicRoute = PwfPublicRouteCanonicalization.redirectFor(
          location,
          query: state.uri.query,
        );
        if (canonicalPublicRoute != null) return canonicalPublicRoute;

        final canonicalUnitRoute = PwfUnitSlugRegistry.redirectLegacyPath(
          location,
          query: state.uri.query,
        );
        if (canonicalUnitRoute != null) return canonicalUnitRoute;

        final isLogin =
            location == AppRoutes.login || location == AppRoutes.adminLogin;
        final isAdminRoute = location.startsWith('/admin');
        final systemKey = _systemKeyFromLocation(location);
        final isSystemRoute = systemKey != null;

        final user = Supabase.instance.client.auth.currentUser;
        final freshLoginRequested = state.uri.queryParameters['fresh'] == '1' ||
            state.uri.queryParameters['reauth'] == '1' ||
            state.uri.queryParameters['forceLogin'] == '1';

        if (isLogin && freshLoginRequested && user != null) {
          await Supabase.instance.client.auth.signOut();
          ref.read(authStateProvider.notifier).clearLocalSession();
          return null;
        }

        // If already authenticated, keep them out of login unless fresh login was requested.
        // Route them to a sensible destination based on their access profile.
        if (isLogin && user != null) {
          final repo = ref.read(accessRepositoryProvider);
          var profile = repo.getCached(user.id);
          profile ??= await repo.load(user.id);

          if (profile != null && !profile.isActive) {
            return _forbiddenLocation(state, PwfAccessReason.inactiveProfile);
          }

          final from = state.uri.queryParameters['from'];
          if (from != null && from.isNotEmpty) {
            final decodedFrom = Uri.decodeComponent(from);
            return _operationalTargetAfterLogin(decodedFrom, profile);
          }

          // Any active admin_users account may enter the admin shell.
          if (profile != null) {
            return AppRoutes.adminDashboard;
          }

          return AppRoutes.home;
        }

        // Protected areas: admin routes (except /admin/login) and system routes.
        final isProtected =
            (isAdminRoute && location != AppRoutes.adminLogin) || isSystemRoute;

        if (isProtected && user == null) {
          final from = Uri.encodeComponent(state.uri.toString());
          return '${AppRoutes.login}?from=$from';
        }

        if (user == null) return null;

        // Load cached profile; if missing, load once (Fail-Closed by forbidding on null)
        final repo = ref.read(accessRepositoryProvider);
        var profile = repo.getCached(user.id);
        profile ??= await repo.load(user.id);

        if (profile != null && !profile.isActive) {
          return _forbiddenLocation(state, PwfAccessReason.inactiveProfile);
        }

        final isTasksAdminRoute = location == AppRoutes.adminTasks ||
            location == AppRoutes.adminTaskForm ||
            RegExp(r'^/admin/tasks/[^/]+$').hasMatch(location) ||
            RegExp(r'^/admin/tasks/[^/]+/edit$').hasMatch(location);
        final isTasksWriteRoute = location == AppRoutes.tasksNew ||
            RegExp(r'^/tasks/[^/]+/edit$').hasMatch(location);

        if (isAdminRoute && location != AppRoutes.adminLogin) {
          if (profile == null) {
            return _forbiddenLocation(
                state, PwfAccessReason.missingAccessProfile);
          }

          final dynamicSystemKey = _dynamicSystemKeyFromAdminLocation(location);
          if (dynamicSystemKey != null &&
              !profile.canAccessDynamicSystem(dynamicSystemKey)) {
            return _forbiddenLocation(state, PwfAccessReason.systemRoleDenied);
          }

          final routeDecision =
              AdminRouteAccessContracts.decide(location, profile);
          if (!routeDecision.allowed) {
            return _forbiddenLocation(state, PwfAccessReason.adminAccessDenied);
          }

          // Legacy task routes remain guarded explicitly because some task detail
          // routes are dynamic and may not be represented as a static registry entry.
          if (isTasksAdminRoute) {
            if (!profile.canManageSystem(SystemKey.tasks)) {
              return _forbiddenLocation(
                  state, PwfAccessReason.systemRoleDenied);
            }
          }
        }

        if (isSystemRoute) {
          if (profile == null) {
            return _forbiddenLocation(
                state, PwfAccessReason.missingAccessProfile);
          }
          if (!profile.canAccessSystem(systemKey)) {
            return _forbiddenLocation(state, PwfAccessReason.systemRoleDenied);
          }
        }

        if (isTasksWriteRoute) {
          if (profile == null) {
            return _forbiddenLocation(
                state, PwfAccessReason.missingAccessProfile);
          }
          if (!profile.canWriteSystem(SystemKey.tasks)) {
            return _forbiddenLocation(state, PwfAccessReason.systemRoleDenied);
          }
        }

        return null;
      },
      routes: [
        ..._buildCommonRoutes(),
        ..._buildAuthRoutes(),
        _buildAdminShellRoute(ref),
        ..._buildSystemShellRoutes(),
        _buildPublicShellRoute(),
      ],
    );
  }

  static AssistantContextSeed _buildAssistantSeed(
      Ref ref, GoRouterState state) {
    final currentUser = ref.read(currentUserProvider);
    final access = ref.read(accessCachedProvider);
    final from = state.uri.queryParameters['from'] ?? AppRoutes.adminDashboard;
    final routeContext = ChatRouteContextService.resolve(
      from,
      fallbackUnitSlug: state.uri.queryParameters['unit'] ?? 'home',
    );

    final permissions =
        _permissionsForAssistantSystem(access, routeContext.systemKey);
    final unitSlug = state.uri.queryParameters['unit'] ?? routeContext.unitSlug;
    final waqfAssetId = state.uri.queryParameters['waqf_asset_id'] ??
        state.uri.queryParameters['waqfAssetId'] ??
        state.uri.queryParameters['asset_id'] ??
        state.uri.queryParameters['assetId'] ??
        routeContext.waqfAssetId;
    final nationalAssetCode =
        state.uri.queryParameters['national_asset_code'] ??
            state.uri.queryParameters['nationalAssetCode'] ??
            state.uri.queryParameters['asset_code'] ??
            state.uri.queryParameters['assetCode'] ??
            routeContext.nationalAssetCode;

    return AssistantContextSeed(
      displayName: currentUser?.name ?? currentUser?.email ?? 'PalWakf User',
      adminUserId:
          currentUser?.id ?? Supabase.instance.client.auth.currentUser?.id,
      systemKey: routeContext.systemKey,
      systemLabel: routeContext.pageLabelAr == 'لوحة الإدارة' &&
              routeContext.systemKey == 'awqaf_system'
          ? 'نظام الأوقاف'
          : _systemLabelForAssistant(routeContext.systemKey),
      roleLabel: _roleLabelForAssistant(
          access, currentUser?.role, routeContext.systemKey),
      permissions: permissions,
      currentRoute: from,
      unitId: unitSlug,
      unitSlug: unitSlug,
      waqfAssetId: waqfAssetId,
      nationalAssetCode: nationalAssetCode,
      currentPageLabel:
          state.uri.queryParameters['pageAr'] ?? routeContext.pageLabelAr,
      lastActionLabel:
          state.uri.queryParameters['pageAr'] ?? routeContext.pageLabelAr,
      lastRoute: from,
      knowledgeScopeLabel: 'داخلي',
    );
  }

  static String _systemLabelForAssistant(String systemKey) {
    switch (systemKey) {
      case 'mustakshif':
      case 'mustakshif_alwaqf':
        return 'مستكشف الوقف';
      case 'waqf_cases_system':
        return 'نظام القضايا الوقفية';
      case 'billing_system':
        return 'نظام الفوترة';
      case 'tasks_system':
        return 'نظام المهام';
      case 'public_site':
        return 'الموقع العام';
      case 'awqaf_system':
      default:
        return 'نظام الأوقاف';
    }
  }

  static String _roleLabelForAssistant(
      AccessProfile? access, String? fallbackRole, String systemKey) {
    if (access?.isSuperuser == true) return 'superuser';
    final role = _roleForAssistantSystem(access, systemKey);
    if (role != null) return role.name;
    return (fallbackRole == null || fallbackRole.trim().isEmpty)
        ? 'viewer'
        : fallbackRole.trim();
  }

  static List<String> _permissionsForAssistantSystem(
      AccessProfile? access, String systemKey) {
    final perms = access == null
        ? const <Permission>{}
        : (access.permissions[_assistantSystemKey(systemKey)] ??
            const <Permission>{});
    return perms.map((e) => e.name).toList()..sort();
  }

  static UserRole? _roleForAssistantSystem(
      AccessProfile? access, String systemKey) {
    if (access == null) return null;
    return access.roles[_assistantSystemKey(systemKey)];
  }

  static SystemKey _assistantSystemKey(String systemKey) {
    switch (systemKey) {
      case 'mustakshif':
      case 'mustakshif_alwaqf':
        return SystemKey.mustakshif;
      case 'waqf_cases_system':
        return SystemKey.cases;
      case 'billing_system':
        return SystemKey.billing;
      case 'tasks_system':
        return SystemKey.tasks;
      case 'public_site':
        return SystemKey.site;
      case 'awqaf_system':
      default:
        return SystemKey.awqafSystem;
    }
  }

  static String _forbiddenLocation(
    GoRouterState state,
    PwfAccessReason reason, {
    String? unitSlug,
  }) {
    return PwfRouteAccessGuard.forbiddenLocation(
      reason: reason,
      currentLocation: state.uri.toString(),
      unitSlug: unitSlug,
    );
  }

  static String _operationalTargetAfterLogin(
    String decodedFrom,
    AccessProfile? profile,
  ) {
    final uri = Uri.tryParse(decodedFrom);
    final path = uri?.path ?? decodedFrom.split('?').first;
    final isAwqafPublicEntry = path == '/systems/awqaf-system' ||
        RegExp(r'^/[^/]+/systems/awqaf-system/?$').hasMatch(path);
    if (!isAwqafPublicEntry) return decodedFrom;

    if (profile == null || !profile.isActive) return decodedFrom;
    if (!profile.canAccessSystemByAlias('awqaf_system'))
      return AppRoutes.forbidden;

    final segments = uri?.pathSegments ?? Uri.parse(path).pathSegments;
    if (segments.length >= 3 && segments[1] == 'systems') {
      return '/${segments[0]}/systems/awqaf-system/dashboard';
    }
    return '/systems/awqaf-system/dashboard';
  }

  static String? _dynamicSystemKeyFromAdminLocation(String location) {
    final segments = Uri.parse(location).pathSegments;
    if (segments.length >= 3 &&
        segments[0] == 'admin' &&
        segments[1] == 'systems') {
      return Uri.decodeComponent(segments[2]);
    }
    return null;
  }

  static SystemKey? _systemKeyFromLocation(String location) {
    if (location.startsWith('/mustakshif')) return SystemKey.mustakshif;
    if (location.startsWith('/systems/awqaf-system/dashboard') ||
        RegExp(r'^/[^/]+/systems/awqaf-system/dashboard(/|$)')
            .hasMatch(location)) {
      return SystemKey.awqafSystem;
    }
    if (location.startsWith('/admin-data')) return SystemKey.adminData;
    if (location.startsWith('/lands')) return SystemKey.lands;
    if (location.startsWith('/properties')) return SystemKey.properties;
    if (location.startsWith('/cases')) return SystemKey.cases;
    if (location.startsWith('/tasks')) return SystemKey.tasks;
    if (location.startsWith('/mosques-system')) return SystemKey.mosques;
    if (location.startsWith('/billing')) return SystemKey.billing;
    return null;
  }
}
