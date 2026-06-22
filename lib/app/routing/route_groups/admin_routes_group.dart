part of '../go_router_config.dart';

RouteBase _buildAdminShellRoute(Ref ref) {
  return ShellRoute(
    builder: (context, state, child) =>
        PlatformAdminShell(location: state.uri.path, child: child),
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
        path: AppRoutes.adminMyActivity,
        builder: (context, state) => const MyActivityScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminReports,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminWaqfLands,
        builder: (context, state) => const WaqfLandsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminWaqfAssetsIntegrationIntake,
        builder: (context, state) =>
            const AwqafWaqfAssetsIntegrationIntakePage(),
      ),
      GoRoute(
        path: AppRoutes.adminCrossSystemContracts,
        builder: (context, state) => const PwfCrossSystemIntegrationPage(),
      ),
      GoRoute(
        path: AppRoutes.adminDynamicSystemRegistry,
        builder: (context, state) => const PwfDynamicSystemRegistryAdminPage(),
      ),
      GoRoute(
        path: AppRoutes.adminSystemOperations,
        builder: (context, state) => const PwfPlatformSystemOperationsPage(),
      ),
      GoRoute(
        path: AppRoutes.adminTechnicalServices,
        builder: (context, state) => const PwfTechnicalServicesPage(),
      ),
      GoRoute(
        path: AppRoutes.adminTechnicalServicesBackup,
        builder: (context, state) => const PwfTechnicalServicesPage(
          section: PwfTechnicalServiceSection.backup,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminTechnicalServicesMaintenance,
        builder: (context, state) => const PwfTechnicalServicesPage(
          section: PwfTechnicalServiceSection.maintenance,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminTechnicalServicesHealth,
        builder: (context, state) => const PwfTechnicalServicesPage(
          section: PwfTechnicalServiceSection.health,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminTechnicalServicesDeployment,
        builder: (context, state) => const PwfTechnicalServicesPage(
          section: PwfTechnicalServiceSection.deployment,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminTechnicalServicesAudit,
        builder: (context, state) => const PwfTechnicalServicesPage(
          section: PwfTechnicalServiceSection.audit,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminDatabaseMigration,
        builder: (context, state) => const PwfDatabaseDomainMigrationPage(),
      ),
      GoRoute(
        path: AppRoutes.adminDatabaseMigrationLegacyAlias,
        redirect: (context, state) => AppRoutes.adminDatabaseMigration,
      ),
      ...PwfSisRoutes.routes(),
      GoRoute(
        path: '/admin/systems/:systemKey',
        builder: (context, state) => PwfDynamicSystemPage(
          systemKey: state.pathParameters['systemKey'] ?? '',
        ),
      ),
      GoRoute(
        path: '/admin/systems/:systemKey/sections/:sectionKey',
        builder: (context, state) => PwfDynamicSystemPage(
          systemKey: state.pathParameters['systemKey'] ?? '',
          sectionKey: state.pathParameters['sectionKey'],
        ),
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
        builder: (context, state) =>
            const HomeManagementScreen(initialSurface: 'home'),
      ),
      GoRoute(
        path: AppRoutes.adminUnitSurfacesManagement,
        builder: (context, state) => UnitSurfacesManagementScreen(
          initialUnitSlug: state.uri.queryParameters['unit'],
        ),
      ),
      GoRoute(
        path: AppRoutes.adminSystemSurfacesManagement,
        builder: (context, state) => const SystemSurfacesManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUnitPagesExecution,
        builder: (context, state) => const UnitPagesExecutionScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminSharedContent,
        builder: (context, state) => const SharedContentManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminSurfacesServices,
        builder: (context, state) => const PwfSurfacesServicesAdminHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminSurfacesServicesQuickLinks,
        builder: (context, state) => const SharedContentManagementScreen(
          initialTabIndex: 0,
          currentRoute: AppRoutes.adminSurfacesServicesQuickLinks,
          platformSurfaceOnly: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminSurfacesServicesImportantLinks,
        builder: (context, state) => const SharedContentManagementScreen(
          initialTabIndex: 0,
          currentRoute: AppRoutes.adminSurfacesServicesImportantLinks,
          platformSurfaceOnly: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminSurfacesServicesQuickServices,
        builder: (context, state) => const SharedContentManagementScreen(
          initialTabIndex: 1,
          currentRoute: AppRoutes.adminSurfacesServicesQuickServices,
          platformSurfaceOnly: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminSurfacesServicesStatistics,
        builder: (context, state) => const SharedContentManagementScreen(
          initialTabIndex: 2,
          currentRoute: AppRoutes.adminSurfacesServicesStatistics,
          platformSurfaceOnly: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminSurfacesServicesEServicesPortal,
        builder: (context, state) => const SharedContentManagementScreen(
          initialTabIndex: 3,
          currentRoute: AppRoutes.adminSurfacesServicesEServicesPortal,
          platformSurfaceOnly: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminSurfacesServicesRequests,
        builder: (context, state) => const PwfServiceRequestIntakeAdminScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminSurfacesServicesRequestQueue,
        builder: (context, state) => const PwfServiceRequestQueueAdminScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminSurfacesServicesFormsRegistry,
        builder: (context, state) => const PwfFormsRegistryAdminScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminSurfacesServicesFeatureHighlights,
        builder: (context, state) => const SharedContentManagementScreen(
          initialTabIndex: 4,
          currentRoute: AppRoutes.adminSurfacesServicesFeatureHighlights,
          platformSurfaceOnly: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminSurfacesServicesMiniMapTeaser,
        builder: (context, state) => const SharedContentManagementScreen(
          initialTabIndex: 5,
          currentRoute: AppRoutes.adminSurfacesServicesMiniMapTeaser,
          platformSurfaceOnly: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminSurfacesServicesLegalReferences,
        builder: (context, state) => const PwfLegalReferencesAdminScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenter,
        builder: (context, state) => const MediaCenterDashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.adminUnitMediaCenter,
        builder: (context, state) => UnitMediaCenterAdministrationPage(
          initialSectionKey: state.uri.queryParameters['section'],
        ),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterNews,
        builder: (context, state) => const MediaCenterNewsOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterAnnouncements,
        builder: (context, state) =>
            const MediaCenterAnnouncementsOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterActivities,
        builder: (context, state) =>
            const MediaCenterActivitiesOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterEvents,
        builder: (context, state) => const MediaCenterEventsOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterPhotos,
        builder: (context, state) => const MediaCenterPhotosOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterVideos,
        builder: (context, state) => const MediaCenterVideosOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterBreakingNews,
        builder: (context, state) =>
            const MediaCenterBreakingNewsOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterFridaySermons,
        builder: (context, state) =>
            const MediaCenterFridaySermonsOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterHeroSlider,
        builder: (context, state) =>
            const MediaCenterHeroSliderOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterSocialPosts,
        builder: (context, state) =>
            const MediaCenterSocialPostsOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterPressReleases,
        builder: (context, state) =>
            const MediaCenterPressReleasesOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterOfficialStatements,
        builder: (context, state) =>
            const MediaCenterOfficialStatementsOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterAwarenessCampaigns,
        builder: (context, state) =>
            const MediaCenterAwarenessCampaignsOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterEditorialCalendar,
        builder: (context, state) =>
            const MediaCenterEditorialCalendarOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterMediaLibrary,
        builder: (context, state) =>
            const MediaCenterMediaLibraryOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterSanctitiesObservatory,
        builder: (context, state) =>
            const MediaCenterSanctitiesObservatoryOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterMediaReports,
        builder: (context, state) =>
            const MediaCenterMediaReportsOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterMediaCoverage,
        builder: (context, state) =>
            const MediaCenterMediaCoverageOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterWaqfImpactStories,
        builder: (context, state) =>
            const MediaCenterWaqfImpactStoriesOperationalPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterGovernance,
        builder: (context, state) => const MediaCenterGovernanceInfoPage(),
      ),
      GoRoute(
        path: AppRoutes.adminMediaCenterFamilyGovernancePattern,
        builder: (context, state) => MediaCenterGovernanceInfoPage(
          familyKey: state.pathParameters['familyKey'],
        ),
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
        path: AppRoutes.adminAssistant,
        builder: (context, state) => InternalAssistantPage(
          contextSeed: GoRouterConfig._buildAssistantSeed(ref, state),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminChatbot,
        builder: (context, state) => const PublicChatbotPage(unitId: 'home'),
      ),
      GoRoute(
        path: AppRoutes.adminActivities,
        redirect: (context, state) => AppRoutes.adminMediaCenterActivities,
      ),
      GoRoute(
        path: AppRoutes.adminActivitiesManagement,
        builder: (context, state) => const SharedContentManagementScreen(),
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
      GoRoute(
        path: AppRoutes.adminUnitOperationalActivation,
        builder: (context, state) => UnitOperationalActivationPage(
          initialUnitSlug: state.uri.queryParameters['unit'],
        ),
      ),
      GoRoute(
        path: AppRoutes.adminDocumentIntelligence,
        builder: (context, state) => const DocumentIntelligenceDashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.adminDocumentIntelligenceNew,
        builder: (context, state) => const DocumentJobCreatePage(),
      ),
      GoRoute(
        path: '/admin/document-intelligence/jobs/:jobId',
        builder: (context, state) =>
            DocumentJobDetailPage(jobId: state.pathParameters['jobId']!),
      ),
      GoRoute(
        path: AppRoutes.adminDocumentIntelligenceReviewQueue,
        builder: (context, state) => const DocumentReviewQueuePage(),
      ),
      GoRoute(
        path: '/admin/document-intelligence/review/:jobId',
        builder: (context, state) =>
            DocumentReviewPage(jobId: state.pathParameters['jobId']!),
      ),
      GoRoute(
        path: '/admin/document-intelligence/linking/:jobId',
        builder: (context, state) =>
            DocumentLinkingPage(jobId: state.pathParameters['jobId']!),
      ),
      GoRoute(
        path: AppRoutes.adminComplaints,
        builder: (context, state) => const PwfAdminComplaintsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPublicPagesHub,
        builder: (context, state) => const PwfPublicPagesAdminHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminAboutPage,
        builder: (context, state) => PwfPublicPageAdminScreen(
          config: pwfPublicPageAdminConfigByRoute(AppRoutes.adminAboutPage)!,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminMinisterPage,
        builder: (context, state) => PwfPublicPageAdminScreen(
          config: pwfPublicPageAdminConfigByRoute(AppRoutes.adminMinisterPage)!,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminVisionMissionPage,
        builder: (context, state) => PwfPublicPageAdminScreen(
          config: pwfPublicPageAdminConfigByRoute(
            AppRoutes.adminVisionMissionPage,
          )!,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminStructurePage,
        builder: (context, state) => PwfPublicPageAdminScreen(
          config: pwfPublicPageAdminConfigByRoute(
            AppRoutes.adminStructurePage,
          )!,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminFormerMinistersPage,
        builder: (context, state) => PwfPublicPageAdminScreen(
          config: pwfPublicPageAdminConfigByRoute(
            AppRoutes.adminFormerMinistersPage,
          )!,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminServicesPage,
        builder: (context, state) => PwfPublicPageAdminScreen(
          config: pwfPublicPageAdminConfigByRoute(AppRoutes.adminServicesPage)!,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminEServicesPage,
        builder: (context, state) => PwfPublicPageAdminScreen(
          config: pwfPublicPageAdminConfigByRoute(
            AppRoutes.adminEServicesPage,
          )!,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminSocialServicesPage,
        builder: (context, state) => PwfPublicPageAdminScreen(
          config: pwfPublicPageAdminConfigByRoute(
            AppRoutes.adminSocialServicesPage,
          )!,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminProjectsPage,
        builder: (context, state) => PwfPublicPageAdminScreen(
          config: pwfPublicPageAdminConfigByRoute(AppRoutes.adminProjectsPage)!,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminContactPage,
        builder: (context, state) => PwfPublicPageAdminScreen(
          config: pwfPublicPageAdminConfigByRoute(AppRoutes.adminContactPage)!,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminPrivacyPage,
        builder: (context, state) => PwfPublicPageAdminScreen(
          config: pwfPublicPageAdminConfigByRoute(AppRoutes.adminPrivacyPage)!,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminTermsPage,
        builder: (context, state) => PwfPublicPageAdminScreen(
          config: pwfPublicPageAdminConfigByRoute(AppRoutes.adminTermsPage)!,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminSitemapPage,
        builder: (context, state) => PwfPublicPageAdminScreen(
          config: pwfPublicPageAdminConfigByRoute(AppRoutes.adminSitemapPage)!,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminZakat,
        builder: (context, state) => const PwfZakatAdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPrayerTimes,
        builder: (context, state) => const PwfPrayerTimesAdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminQuran,
        builder: (context, state) => const PwfQuranAdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUsageGuide,
        builder: (context, state) => const UsageGuideScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminTasks,
        builder: (context, state) => const TasksDashboardPage(adminScope: true),
      ),
      GoRoute(
        path: AppRoutes.adminTaskForm,
        builder: (context, state) => const TaskFormPage(adminScope: true),
      ),
      GoRoute(
        path: '/admin/tasks/:taskId/edit',
        builder: (context, state) => TaskFormPage(
          taskId: state.pathParameters['taskId'],
          adminScope: true,
        ),
      ),
      GoRoute(
        path: '/admin/tasks/:taskId',
        builder: (context, state) => TaskDetailPage(
          taskId: state.pathParameters['taskId'] ?? '',
          adminScope: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminSettings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDeveloper,
        builder: (context, state) => const DeveloperToolsScreen(),
      ),
    ],
  );
}
