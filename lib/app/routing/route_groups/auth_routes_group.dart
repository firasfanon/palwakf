part of '../go_router_config.dart';

List<RouteBase> _buildAuthRoutes() {
  return [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminLogin,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => PwfForgotPasswordPage(
        from: state.uri.queryParameters['from'],
      ),
    ),
    GoRoute(
      path: AppRoutes.recoveryCallback,
      builder: (context, state) => PwfRecoveryCallbackPage(
        uri: state.uri,
      ),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      builder: (context, state) => PwfResetPasswordPage(
        from: state.uri.queryParameters['from'],
      ),
    ),

    // Forbidden
    GoRoute(
      path: AppRoutes.forbidden,
      builder: (context, state) => const ForbiddenScreen(),
    ),
  ];
}
