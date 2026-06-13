import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  // Admin
  static const adminUsers = '/admin/users';
  static const adminFridaySermons = '/admin/friday-sermons';
  static const adminMosques = '/admin/mosques';
  static const adminOrgUnits = '/admin/org-units';

  // Public
  /// Root of the public website. We redirect it to the ministry unit (/home).
  static const root = '/';
  static const home = '/home';
  static const news = '/news';
  static const newsDetail = '/news/detail';
  static const announcements = '/announcements';
  static const activities = '/activities';
  static const events = '/events';
  static const services = '/services';
  static const eservices = '/eservices';
  static const serviceRequestEntry = '/services/request';
  static const serviceRequestTracking = '/services/track';
  static const socialServices = '/social-services';
  static const mediaCenter = '/media-center';
  static const mediaCenterMobileOperationalHome = '/app/media';
  static const mediaCenterMobileApp = '/app/media-center';
  static const mediaCenterMobilePublish = '/app/media-center/publish';
  static const mediaCenterMobileDrafts = '/app/media-center/drafts';
  static const officialMediaBase = '/official/media';
  static const socialPosts = '/social-posts';
  static const pressReleases = '/press-releases';
  static const officialStatements = '/official-statements';
  static const awarenessCampaigns = '/awareness-campaigns';
  static const legalReferences = '/legal-references';
  static const sanctitiesObservatory = '/sanctities-observatory';

  // Public (Features)
  static const complaints = '/complaints';
  static const zakat = '/zakat';
  static const prayerTimes = '/prayer-times';
  static const quran = '/quran';
  static const chat = '/chat';

  // Legacy public aliases kept for backward compatibility after reclassifying
  // these pages as platform services rather than semi-independent systems.
  static const zakatSystem = '/zakat-system';
  static const prayerTimesSystem = '/prayer-times-system';
  static const quranSystem = '/quran-system';

  static const mosques = '/mosques';
  static const projects = '/projects';
  static const about = '/about';
  static const minister = '/minister';
  static const visionMission = '/vision-mission';
  static const structure = '/structure';
  static const formerMinisters = '/former-ministers';
  static const fridaySermon = '/friday-sermon';
  static const contact = '/contact';
  static const privacy = '/privacy';
  static const terms = '/terms';
  static const sitemap = '/sitemap';
  static const search = '/search';
  static const underConstruction = '/under-construction';
  static const notFound = '/not-found';

  /// Transition route when moving from the public website to a service system.
  /// Example: /switch/mustakshif
  static const switchSystemBase = '/switch';

  // Auth
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const recoveryCallback = '/auth/recovery-callback';
  static const resetPassword = '/reset-password';

  // Platform Admin
  static const adminLogin = '/admin/login';
  static const adminDashboard = '/admin/dashboard';
  static const adminWaqfLands = '/admin/waqf-lands';
  static const adminWaqfAssetsIntegrationIntake =
      '/admin/awqaf-system/waqf-assets-intake';
  static const adminCrossSystemContracts =
      '/admin/platform/cross-system-contracts';
  static const adminDynamicSystemRegistry = '/admin/platform/system-registry';
  static const adminSystemOperations = '/admin/platform/system-operations';
  static const adminTechnicalServices = '/admin/platform/technical-services';
  static const adminTechnicalServicesBackup =
      '/admin/platform/technical-services/backup';
  static const adminTechnicalServicesMaintenance =
      '/admin/platform/technical-services/maintenance';
  static const adminTechnicalServicesHealth =
      '/admin/platform/technical-services/health';
  static const adminTechnicalServicesDeployment =
      '/admin/platform/technical-services/deployment';
  static const adminTechnicalServicesAudit =
      '/admin/platform/technical-services/audit';
  static const adminDatabaseMigration = '/admin/platform/database-migration';
  // Legacy audit URL kept as a redirect-only alias after Full Site Audit clean retest.
  static const adminDatabaseMigrationLegacyAlias = '/admin/database-migration';
  static const adminDesignSystem = '/admin/platform/design-system';

  static const adminDesignSystemPlatformAdminAdoption =
      '/admin/platform/design-system/platform-admin-adoption';

  static const adminDesignSystemMediaCenterLowRiskAdoption =
      '/admin/platform/design-system/media-center-low-risk-adoption';

  static const adminDesignSystemServicesPlatformContentAdoption =
      '/admin/platform/design-system/services-platform-content-adoption';

  static const adminDesignSystemPublicResponsiveAlignment =
      '/admin/platform/design-system/public-responsive-alignment';
  static const adminDesignSystemVisualIdentityBridge =
      '/admin/platform/design-system/visual-identity-bridge';
  static const adminDesignSystemAwqafPilot =
      '/admin/platform/design-system/awqaf-pilot';
  static const adminDesignSystemRolloutEvidence =
      '/admin/platform/design-system/rollout-evidence';
  static const adminDesignSystemClosureReview =
      '/admin/platform/design-system/closure-review';
  static const adminDesignSystemWave2Scope =
      '/admin/platform/design-system/wave-2-scope';
  static const adminDesignSystemWave2MediaInventory =
      '/admin/platform/design-system/wave-2-media-inventory';
  static const adminDesignSystemWave2MediaLibraryPilot =
      '/admin/platform/design-system/wave-2/media-library-pilot';
  static const adminDynamicSystemBase = '/admin/systems';
  static String adminDynamicSystem(String systemKey) =>
      '/admin/systems/$systemKey';
  static String adminDynamicSystemSection(
          String systemKey, String sectionKey) =>
      '/admin/systems/$systemKey/sections/$sectionKey';
  static const adminCases = '/admin/cases';
  static const adminDocuments = '/admin/documents';
  static const adminZakat = '/admin/zakat';
  static const adminPrayerTimes = '/admin/prayer-times';
  static const adminQuran = '/admin/quran';
  static const adminPublicPagesHub = '/admin/public-pages';
  static const adminAboutPage = '/admin/public-pages/about';
  static const adminMinisterPage = '/admin/public-pages/minister';
  static const adminVisionMissionPage = '/admin/public-pages/vision-mission';
  static const adminStructurePage = '/admin/public-pages/structure';
  static const adminFormerMinistersPage =
      '/admin/public-pages/former-ministers';
  static const adminServicesPage = '/admin/public-pages/services';
  static const adminEServicesPage = '/admin/public-pages/eservices';
  static const adminSocialServicesPage = '/admin/public-pages/social-services';
  static const adminProjectsPage = '/admin/public-pages/projects';
  static const adminContactPage = '/admin/public-pages/contact';
  static const adminPrivacyPage = '/admin/public-pages/privacy';
  static const adminTermsPage = '/admin/public-pages/terms';
  static const adminSitemapPage = '/admin/public-pages/sitemap';
  static const adminComplaints = '/admin/complaints';

  static const adminProfile = '/admin/profile';
  static const adminMyActivity = '/admin/my-activity';
  static const adminActivities = '/admin/activities';
  static const adminSharedContent = '/admin/shared-content';
  static const adminSettings = '/admin/settings';
  static const adminDeveloper = '/admin/developer';
  static const adminReports = '/admin/reports';
  static const adminUsageGuide = '/admin/usage-guide';
  static const adminTasks = '/admin/tasks';
  static const adminTaskForm = '/admin/tasks/new';
  static String adminTaskDetails(String taskId) => '/admin/tasks/$taskId';
  static String adminTaskEdit(String taskId) => '/admin/tasks/$taskId/edit';
  static const adminHomeManagement = '/admin/home-management';
  static const adminUnitSurfacesManagement = '/admin/unit-surfaces-management';
  static const adminSystemSurfacesManagement =
      '/admin/system-surfaces-management';
  static const adminUnitPagesExecution = '/admin/unit-pages-execution';
  static const adminHeroSlider = '/admin/hero-slider';
  static const adminBreakingNews = '/admin/breaking-news';
  static const adminActivitiesManagement = '/admin/activities-management';
  // Platform Surfaces & Services
  static const adminSurfacesServices = '/admin/surfaces-services';
  static const adminSurfacesServicesQuickLinks =
      '/admin/surfaces-services/quick-links';
  static const adminSurfacesServicesImportantLinks =
      '/admin/surfaces-services/important-links';
  static const adminSurfacesServicesQuickServices =
      '/admin/surfaces-services/quick-services';
  static const adminSurfacesServicesStatistics =
      '/admin/surfaces-services/statistics';
  static const adminSurfacesServicesEServicesPortal =
      '/admin/surfaces-services/eservices-portal';
  static const adminSurfacesServicesRequests =
      '/admin/surfaces-services/requests';
  static const adminSurfacesServicesRequestQueue =
      '/admin/surfaces-services/request-queue';
  static const adminSurfacesServicesFormsRegistry =
      '/admin/surfaces-services/forms-registry';
  static const adminSurfacesServicesFeatureHighlights =
      '/admin/surfaces-services/feature-highlights';
  static const adminSurfacesServicesMiniMapTeaser =
      '/admin/surfaces-services/mini-map-teaser';
  static const adminSurfacesServicesLegalReferences =
      '/admin/surfaces-services/legal-references';

  // Media Center
  static const adminMediaCenter = '/admin/media-center';
  static const adminMediaCenterNews = '/admin/media-center/news';
  static const adminMediaCenterAnnouncements =
      '/admin/media-center/announcements';
  static const adminMediaCenterActivities = '/admin/media-center/activities';
  static const adminMediaCenterEvents = '/admin/media-center/events';
  static const adminMediaCenterPhotos = '/admin/media-center/photos';
  static const adminMediaCenterVideos = '/admin/media-center/videos';
  static const adminMediaCenterBreakingNews =
      '/admin/media-center/breaking-news';
  static const adminMediaCenterFridaySermons =
      '/admin/media-center/friday-sermons';
  static const adminMediaCenterHeroSlider = '/admin/media-center/hero-slider';
  static const adminMediaCenterSocialPosts = '/admin/media-center/social-posts';
  static const adminMediaCenterPressReleases =
      '/admin/media-center/press-releases';
  static const adminMediaCenterOfficialStatements =
      '/admin/media-center/official-statements';
  static const adminMediaCenterAwarenessCampaigns =
      '/admin/media-center/awareness-campaigns';
  static const adminMediaCenterEditorialCalendar =
      '/admin/media-center/editorial-calendar';
  static const adminMediaCenterMediaLibrary =
      '/admin/media-center/media-library';
  static const adminMediaCenterSanctitiesObservatory =
      '/admin/media-center/sanctities-observatory';
  static const adminMediaCenterMediaReports =
      '/admin/media-center/media-reports';
  static const adminMediaCenterMediaCoverage =
      '/admin/media-center/media-coverage';
  static const adminMediaCenterWaqfImpactStories =
      '/admin/media-center/waqf-impact-stories';
  static const adminMediaCenterGovernance = '/admin/media-center/governance';
  static const adminMediaCenterFamilyGovernancePattern =
      '/admin/media-center/:familyKey/governance';
  static String adminMediaCenterFamilyGovernance(String familyKey) =>
      '/admin/media-center/$familyKey/governance';

  // Document Intelligence
  static const adminDocumentIntelligence = '/admin/document-intelligence';
  static const adminDocumentIntelligenceNew =
      '/admin/document-intelligence/jobs/new';
  static String adminDocumentIntelligenceJob(String jobId) =>
      '/admin/document-intelligence/jobs/$jobId';
  static const adminDocumentIntelligenceReviewQueue =
      '/admin/document-intelligence/review-queue';
  static String adminDocumentIntelligenceReview(String jobId) =>
      '/admin/document-intelligence/review/$jobId';
  static String adminDocumentIntelligenceLinking(String jobId) =>
      '/admin/document-intelligence/linking/$jobId';

  // Assistant / Chat
  static const adminAssistant = '/admin/assistant';
  static const adminChatbot = '/admin/chatbot';

  // Systems
  static const mustakshif = '/mustakshif';
  static const adminData = '/admin-data';
  static const lands = '/lands';
  static const properties = '/properties';
  static const cases = '/cases';
  static const tasks = '/tasks';
  static const tasksNew = '/tasks/new';
  static String taskDetails(String taskId) => '/tasks/$taskId';
  static String taskEdit(String taskId) => '/tasks/$taskId/edit';
  static const mosquesSystem = '/mosques-system';
  static const billing = '/billing';

  // Guards
  static const forbidden = '/forbidden';

  /// GoRouter equivalent of "push and clear stack" (Navigator legacy).
  /// On GoRouter, `go()` replaces the stack.
  static void pushAndClearStack(BuildContext context, String location) {
    GoRouter.of(context).go(location);
  }

  /// GoRouter equivalent of "push replacement".
  static void pushReplacement(BuildContext context, String location) {
    // `replace` keeps the same shell but replaces the current location.
    GoRouter.of(context).replace(location);
  }
}
