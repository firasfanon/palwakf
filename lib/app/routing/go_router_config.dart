import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/access/access_provider.dart';
import '../../core/enums/enums.dart';
import '../../features/shells/presentation/forbidden_screen.dart';
import '../../features/shells/presentation/platform_admin_shell.dart';
import '../../features/shells/presentation/public_shell.dart';
import '../../features/shells/presentation/system_dashboard_placeholder.dart';
import '../../features/shells/presentation/system_shell.dart';
import '../../presentation/screens/admin/auth/login/login_screen.dart';
import '../../presentation/screens/admin/auth/profile/profile_screen.dart';
import '../../presentation/screens/admin/main/dashboard/dashboard_screen.dart';
import '../../presentation/screens/admin/main/management/activities_management/activities_management_screen.dart';
import '../../presentation/screens/admin/main/management/breaking_news_management/breaking_news_management_screen.dart';
import '../../presentation/screens/admin/main/management/hero_slider_management/hero_slider_management_screen.dart';
import '../../presentation/screens/admin/main/management/home_management/homepage_management_screen.dart';
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
import '../../presentation/screens/public/home/home_screen.dart';
import '../../presentation/screens/public/mosques/mosques_screen.dart';
import '../../presentation/screens/public/news/news_screen.dart';
import '../../presentation/screens/public/news_details/news_detail_screen.dart';
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
import 'app_routes.dart';
import 'router_refresh_notifier.dart';
import 'unit_routes.dart';
import '../../data/models/news_article.dart';
import '../../presentation/screens/public/news_details/news_detail_route_screen.dart';
import '../../presentation/screens/public/unit/unit_home_screen.dart';
import '../../presentation/screens/admin/main/management/users_management/users_management_screen.dart';
import '../../presentation/screens/admin/main/management/mosques_management/mosques_management_screen.dart';
import '../../presentation/screens/admin/main/management/org_units_management/org_units_management_screen.dart';

class GoRouterConfig {
  static GoRouter build(Ref ref) {
    final refresh = GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    );

    return GoRouter(
      // Official sites should land directly on the ministry home.
      initialLocation: AppRoutes.home,
      refreshListenable: refresh,
      debugLogDiagnostics: true,
      redirect: (context, state) async {
        final location = state.uri.path;

        final isLogin = location == AppRoutes.login || location == AppRoutes.adminLogin;
        final isAdminRoute = location.startsWith('/admin');
        final systemKey = _systemKeyFromLocation(location);
        final isSystemRoute = systemKey != null;

        final user = Supabase.instance.client.auth.currentUser;

        // If already authenticated, keep them out of login.
        // Route them to a sensible destination based on their access profile.
        if (isLogin && user != null) {
          final repo = ref.read(accessRepositoryProvider);
          var profile = repo.getCached(user.id);
          profile ??= await repo.load(user.id);

          if (profile != null && !profile.isActive) {
            return AppRoutes.forbidden;
          }

          final from = state.uri.queryParameters['from'];
          if (from != null && from.isNotEmpty) {
            return Uri.decodeComponent(from);
          }

          if (profile != null &&
              (profile.isSuperuser || profile.can(SystemKey.platformAdmin, Permission.manageUsers))) {
            return AppRoutes.adminDashboard;
          }

          return AppRoutes.home;
        }

        // Protected areas: admin routes (except /admin/login) and system routes.
        final isProtected = (isAdminRoute && location != AppRoutes.adminLogin) || isSystemRoute;

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
          return AppRoutes.forbidden;
        }

        if (isAdminRoute && location != AppRoutes.adminLogin) {
          if (profile == null) return AppRoutes.forbidden;
          final allowed = profile.isSuperuser || profile.can(SystemKey.platformAdmin, Permission.manageUsers);
          if (!allowed) return AppRoutes.forbidden;
        }

        if (isSystemRoute) {
          if (profile == null) return AppRoutes.forbidden;
          if (!profile.hasRoleAtLeast(systemKey!, UserRole.viewer)) {
            return AppRoutes.forbidden;
          }
        }

        return null;
      },
      routes: [
        // Transition page used when moving from the public site into a service system.
        GoRoute(
          path: '${AppRoutes.switchSystemBase}/:systemKey',
          builder: (context, state) {
            final key = state.pathParameters['systemKey'] ?? '';
            return SwitchSystemScreen(systemKeySlug: key);
          },
        ),

        // Public shell
        ShellRoute(
          builder: (context, state, child) => PublicShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.root,
              redirect: (context, state) => AppRoutes.home,
            ),
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: AppRoutes.news,
              redirect: (context, state) => UnitRoutes.news('home'),
            ),
            GoRoute(
              path: AppRoutes.newsDetail,
              redirect: (context, state) => UnitRoutes.news('home'),
            ),
            GoRoute(
              path: AppRoutes.announcements,
              redirect: (context, state) => UnitRoutes.announcements('home'),
            ),
            GoRoute(
              path: AppRoutes.activities,
              redirect: (context, state) => UnitRoutes.activities('home'),
            ),
            GoRoute(
              path: AppRoutes.services,
              builder: (context, state) => const ServicesScreen(),
            ),
            GoRoute(
              path: AppRoutes.eservices,
              builder: (context, state) => const EServicesScreen(),
            ),
            GoRoute(
              path: AppRoutes.socialServices,
              builder: (context, state) => const SocialServicesScreen(),
            ),
            GoRoute(
              path: AppRoutes.mosques,
              builder: (context, state) => const MosquesScreen(),
            ),
            GoRoute(
              path: AppRoutes.projects,
              builder: (context, state) => const ProjectsScreen(),
            ),
            GoRoute(
              path: AppRoutes.about,
              builder: (context, state) => const AboutScreen(),
            ),
            GoRoute(
              path: AppRoutes.minister,
              builder: (context, state) => const MinisterScreen(),
            ),
            GoRoute(
              path: AppRoutes.visionMission,
              builder: (context, state) => const VisionMissionScreen(),
            ),
            GoRoute(
              path: AppRoutes.structure,
              builder: (context, state) => const StructureScreen(),
            ),
            GoRoute(
              path: AppRoutes.formerMinisters,
              builder: (context, state) => const FormerMinistersScreen(),
            ),
            GoRoute(
              path: AppRoutes.contact,
              builder: (context, state) => const ContactScreen(),
            ),
            GoRoute(
              path: AppRoutes.search,
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
              path: AppRoutes.fridaySermon,
              builder: (context, state) => const FridaySermonScreen(),
            ),
            
            // Unit-scoped public routes (/:unitSlug/*)
            GoRoute(
              path: '/:unitSlug',
              builder: (context, state) {
                final slug = (state.pathParameters['unitSlug'] ?? 'home').toLowerCase();
                return UnitHomeScreen(unitSlug: slug);
              },
              routes: [
                GoRoute(
                  path: 'news',
                  builder: (context, state) {
                    final slug = (state.pathParameters['unitSlug'] ?? 'home').toLowerCase();
                    return NewsScreen(unitSlug: slug);
                  },
                ),
                GoRoute(
                  path: 'news/:id',
                  builder: (context, state) {
                    final slug = (state.pathParameters['unitSlug'] ?? 'home').toLowerCase();
                    final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                    final extra = state.extra is NewsArticle ? state.extra as NewsArticle : null;
                    return NewsDetailRouteScreen(unitSlug: slug, id: id, extraArticle: extra);
                  },
                ),
                GoRoute(
                  path: 'announcements',
                  builder: (context, state) {
                    final slug = (state.pathParameters['unitSlug'] ?? 'home').toLowerCase();
                    return AnnouncementsScreen(unitSlug: slug);
                  },
                ),
                GoRoute(
                  path: 'activities',
                  builder: (context, state) {
                    final slug = (state.pathParameters['unitSlug'] ?? 'home').toLowerCase();
                    return ActivitiesScreen(unitSlug: slug);
                  },
                ),
              ],
            ),
GoRoute(
              path: AppRoutes.notFound,
              builder: (context, state) => const NotFoundScreen(),
            ),
          ],
        ),

        // Auth
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.adminLogin,
          builder: (context, state) => const LoginScreen(),
        ),

        // Forbidden
        GoRoute(
          path: AppRoutes.forbidden,
          builder: (context, state) => const ForbiddenScreen(),
        ),

        // Platform Admin shell
        ShellRoute(
          builder: (context, state, child) => PlatformAdminShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.adminDashboard,
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminUsers,
              builder: (context, state) => const UsersManagementScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminProfile,
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminWaqfLands,
              builder: (context, state) => const WaqfLandsScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminCases,
              builder: (context, state) => const CasesScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminDocuments,
              builder: (context, state) => const DocumentsScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminHomeManagement,
              builder: (context, state) => const HomeManagementScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminHeroSlider,
              builder: (context, state) => const HeroSliderManagementScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminBreakingNews,
              builder: (context, state) => const BreakingNewsManagementScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminActivitiesManagement,
              builder: (context, state) => const ActivitiesManagementScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminFridaySermons,
              builder: (context, state) => const FridaySermonsManagementScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminMosques,
              builder: (context, state) => const MosquesManagementScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminOrgUnits,
              builder: (context, state) => const OrgUnitsManagementScreen(),
            ),
          ],
        ),

        // System shells (placeholders)
        ShellRoute(
          builder: (context, state, child) => SystemShell(
            systemKey: SystemKey.mustakshif,
            child: child,
          ),
          routes: [
            GoRoute(
              path: AppRoutes.mustakshif,
              builder: (context, state) => const SystemDashboardPlaceholder(systemKey: SystemKey.mustakshif),
            ),
          ],
        ),
        ShellRoute(
          builder: (context, state, child) => SystemShell(
            systemKey: SystemKey.adminData,
            child: child,
          ),
          routes: [
            GoRoute(
              path: AppRoutes.adminData,
              builder: (context, state) => const SystemDashboardPlaceholder(systemKey: SystemKey.adminData),
            ),
          ],
        ),
        ShellRoute(
          builder: (context, state, child) => SystemShell(
            systemKey: SystemKey.lands,
            child: child,
          ),
          routes: [
            GoRoute(
              path: AppRoutes.lands,
              builder: (context, state) => const SystemDashboardPlaceholder(systemKey: SystemKey.lands),
            ),
          ],
        ),
        ShellRoute(
          builder: (context, state, child) => SystemShell(
            systemKey: SystemKey.properties,
            child: child,
          ),
          routes: [
            GoRoute(
              path: AppRoutes.properties,
              builder: (context, state) => const SystemDashboardPlaceholder(systemKey: SystemKey.properties),
            ),
          ],
        ),
        ShellRoute(
          builder: (context, state, child) => SystemShell(
            systemKey: SystemKey.cases,
            child: child,
          ),
          routes: [
            GoRoute(
              path: AppRoutes.cases,
              builder: (context, state) => const SystemDashboardPlaceholder(systemKey: SystemKey.cases),
            ),
          ],
        ),
        ShellRoute(
          builder: (context, state, child) => SystemShell(
            systemKey: SystemKey.tasks,
            child: child,
          ),
          routes: [
            GoRoute(
              path: AppRoutes.tasks,
              builder: (context, state) => const SystemDashboardPlaceholder(systemKey: SystemKey.tasks),
            ),
          ],
        ),
        ShellRoute(
          builder: (context, state, child) => SystemShell(
            systemKey: SystemKey.mosques,
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/mosques-system',
              builder: (context, state) => const SystemDashboardPlaceholder(systemKey: SystemKey.mosques),
            ),
          ],
        ),
        ShellRoute(
          builder: (context, state, child) => SystemShell(
            systemKey: SystemKey.billing,
            child: child,
          ),
          routes: [
            GoRoute(
              path: AppRoutes.billing,
              builder: (context, state) => const SystemDashboardPlaceholder(systemKey: SystemKey.billing),
            ),
          ],
        ),
      ],
    );
  }

  static SystemKey? _systemKeyFromLocation(String location) {
    if (location.startsWith('/mustakshif')) return SystemKey.mustakshif;
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
