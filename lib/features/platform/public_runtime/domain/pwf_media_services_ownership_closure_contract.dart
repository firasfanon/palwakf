/// Contract declarations for the Media/Services ownership final closure.
///
/// This file is intentionally pure Dart and does not perform runtime IO. It is
/// used by governance, UAT, and future routing/repository reviews to prevent
/// reintroducing direct public-table ownership after the migration closure.
class PwfMediaServicesOwnershipClosureContract {
  const PwfMediaServicesOwnershipClosureContract._();

  static const String batch =
      'mega_batch_media_services_data_ownership_final_closure_legacy_quarantine_decision_2026_05_22';
  static const String closureDecision =
      'MEDIA_SERVICES_OWNERSHIP_FINAL_CLOSURE_ACCEPTED_WITH_LEGACY_QUARANTINE_NO_DELETE';

  static const String mediaOwnerSchema = 'media_center';
  static const String servicesOwnerSchema = 'platform_services';
  static const String publicSchemaRole = 'wrappers_rpc_views_only';

  static const bool deleteLegacyPublicTables = false;
  static const bool archiveLegacyPublicTablesNow = false;
  static const bool allowDirectPublicTableRuntimeReads = false;
  static const bool allowPublicCompatibilityWrappers = false;
  static const bool publicRuntimeDependencyZeroRequired = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> finalMediaRuntimeContracts = [
    'media_center.v_unit_public_content_runtime_v1',
    'media_center.v_unit_public_news_runtime_v1',
    'media_center.v_unit_public_announcements_runtime_v1',
    'media_center.v_unit_public_activities_runtime_v1',
    'media_center.v_unit_public_gallery_runtime_v1',
    'core.v_unit_public_surface_profile_runtime_v1',
  ];

  static const List<String> finalServicesRuntimeContracts = [
    'public.v_services_catalog_compat_v1',
  ];

  static const List<LegacyPublicTableQuarantine> legacyPublicTables = [
    LegacyPublicTableQuarantine(
      tableName: 'public.news_articles',
      domain: 'media',
      decision: 'quarantine_preserve_not_runtime_source',
      ownerAfterClosure: 'media_center',
      publicRuntimeContract: 'runtime_forbidden_use_media_center.v_unit_public_news_runtime_v1',
    ),
    LegacyPublicTableQuarantine(
      tableName: 'public.announcements',
      domain: 'media',
      decision: 'quarantine_preserve_not_runtime_source',
      ownerAfterClosure: 'media_center',
      publicRuntimeContract: 'runtime_forbidden_use_media_center.v_unit_public_announcements_runtime_v1',
    ),
    LegacyPublicTableQuarantine(
      tableName: 'public.activities',
      domain: 'media',
      decision: 'quarantine_preserve_not_runtime_source',
      ownerAfterClosure: 'media_center',
      publicRuntimeContract: 'runtime_forbidden_use_media_center.v_unit_public_activities_runtime_v1',
    ),
    LegacyPublicTableQuarantine(
      tableName: 'public.media_gallery_items',
      domain: 'media_assets',
      decision: 'quarantine_empty_or_mapping_pending_no_delete',
      ownerAfterClosure: 'media_center.content_assets',
      publicRuntimeContract: 'runtime_forbidden_use_media_center.v_unit_public_gallery_runtime_v1',
    ),
    LegacyPublicTableQuarantine(
      tableName: 'public.services',
      domain: 'services',
      decision:
          'quarantine_preserve_until_platform_services_certifies_full_catalog',
      ownerAfterClosure: 'platform_services',
      publicRuntimeContract: 'public.v_services_catalog_compat_v1',
    ),
    LegacyPublicTableQuarantine(
      tableName: 'public.servicepoints',
      domain: 'services_location_points',
      decision: 'quarantine_review_no_runtime_owner_change',
      ownerAfterClosure:
          'platform_services_or_facilities_after_separate_certification',
      publicRuntimeContract: 'not_certified_in_this_batch',
    ),
    LegacyPublicTableQuarantine(
      tableName: 'public.serviceproviders',
      domain: 'services_providers',
      decision: 'quarantine_review_no_runtime_owner_change',
      ownerAfterClosure:
          'platform_services_or_facilities_after_separate_certification',
      publicRuntimeContract: 'not_certified_in_this_batch',
    ),
    LegacyPublicTableQuarantine(
      tableName: 'public.servicetypes',
      domain: 'services_taxonomy',
      decision: 'quarantine_review_no_runtime_owner_change',
      ownerAfterClosure: 'platform_services_after_taxonomy_certification',
      publicRuntimeContract: 'not_certified_in_this_batch',
    ),
  ];
}

class LegacyPublicTableQuarantine {
  const LegacyPublicTableQuarantine({
    required this.tableName,
    required this.domain,
    required this.decision,
    required this.ownerAfterClosure,
    required this.publicRuntimeContract,
  });

  final String tableName;
  final String domain;
  final String decision;
  final String ownerAfterClosure;
  final String publicRuntimeContract;
}

/// Phase B media-only controlled ownership closure entry.
class PwfMediaCenterControlledOwnershipClosurePhaseB20260526 {
  const PwfMediaCenterControlledOwnershipClosurePhaseB20260526._();

  static const String batchKey =
      'database_ownership_phase_b_media_center_controlled_ownership_closure_2026_05_26';
  static const String decision =
      'MEDIA_CENTER_CONTROLLED_CLOSURE_ENTRY_READ_ONLY_FIRST';

  static const String ownerSchema = 'media_center';
  static const String publicRole = 'compatibility_views_and_rpcs_only';

  static const bool preserveLegacyPublicTables = true;
  static const bool allowDestructiveCleanup = false;
  static const bool allowExactPublicReplacement = false;
  static const bool allowSyncExecutionInEntryPack = false;
  static const bool serviceCenterDeferred = true;
  static const bool noAuthRbacRewrite = true;
  static const bool noWaqfAssetsMutation = true;
  static const bool noGisMutation = true;

  static const List<String> publicRoutesForBrowserUat = <String>[
    '/home',
    '/home/news',
    '/home/news/:id',
    '/home/announcements',
    '/home/announcements/:id',
  ];

  static const List<String> adminRoutesForBrowserUat = <String>[
    '/admin/media-center/news',
    '/admin/media-center/announcements',
    '/admin/media-center/activities',
  ];
}
