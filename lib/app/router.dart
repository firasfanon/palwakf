// lib/app/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/presentation/screens/admin/auth/login/login_screen.dart';
import 'package:waqf/presentation/screens/admin/auth/profile/profile_screen.dart';
import 'package:waqf/presentation/screens/admin/main/dashboard/dashboard_screen.dart';
import 'package:waqf/presentation/screens/admin/main/management/activities_management/activities_management_screen.dart';
import 'package:waqf/presentation/screens/admin/main/management/breaking_news_management/breaking_news_management_screen.dart';
import 'package:waqf/presentation/screens/admin/main/management/hero_slider_management/hero_slider_management_screen.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/homepage_management_screen.dart';
import 'package:waqf/presentation/screens/admin/systems/cases/cases_screen.dart';
import 'package:waqf/presentation/screens/admin/systems/documents/documents_screen.dart';
import 'package:waqf/presentation/screens/admin/systems/waqf_lands/waqf_lands_screen.dart';
import 'package:waqf/presentation/screens/public/mosques/mosques_screen.dart';
import 'package:waqf/presentation/screens/public/news/news_screen.dart';
import '../presentation/screens/public/home/home_screen.dart';
import '../presentation/screens/public/not_found/not_found_screen.dart';
import '../presentation/screens/public/services/services_screen.dart';
import '../presentation/screens/public/splash/splash_screen.dart';
import '../presentation/screens/public/news_details/news_detail_screen.dart';
import '../presentation/screens/public/announcements_screen.dart';
import '../presentation/screens/public/eservices_screen.dart';
import '../presentation/screens/public/projects_screen.dart';
import '../presentation/screens/public/about/about_screen.dart';
import '../presentation/screens/public/minister_screen.dart';
import '../presentation/screens/public/vision_mission_screen.dart';
import '../presentation/screens/public/structure_screen.dart';
import '../presentation/screens/public/former_ministers_screen.dart';
import '../presentation/screens/public/contact/contact_screen.dart';
import '../presentation/screens/public/search/search_screen.dart';
import '../presentation/providers/auth_provider.dart';
import '../data/models/news_article.dart';


class AppRouter {
  // Public Routes
  static const String splash = '/';
  static const String home = '/home';
  static const String news = '/news';
  static const String newsDetail = '/news/detail';
  static const String announcements = '/announcements';
  static const String activities = '/activities';
  static const String services = '/services';
  static const String eservices = '/eservices';
  static const String mosques = '/mosques';
  static const String projects = '/projects';
  static const String about = '/about';
  static const String minister = '/minister';
  static const String visionMission = '/vision-mission';
  static const String structure = '/structure';
  static const String formerMinisters = '/former-ministers';
  static const String contact = '/contact';
  static const String search = '/search';
  static const String notFound = '/not-found';
  static const String fridaySermon = '/friday-sermon';
  static const String organizationalStructure = '/organizational-structure';
  static const String previousMinisters = '/previous-ministers';

  // Admin Routes
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminWaqfLands = '/admin/waqf-lands';
  static const String adminCases = '/admin/cases';
  static const String adminDocuments = '/admin/documents';
  static const String adminProfile = '/admin/profile';
  static const String adminActivities = '/admin/activities';
  static const String adminSettings = '/admin/settings';
  static const String adminReports = '/admin/reports';
  static const String adminUsers = '/admin/users';
  static const String adminNews = '/admin/news';
  static const String adminAnnouncements = '/admin/announcements';
  static const String adminMosques = '/admin/mosques';
  static const String adminHomeManagement = '/admin/home-management';
  static const String adminActivitiesManagement = '/admin/activities-management';
  static const String adminHeroSlider = '/admin/hero-slider';
  static const String adminBreakingNews = '/admin/breaking-news';
  static const String adminFridaySermons = '/admin/friday-sermons';




  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
    // ============================================
    // PUBLIC ROUTES (No Authentication Required)
    // ============================================

      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case news:
        return MaterialPageRoute(
          builder: (_) => const NewsScreen(),
          settings: settings,
        );

      case newsDetail:
        final article = settings.arguments as NewsArticle?;
        return MaterialPageRoute(
          builder: (_) => NewsDetailScreen(article: article),
          settings: settings,
        );

      case announcements:
        return MaterialPageRoute(
          builder: (_) => const AnnouncementsScreen(),
          settings: settings,
        );

        /*
      case activities:
        return MaterialPageRoute(
          builder: (_) => const ActivitiesManagementScreen(),
          settings: settings,
        );

         */

      case services:
        return MaterialPageRoute(
          builder: (_) => const ServicesScreen(),
          settings: settings,
        );

      case eservices:
        return MaterialPageRoute(
          builder: (_) => const EServicesScreen(),
          settings: settings,
        );

      case mosques:
        return MaterialPageRoute(
          builder: (_) => const MosquesScreen(),
          settings: settings,
        );

      case projects:
        return MaterialPageRoute(
          builder: (_) => const ProjectsScreen(),
          settings: settings,
        );

      case about:
        return MaterialPageRoute(
          builder: (_) => const AboutScreen(),
          settings: settings,
        );

      case minister:
        return MaterialPageRoute(
          builder: (_) => const MinisterScreen(),
          settings: settings,
        );

      case visionMission:
        return MaterialPageRoute(
          builder: (_) => const VisionMissionScreen(),
          settings: settings,
        );

      case structure:
        return MaterialPageRoute(
          builder: (_) => const StructureScreen(),
          settings: settings,
        );

      case formerMinisters:
        return MaterialPageRoute(
          builder: (_) => const FormerMinistersScreen(),
          settings: settings,
        );

      case contact:
        return MaterialPageRoute(
          builder: (_) => const ContactScreen(),
          settings: settings,
        );

      case search:
        return MaterialPageRoute(
          builder: (_) => const SearchScreen(),
          settings: settings,
        );

    // ============================================
    // ADMIN ROUTES
    // ============================================

    // Admin Login (No Auth Required)
      case adminLogin:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

    // Admin Dashboard (Auth Required) ✅
      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AuthGuardedRoute(
            child: DashboardScreen(),
          ),
          settings: settings,
        );

    // Waqf Lands Management (Auth Required) ✅
      case adminWaqfLands:
        return MaterialPageRoute(
          builder: (_) => const AuthGuardedRoute(
            child: WaqfLandsScreen(),
          ),
          settings: settings,
        );

    // Cases Management (Auth Required) ✅
      case adminCases:
        return MaterialPageRoute(
          builder: (_) => const AuthGuardedRoute(
            child: CasesScreen(),
          ),
          settings: settings,
        );

    // Documents Management (Auth Required) ✅
      case adminDocuments:
        return MaterialPageRoute(
          builder: (_) => const AuthGuardedRoute(
            child: DocumentsScreen(),
          ),
          settings: settings,
        );

      case adminProfile:
        return MaterialPageRoute(
          builder: (_) => const AuthGuardedRoute(
            child: ProfileScreen(),
          ),
          settings: settings,
        );

      case adminHomeManagement:
        return MaterialPageRoute(
          builder: (_) => const AuthGuardedRoute(
            child: HomeManagementScreen(),
          ),
          settings: settings,
        );

      case adminHeroSlider:
        return MaterialPageRoute(
          builder: (_) => const AuthGuardedRoute(
            child: HeroSliderManagementScreen(),
          ),
          settings: settings,
        );

      case adminBreakingNews:
        return MaterialPageRoute(
          builder: (_) => const AuthGuardedRoute(
            child: BreakingNewsManagementScreen(),
          ),
          settings: settings,
        );

    // Activities Management (Auth Required) ✅

      case adminActivitiesManagement:
        return MaterialPageRoute(
          builder: (_) => const AuthGuardedRoute(
            child: ActivitiesManagementScreen(),
          ),
          settings: settings,
        );



      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
          settings: settings,
        );
    }
  }

  // ============================================
  // NAVIGATION HELPERS
  // ============================================

  /// Navigate to route
  static Future<T?> navigateTo<T extends Object?>(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Alias for navigateTo
  static Future<T?> push<T extends Object?>(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) {
    return navigateTo<T>(context, routeName, arguments: arguments);
  }

  /// Navigate and replace current route
  static Future<T?> navigateToAndReplace<T extends Object?, TO extends Object?>(
      BuildContext context,
      String routeName, {
        TO? result,
        Object? arguments,
      }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  /// Alias for navigateToAndReplace
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
      BuildContext context,
      String routeName, {
        TO? result,
        Object? arguments,
      }) {
    return navigateToAndReplace<T, TO>(context, routeName, result: result, arguments: arguments);
  }

  /// Navigate and clear stack
  static Future<T?> navigateToAndClearStack<T extends Object?>(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
          (route) => false,
      arguments: arguments,
    );
  }

  /// Alias for navigateToAndClearStack
  static Future<T?> pushAndClearStack<T extends Object?>(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) {
    return navigateToAndClearStack<T>(context, routeName, arguments: arguments);
  }

  /// Pop current route
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Check if navigation stack can pop
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  /// Pop until specific route
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  // ============================================
  // ROUTE VALIDATION METHODS
  // ============================================

  /// Check if route is public (no auth required)
  static bool isPublicRoute(String routeName) {
    const publicRoutes = [
      splash,
      home,
      news,
      newsDetail,
      announcements,
      activities,
      services,
      eservices,
      mosques,
      projects,
      about,
      minister,
      visionMission,
      structure,
      formerMinisters,
      contact,
      search,
      notFound,
      fridaySermon,
      organizationalStructure,
      previousMinisters

    ];
    return publicRoutes.contains(routeName);
  }

  /// Check if route is admin route
  static bool isAdminRoute(String routeName) {
    return routeName.startsWith('/admin');
  }

  /// Check if route requires authentication
  static bool requiresAuth(String routeName) {
    return isAdminRoute(routeName) && routeName != adminLogin;
  }
}

// ============================================
// AUTH GUARDED ROUTE WRAPPER
// ============================================

/// Wrapper widget that protects routes requiring authentication
///
/// Usage:
/// ```dart
/// case adminDashboard:
///   return MaterialPageRoute(
///     builder: (_) => const AuthGuardedRoute(
///       child: AdminDashboardScreen(),
///     ),
///   );
/// ```
class AuthGuardedRoute extends ConsumerStatefulWidget {
  final Widget child;

  const AuthGuardedRoute({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AuthGuardedRoute> createState() => _AuthGuardedRouteState();
}

class _AuthGuardedRouteState extends ConsumerState<AuthGuardedRoute> {
  @override
  void initState() {
    super.initState();
    // Check authentication on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }

  // FIXED: Made async and initialize auth provider first
  void _checkAuthentication() async {
    // Initialize auth provider first (only runs once due to _initialized flag)
    await ref.read(authStateProvider.notifier).initialize();

    final isAuthenticated = ref.read(isAuthenticatedProvider);

    if (!isAuthenticated) {
      // Redirect to login if not authenticated
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.adminLogin,
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Listen for auth state changes
    ref.listen(isAuthenticatedProvider, (previous, next) {
      if (!next && mounted) {
        // User logged out, redirect to login
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.adminLogin,
              (route) => false,
        );
      }
    });

    // Show loading while checking authentication
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.islamicGreen,
          ),
        ),
      );
    }

    // Show protected content if authenticated
    if (authState.isAuthenticated) {
      return widget.child;
    }

    // Show loading indicator while redirecting
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.islamicGreen,
        ),
      ),
    );
  }
}

// ============================================
// ROUTE ANIMATIONS (Optional - Already existed)
// ============================================

/// Slide transition for routes
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final AxisDirection direction;

  SlidePageRoute({
    required this.child,
    this.direction = AxisDirection.left,
    super.settings,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      Offset begin;
      switch (direction) {
        case AxisDirection.up:
          begin = const Offset(0.0, 1.0);
          break;
        case AxisDirection.down:
          begin = const Offset(0.0, -1.0);
          break;
        case AxisDirection.right:
          begin = const Offset(-1.0, 0.0);
          break;
        case AxisDirection.left:
          begin = const Offset(1.0, 0.0);
          break;
      }

      const end = Offset.zero;
      const curve = Curves.easeInOut;
      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// Fade transition for routes
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  FadePageRoute({
    required this.child,
    super.settings,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// Scale transition for routes
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  ScalePageRoute({
    required this.child,
    super.settings,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = 0.0;
      const end = 1.0;
      const curve = Curves.easeInOut;

      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return ScaleTransition(
        scale: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}