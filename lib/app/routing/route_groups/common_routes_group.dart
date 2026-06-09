part of '../go_router_config.dart';

List<RouteBase> _buildCommonRoutes() {
  return [
    // Transition page used when moving from the public site into a service system.
    GoRoute(
      path: '${AppRoutes.switchSystemBase}/:systemKey',
      builder: (context, state) {
        final key = state.pathParameters['systemKey'] ?? '';
        return SwitchSystemScreen(systemKeySlug: key);
      },
    ),
  ];
}
