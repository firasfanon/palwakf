import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized database ownership surfaces for PalWakf.
///
/// Platform Database Ownership Closure — Dependency Reduction + Owner Wrapper
/// Remediation (2026-05-26).
///
/// This file intentionally centralizes all Flutter PostgREST `.from(...)`
/// database surface names that were found in the 2026-05-25 ownership scan.
/// Direct string literals in repositories are replaced with these constants so
/// future owner-schema reroutes occur from one governed location instead of
/// dozens of page/repository files.
class PwfDatabaseOwnerSurfaces {
  const PwfDatabaseOwnerSurfaces._();

  static const String batchKey =
      'database_ownership_dependency_reduction_2026_05_26';
  static const int intakeDirectReferenceCount = 319;
  static const int intakeDbPublicDependencyCount = 502;
  static const int centralizedSurfaceCount = 39;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool productionApproved = false;
  static const bool publicSchemaIsCompatibilityAndApiEdgeOnly = true;
  static const bool publicBaseTableCreationAuthorized = false;
  static const bool publicWrappersAreTransitionalApiFacade = false;
  static const bool publicRuntimeDependencyZeroRequired = true;
  static const bool publicRuntimeWrappersForbidden = true;
  static const bool authUsersMigrationAllowed = false;
  static const bool flutterElevatedSecretAllowed = false;
  static const bool waqfAssetsMutationAllowed = false;

  /// owner=media_center; target=media_center.content_items; decision=legacy_public_compat_view.
  static const String activities = 'activities';

  /// owner=core; target=core.admin_users; decision=compat_view_rpc_only.
  static const String adminUsers = 'admin_users';

  /// owner=media_center; target=media_center.content_items; decision=legacy_public_compat_view.
  static const String announcements = 'announcements';

  /// owner=cases; target=cases.case_records; decision=owner_schema_required.
  static const String cases = 'cases';

  /// owner=core; target=core.prayer_calc_methods; decision=sovereign_schema_direct_read_existing.
  static const String corePrayerCalcMethods = 'core.prayer_calc_methods';

  /// owner=core; target=core.prayer_cities; decision=sovereign_schema_direct_read_existing.
  static const String corePrayerCities = 'core.prayer_cities';

  /// owner=core; target=core.prayer_times_daily; decision=sovereign_schema_direct_read_existing.
  static const String corePrayerTimesDaily = 'core.prayer_times_daily';

  /// owner=core; target=core.user_prayer_settings; decision=sovereign_schema_direct_read_existing.
  static const String coreUserPrayerSettings = 'core.user_prayer_settings';

  /// owner=platform_content; target=platform_content.former_ministers; decision=preserve_public_compat_view.
  static const String formerMinisters = 'former_ministers';

  /// owner=media_center; target=media_center.friday_sermons; decision=legacy_public_compat_view.
  static const String fridaySermons = 'friday_sermons';

  /// owner=media_center; target=media_center.media_gallery_items; decision=legacy_public_compat_view.
  static const String mediaGalleryItems = 'media_gallery_items';

  /// owner=awqaf_system; target=awqaf_system.mosques; decision=excluded_sovereign_no_platform_migration.
  static const String mosques = 'mosques';

  /// owner=media_center; target=media_center.content_items; decision=legacy_public_compat_view.
  static const String newsArticles = 'news_articles';

  /// owner=core; target=core.org_unit_profiles; decision=read_wrapper_only.
  static const String orgUnitProfiles = 'core.org_unit_profiles';

  /// owner=core; target=core.org_units; decision=read_wrapper_only.
  static const String orgUnits = 'core.org_units';

  /// owner=platform_services; target=platform_services.complaint_updates; decision=owner_schema_required.
  static const String pwfComplaintUpdates = 'pwf_complaint_updates';

  /// owner=platform_services; target=platform_services.complaints; decision=owner_schema_required.
  static const String pwfComplaints = 'pwf_complaints';

  /// owner=tasks; target=tasks.task_assignments; decision=owner_schema_required.
  static const String taskAssignments = 'task_assignments';

  /// owner=tasks; target=tasks.task_attachments; decision=owner_schema_required.
  static const String taskAttachments = 'task_attachments';

  /// owner=tasks; target=tasks.task_comments; decision=owner_schema_required.
  static const String taskComments = 'task_comments';

  /// owner=tasks; target=tasks.task_events; decision=owner_schema_required.
  static const String taskEvents = 'task_events';

  /// owner=tasks; target=tasks.task_followups; decision=owner_schema_required.
  static const String taskFollowups = 'task_followups';

  /// owner=tasks; target=tasks.task_links; decision=owner_schema_required.
  static const String taskLinks = 'task_links';

  /// owner=tasks; target=tasks.task_notifications; decision=owner_schema_required.
  static const String taskNotifications = 'task_notifications';

  /// owner=tasks; target=tasks.task_status_history; decision=owner_schema_required.
  static const String taskStatusHistory = 'task_status_history';

  /// owner=tasks; target=tasks.task_watchers; decision=owner_schema_required.
  static const String taskWatchers = 'task_watchers';

  /// owner=tasks; target=tasks.tasks; decision=owner_schema_required.
  static const String tasks = 'tasks';

  /// owner=platform_access; target=platform_access.user_scope_assignment_units; decision=RPC_only_for_client_writes.
  static const String userScopeAssignmentUnits = 'user_scope_assignment_units';

  /// owner=platform_access; target=platform_access.user_scope_assignments; decision=RPC_only_for_client_writes.
  static const String userScopeAssignments = 'user_scope_assignments';

  /// owner=core; target=core.user_accounts; decision=compat_view_rpc_only.
  static const String users = 'users';

  /// Media Center Runtime Source Root Cutover (2026-06-18 correction):
  /// public.v_* runtime wrappers are no longer accepted for unit/public page
  /// execution. Flutter must bind directly to owner-schema read surfaces.
  static const String mediaCenterRootCutoverBatchKey =
      'media_center_runtime_source_root_cutover_2026_05_30';
  static const bool mediaCenterOwnerReadDefault = true;
  static const bool mediaCenterLegacyPublicFallbackOnly = false;
  static const bool mediaCenterPublicRuntimeDependencyZero = true;

  /// Least-privilege API edge: `media_center` must remain outside Supabase
  /// Exposed Schemas. Public Flutter reads invoke the explicit `public` RPC
  /// below; owner views are internal server-side sources only.
  static const String mediaCenterApiSchema = 'media_center';
  static const String mediaCenterApiExposureDecision =
      'media-center-remains-unexposed-public-rpc-contract-v2';
  static const String publicMediaRuntimeFeedRpcV2 =
      'rpc_public_media_feed_v2';

  /// Public detail RPC. The requested content id is always unit + family scoped
  /// server-side and never resolved by scanning a public feed window.
  static const String publicMediaRuntimeDetailRpcV2 =
      'rpc_public_media_detail_v2';

  /// Canonical owner-schema runtime surfaces for public unit/home pages.
  /// These are not public wrappers. Flutter adapters must filter by
  /// `owner_org_unit_id` after resolving the route slug through core.org_units.
  static const String unitPublicContentRuntimeV1 =
      'media_center.v_unit_public_content_runtime_v1';
  static const String unitPublicNewsRuntimeV1 =
      'media_center.v_unit_public_news_runtime_v1';
  static const String unitPublicAnnouncementsRuntimeV1 =
      'media_center.v_unit_public_announcements_runtime_v1';
  static const String unitPublicActivitiesRuntimeV1 =
      'media_center.v_unit_public_activities_runtime_v1';
  static const String unitPublicEventsRuntimeV1 =
      'media_center.v_unit_public_events_runtime_v1';
  static const String unitPublicSocialPostsRuntimeV1 =
      'media_center.v_unit_public_social_posts_runtime_v1';
  static const String unitPublicGalleryRuntimeV1 =
      'media_center.v_unit_public_gallery_runtime_v1';
  static const String unitPublicGalleryImagesRuntimeV1 =
      'media_center.v_unit_public_gallery_images_runtime_v1';
  static const String unitPublicGalleryVideosRuntimeV1 =
      'media_center.v_unit_public_gallery_videos_runtime_v1';
  static const String unitPublicSurfaceProfileRuntimeV1 =
      'core.v_unit_public_surface_profile_runtime_v1';


  /// Sovereign operational closure owner surfaces (2026-06-19).
  static const String orgUnitPublicProfiles = 'core.org_unit_public_profiles';
  static const String orgUnitSocialLinks = 'core.org_unit_social_links';
  static const String unitPublicCompositionRuntimeV1 =
      'platform_experience.v_unit_public_composition_runtime_v1';
  static const String orgUnitPublicCompositions =
      'platform_experience.org_unit_public_compositions';
  static const String unitPublicContentRecords =
      'media_center.unit_public_content_records';
  static const String unitPublicContentWorkflowEvents =
      'media_center.unit_public_content_workflow_events';

  /// Transitional constant aliases retained for older repository call sites.
  /// Do not interpret the `Compat` suffix as permission to read public.v_*; all
  /// values below resolve to owner-schema direct runtime surfaces.
  static const String vMediaActivitiesCompatV1 = unitPublicActivitiesRuntimeV1;
  static const String vMediaAnnouncementsCompatV1 =
      unitPublicAnnouncementsRuntimeV1;
  static const String vMediaGalleryCompatV1 = unitPublicGalleryRuntimeV1;
  static const String vMediaNewsCompatV1 = unitPublicNewsRuntimeV1;
  static const String vUnitPublicContentCompatV1 = unitPublicContentRuntimeV1;
  static const String vUnitPublicNewsCompatV1 = unitPublicNewsRuntimeV1;
  static const String vUnitPublicAnnouncementsCompatV1 =
      unitPublicAnnouncementsRuntimeV1;
  static const String vUnitPublicActivitiesCompatV1 =
      unitPublicActivitiesRuntimeV1;
  static const String vUnitPublicGalleryCompatV1 = unitPublicGalleryRuntimeV1;
  static const String vUnitPublicSurfaceProfileV1 =
      unitPublicSurfaceProfileRuntimeV1;

  /// api_edge=public; owner=platform_content/media_center; decision=approved_transitional_public_wrapper_not_source_of_truth.
  static const String vPlatformCenterContent = 'v_platform_center_content';

  /// owner=public; target=public.v_services_catalog_compat_v1; decision=approved_public_wrapper.
  static const String vServicesCatalogCompatV1 = 'v_services_catalog_compat_v1';

  /// owner=platform_navigation; target=platform_navigation.service_entries; decision=approved_public_owner_read_wrapper_gated.
  static const String vPlatformNavigationServicesCatalogFromOwnerV1 =
      'v_platform_navigation_services_catalog_from_owner_v1';

  /// owner=platform_navigation; target=platform_navigation.home_entries; decision=approved_public_owner_read_wrapper_gated.
  static const String vPlatformNavigationHomeServicesFromOwnerV1 =
      'v_platform_navigation_home_services_from_owner_v1';

  /// owner=public; target=public.v_zakat_public_config_v1; decision=approved_public_wrapper.
  static const String vZakatPublicConfigV1 = 'v_zakat_public_config_v1';

  /// owner=waqf; target=waqf.waqf_lands; decision=excluded_sovereign_no_platform_migration.
  static const String waqfLands = 'waqf_lands';

  /// owner=zakat; target=zakat.donation_requests; decision=owner_schema_required.
  static const String zakatDonationRequests = 'zakat_donation_requests';

  static const Map<String, String> ownerSchemaBySurface = <String, String>{
    activities: 'media_center',
    adminUsers: 'core',
    announcements: 'media_center',
    cases: 'cases',
    corePrayerCalcMethods: 'core',
    corePrayerCities: 'core',
    corePrayerTimesDaily: 'core',
    coreUserPrayerSettings: 'core',
    formerMinisters: 'platform_content',
    fridaySermons: 'media_center',
    mediaGalleryItems: 'media_center',
    mosques: 'awqaf_system',
    newsArticles: 'media_center',
    orgUnitProfiles: 'core',
    orgUnits: 'core',
    pwfComplaintUpdates: 'platform_services',
    pwfComplaints: 'platform_services',
    taskAssignments: 'tasks',
    taskAttachments: 'tasks',
    taskComments: 'tasks',
    taskEvents: 'tasks',
    taskFollowups: 'tasks',
    taskLinks: 'tasks',
    taskNotifications: 'tasks',
    taskStatusHistory: 'tasks',
    taskWatchers: 'tasks',
    tasks: 'tasks',
    userScopeAssignmentUnits: 'core',
    userScopeAssignments: 'core',
    users: 'core',
    unitPublicContentRuntimeV1: 'media_center',
    unitPublicNewsRuntimeV1: 'media_center',
    unitPublicAnnouncementsRuntimeV1: 'media_center',
    unitPublicActivitiesRuntimeV1: 'media_center',
    unitPublicEventsRuntimeV1: 'media_center',
    unitPublicSocialPostsRuntimeV1: 'media_center',
    unitPublicGalleryRuntimeV1: 'media_center',
    unitPublicGalleryImagesRuntimeV1: 'media_center',
    unitPublicGalleryVideosRuntimeV1: 'media_center',
    unitPublicSurfaceProfileRuntimeV1: 'core',
    orgUnitPublicProfiles: 'core',
    orgUnitSocialLinks: 'core',
    unitPublicCompositionRuntimeV1: 'platform_experience',
    orgUnitPublicCompositions: 'platform_experience',
    unitPublicContentRecords: 'media_center',
    unitPublicContentWorkflowEvents: 'media_center',
    publicMediaRuntimeFeedRpcV2: 'public',
    publicMediaRuntimeDetailRpcV2: 'public',
    vPlatformCenterContent: 'public',
    vServicesCatalogCompatV1: 'public',
    vPlatformNavigationServicesCatalogFromOwnerV1: 'platform_navigation',
    vPlatformNavigationHomeServicesFromOwnerV1: 'platform_navigation',
    vZakatPublicConfigV1: 'public',
    waqfLands: 'waqf',
    zakatDonationRequests: 'zakat',
  };

  static const Map<String, String> ownerTargetBySurface = <String, String>{
    activities: 'media_center.content_items',
    adminUsers: 'core.admin_users',
    announcements: 'media_center.content_items',
    cases: 'cases.case_records',
    corePrayerCalcMethods: 'core.prayer_calc_methods',
    corePrayerCities: 'core.prayer_cities',
    corePrayerTimesDaily: 'core.prayer_times_daily',
    coreUserPrayerSettings: 'core.user_prayer_settings',
    formerMinisters: 'platform_content.former_ministers',
    fridaySermons: 'media_center.friday_sermons',
    mediaGalleryItems: 'media_center.media_gallery_items',
    mosques: 'awqaf_system.mosques',
    newsArticles: 'media_center.content_items',
    orgUnitProfiles: 'core.org_unit_profiles',
    orgUnits: 'core.org_units',
    pwfComplaintUpdates: 'platform_services.complaint_updates',
    pwfComplaints: 'platform_services.complaints',
    taskAssignments: 'tasks.task_assignments',
    taskAttachments: 'tasks.task_attachments',
    taskComments: 'tasks.task_comments',
    taskEvents: 'tasks.task_events',
    taskFollowups: 'tasks.task_followups',
    taskLinks: 'tasks.task_links',
    taskNotifications: 'tasks.task_notifications',
    taskStatusHistory: 'tasks.task_status_history',
    taskWatchers: 'tasks.task_watchers',
    tasks: 'tasks.tasks',
    userScopeAssignmentUnits: 'platform_access.user_scope_assignment_units',
    userScopeAssignments: 'platform_access.user_scope_assignments',
    users: 'core.user_accounts',
    unitPublicContentRuntimeV1: 'media_center.v_unit_public_content_runtime_v1',
    unitPublicNewsRuntimeV1: 'media_center.v_unit_public_news_runtime_v1',
    unitPublicAnnouncementsRuntimeV1:
        'media_center.v_unit_public_announcements_runtime_v1',
    unitPublicActivitiesRuntimeV1:
        'media_center.v_unit_public_activities_runtime_v1',
    unitPublicEventsRuntimeV1: 'media_center.v_unit_public_events_runtime_v1',
    unitPublicSocialPostsRuntimeV1:
        'media_center.v_unit_public_social_posts_runtime_v1',
    unitPublicGalleryRuntimeV1: 'media_center.v_unit_public_gallery_runtime_v1',
    unitPublicGalleryImagesRuntimeV1:
        'media_center.v_unit_public_gallery_images_runtime_v1',
    unitPublicGalleryVideosRuntimeV1:
        'media_center.v_unit_public_gallery_videos_runtime_v1',
    unitPublicSurfaceProfileRuntimeV1:
        'core.v_unit_public_surface_profile_runtime_v1',
    orgUnitPublicProfiles: 'core.org_unit_public_profiles',
    orgUnitSocialLinks: 'core.org_unit_social_links',
    unitPublicCompositionRuntimeV1:
        'platform_experience.v_unit_public_composition_runtime_v1',
    orgUnitPublicCompositions:
        'platform_experience.org_unit_public_compositions',
    unitPublicContentRecords: 'media_center.unit_public_content_records',
    unitPublicContentWorkflowEvents:
        'media_center.unit_public_content_workflow_events',
    publicMediaRuntimeFeedRpcV2: 'public.rpc_public_media_feed_v2',
    publicMediaRuntimeDetailRpcV2: 'public.rpc_public_media_detail_v2',
    vPlatformCenterContent: 'public.v_platform_center_content',
    vServicesCatalogCompatV1: 'public.v_services_catalog_compat_v1',
    vPlatformNavigationServicesCatalogFromOwnerV1:
        'platform_navigation.service_entries',
    vPlatformNavigationHomeServicesFromOwnerV1:
        'platform_navigation.home_entries',
    vZakatPublicConfigV1: 'public.v_zakat_public_config_v1',
    waqfLands: 'waqf.waqf_lands',
    zakatDonationRequests: 'zakat.donation_requests',
  };

  static const Map<String, String> remediationDecisionBySurface =
      <String, String>{
        activities: 'legacy_public_compat_view',
        adminUsers: 'compat_view_rpc_only',
        announcements: 'legacy_public_compat_view',
        cases: 'owner_schema_required',
        corePrayerCalcMethods: 'sovereign_schema_direct_read_existing',
        corePrayerCities: 'sovereign_schema_direct_read_existing',
        corePrayerTimesDaily: 'sovereign_schema_direct_read_existing',
        coreUserPrayerSettings: 'sovereign_schema_direct_read_existing',
        formerMinisters: 'preserve_public_compat_view',
        fridaySermons: 'legacy_public_compat_view',
        mediaGalleryItems: 'legacy_public_compat_view',
        mosques: 'excluded_sovereign_no_platform_migration',
        newsArticles: 'legacy_public_compat_view',
        orgUnitProfiles: 'read_wrapper_only',
        orgUnits: 'read_wrapper_only',
        pwfComplaintUpdates: 'owner_schema_required',
        pwfComplaints: 'owner_schema_required',
        taskAssignments: 'owner_schema_required',
        taskAttachments: 'owner_schema_required',
        taskComments: 'owner_schema_required',
        taskEvents: 'owner_schema_required',
        taskFollowups: 'owner_schema_required',
        taskLinks: 'owner_schema_required',
        taskNotifications: 'owner_schema_required',
        taskStatusHistory: 'owner_schema_required',
        taskWatchers: 'owner_schema_required',
        tasks: 'owner_schema_required',
        userScopeAssignmentUnits: 'owner_schema_required',
        userScopeAssignments: 'owner_schema_required',
        users: 'compat_view_rpc_only',
        unitPublicContentRuntimeV1:
            'owner_schema_direct_runtime_no_public',
        unitPublicNewsRuntimeV1:
            'owner_schema_direct_runtime_no_public',
        unitPublicAnnouncementsRuntimeV1:
            'owner_schema_direct_runtime_no_public',
        unitPublicActivitiesRuntimeV1:
            'owner_schema_direct_runtime_no_public',
        unitPublicEventsRuntimeV1:
            'owner_schema_direct_runtime_no_public',
        unitPublicSocialPostsRuntimeV1:
            'owner_schema_direct_runtime_no_public',
        unitPublicGalleryRuntimeV1:
            'owner_schema_direct_runtime_no_public',
        unitPublicGalleryImagesRuntimeV1:
            'owner_schema_direct_runtime_no_public',
        unitPublicGalleryVideosRuntimeV1:
            'owner_schema_direct_runtime_no_public',
        unitPublicSurfaceProfileRuntimeV1:
            'owner_schema_direct_runtime_no_public',
        orgUnitPublicProfiles: 'owner_schema_direct_profile_write_rpc',
        orgUnitSocialLinks: 'owner_schema_direct_social_write_rpc',
        unitPublicCompositionRuntimeV1:
            'owner_schema_direct_runtime_no_public',
        orgUnitPublicCompositions: 'owner_schema_direct_composition_write_rpc',
        unitPublicContentRecords: 'owner_schema_direct_content_write_rpc',
        unitPublicContentWorkflowEvents:
            'owner_schema_direct_workflow_audit',
        publicMediaRuntimeFeedRpcV2:
            'public_rpc_allowlisted_media_projection_v2',
        publicMediaRuntimeDetailRpcV2:
            'public_rpc_allowlisted_media_projection_v2_scoped_detail',
        vPlatformCenterContent: 'approved_public_wrapper',
        vServicesCatalogCompatV1: 'approved_public_wrapper',
        vPlatformNavigationServicesCatalogFromOwnerV1:
            'approved_public_owner_read_wrapper_gated',
        vPlatformNavigationHomeServicesFromOwnerV1:
            'approved_public_owner_read_wrapper_gated',
        vZakatPublicConfigV1: 'approved_public_wrapper',
        waqfLands: 'excluded_sovereign_no_platform_migration',
        zakatDonationRequests: 'owner_schema_required',
      };


  /// Returns a schema-qualified PostgREST query builder for owner-schema
  /// runtime surfaces.
  ///
  /// Supabase/PostgREST does not treat `.from('core.view_name')` as a read
  /// from the `core` schema. It asks the exposed `public` schema for a relation
  /// literally named `core.view_name`, which produces errors such as
  /// `public.core.v_unit_public_surface_profile_runtime_v1`.
  ///
  /// Runtime adapters must therefore call:
  /// `PwfDatabaseOwnerSurfaces.fromOwnerSchema(client, surface)`.
  static dynamic fromOwnerSchema(SupabaseClient client, String surface) {
    final schemaName = schemaForSurface(surface);
    final relationName = relationForSurface(surface);
    if (schemaName == 'public') return client.from(relationName);
    return client.schema(schemaName).from(relationName);
  }

  static String schemaForSurface(String surface) {
    final mapped = ownerSchemaBySurface[surface];
    if (mapped != null && mapped.trim().isNotEmpty) return mapped.trim();
    final dotIndex = surface.indexOf('.');
    if (dotIndex > 0) return surface.substring(0, dotIndex);
    return 'public';
  }

  static String relationForSurface(String surface) {
    final schemaName = schemaForSurface(surface);
    final prefix = '$schemaName.';
    if (surface.startsWith(prefix)) return surface.substring(prefix.length);
    final dotIndex = surface.lastIndexOf('.');
    if (dotIndex > 0 && schemaName != 'public') {
      return surface.substring(dotIndex + 1);
    }
    return surface;
  }

  static bool isMediaCenterPublicRuntimeSurface(String surface) {
    final normalized = ownerTargetBySurface[surface] ?? surface;
    return normalized.startsWith('media_center.v_unit_public_') &&
        normalized.endsWith('_runtime_v1');
  }

  static bool isSovereignExcludedSurface(String surface) {
    return remediationDecisionBySurface[surface] ==
            'excluded_sovereign_no_platform_migration' ||
        surface.startsWith('core.') ||
        surface.startsWith('gis.');
  }
}
