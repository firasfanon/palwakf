part of '../go_router_config.dart';

List<RouteBase> _buildCommonRoutes() {
  return [
    GoRoute(
      path: AppRoutes.mediaCenterMobileOperationalHome,
      builder: (context, state) => const MediaCenterMobileOperationalHomePage(),
    ),

    GoRoute(
      path: AppRoutes.mediaCenterMobileApp,
      builder: (context, state) => const MediaCenterMobileAppPage(),
    ),
    GoRoute(
      path: AppRoutes.mediaCenterMobilePublish,
      builder: (context, state) => MediaCenterQuickPublishPage(
        initialDraft: state.extra,
      ),
    ),
    GoRoute(
      path: AppRoutes.mediaCenterMobileDrafts,
      builder: (context, state) => const MediaCenterLocalDraftsPage(),
    ),
    GoRoute(
      path: '${AppRoutes.officialMediaBase}/:family/:id',
      builder: (context, state) => OfficialMediaDetailPage(
        family: state.pathParameters['family'] ?? 'news',
        id: state.pathParameters['id'] ?? '',
      ),
    ),
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
