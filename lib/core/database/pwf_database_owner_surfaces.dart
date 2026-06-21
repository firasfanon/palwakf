import 'package:supabase_flutter/supabase_flutter.dart';

class PwfDatabaseOwnerSurfaces {
  const PwfDatabaseOwnerSurfaces._();

  static const String activities = 'activities';
  static const String adminUsers = 'admin_users';
  static const String announcements = 'announcements';
  static const String cases = 'cases';
  static const String corePrayerCalcMethods = 'core.prayer_calc_methods';
  static const String corePrayerCities = 'core.prayer_cities';
  static const String corePrayerTimesDaily = 'core.prayer_times_daily';
  static const String coreUserPrayerSettings = 'core.user_prayer_settings';
  static const String formerMinisters = 'former_ministers';
  static const String fridaySermons = 'friday_sermons';
  static const String mediaGalleryItems = 'media_gallery_items';
  static const String mosques = 'mosques';
  static const String newsArticles = 'news_articles';
  static const String orgUnitProfiles = 'core.org_unit_profiles';
  static const String orgUnits = 'core.org_units';
  static const String pwfComplaintUpdates = 'pwf_complaint_updates';
  static const String pwfComplaints = 'pwf_complaints';
  static const String taskAssignments = 'task_assignments';
  static const String taskAttachments = 'task_attachments';
  static const String taskComments = 'task_comments';
  static const String taskEvents = 'task_events';
  static const String taskFollowups = 'task_followups';
  static const String taskLinks = 'task_links';
  static const String taskNotifications = 'task_notifications';
  static const String taskStatusHistory = 'task_status_history';
  static const String taskWatchers = 'task_watchers';
  static const String tasks = 'tasks';
  static const String userScopeAssignmentUnits = 'user_scope_assignment_units';
  static const String userScopeAssignments = 'user_scope_assignments';
  static const String users = 'users';

  static const String publicMediaRuntimeFeedRpcV2 =
      'rpc_public_media_feed_v2';
  static const String publicMediaRuntimeDetailRpcV2 =
      'rpc_public_media_detail_v2';

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

  static const String vPlatformCenterContent = 'v_platform_center_content';
  static const String vServicesCatalogCompatV1 = 'v_services_catalog_compat_v1';
  static const String vPlatformNavigationServicesCatalogFromOwnerV1 =
      'v_platform_navigation_services_catalog_from_owner_v1';
  static const String vPlatformNavigationHomeServicesFromOwnerV1 =
      'v_platform_navigation_home_services_from_owner_v1';
  static const String vZakatPublicConfigV1 = 'v_zakat_public_config_v1';
  static const String waqfLands = 'waqf_lands';
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
}
