/// Platform Database Ownership Closure Master Pack — 2026-05-25.
///
/// This contract records the controlled continuation of table ownership
/// migration and schema ordering. It is declarative and must not be used as
/// proof that destructive or exact table-name replacement steps have been run.
class PwfDatabaseOwnershipClosureMasterPackContract {
  const PwfDatabaseOwnershipClosureMasterPackContract._();

  static const String batchKey =
      'platform_database_ownership_closure_master_pack_2026_05_25';

  static const String decision =
      'CONTROLLED_SCHEMA_OWNERSHIP_CLOSURE_MASTER_PACK_PREPARED_EXECUTION_PENDING';

  static const bool productionApproved = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool legacyPublicTablesDeleted = false;
  static const bool authUsersMigrated = false;
  static const bool flutterElevatedSecretAllowed = false;
  static const bool waqfAssetsMutationAllowed = false;

  static const int staticDirectPostgrestReferenceCount = 319;
  static const int staticDirectPostgrestFileCount = 45;
  static const int distinctRuntimeTableNameCount = 39;
  static const int routeLikeStaticEntryCount = 386;
  static const int pageScreenStaticFileCount = 138;

  static const List<String> ownerSchemas = [
    'core',
    'platform_access',
    'platform_content',
    'platform_services',
    'media_center',
    'assistant',
    'tasks',
    'cases',
    'gis',
    'waqf',
    'awqaf_system',
  ];

  static const List<String> protectedSovereignSchemas = [
    'auth',
    'waqf',
    'awqaf_system',
    'gis',
  ];

  static const List<String> publicCompatibilityPrinciples = [
    'public is a compatibility/API surface only',
    'public wrappers must be views/RPCs, not sovereign write owners',
    'legacy public tables are preserved until dependency-zero evidence',
    'owner-write paths must use governed RPCs with audit',
    'read paths must prefer owner views/RPC wrappers',
  ];

  static const List<String> executionSqlPack = [
    '00_database_ownership_master_inventory_read_only.sql',
    '01_schema_owner_mapping_matrix_read_only.sql',
    '02_owner_schema_shadow_targets_candidate_guarded.sql',
    '03_platform_media_services_content_sync_candidate_guarded.sql',
    '04_public_compatibility_surface_candidate_guarded.sql',
    '05_flutter_reroute_dependency_read_only.sql',
    '06_dependency_zero_gate_read_only.sql',
    '07_rls_negative_uat_matrix_read_only.sql',
    '08_legacy_archive_delete_blocker_read_only.sql',
    '09_database_ownership_result_intake_read_only.sql',
    '10_production_gate_redecision_read_only.sql',
  ];

  static const List<String> targetOwnerFamilies = [
    'platform access: systems, permissions, role grants, permission grants',
    'platform content: homepage, header, footer, site pages, hero, stats',
    'media center: news, announcements, activities, gallery, sermons',
    'platform services: service catalog, requests, forms, complaints',
    'assistant: conversations, messages, RAG/citations/tools/evals readiness',
    'core: admin profiles, user accounts cache, org units reference wrappers',
    'tasks/cases: semi-independent owner schemas',
  ];

  static const List<String> blockedFamilies = [
    'auth.users migration',
    'waqf_assets mutation',
    'waqf/awqaf_system schema write from platform migration',
    'gis writes from platform migration',
    'legacy public DROP/DELETE/TRUNCATE/ARCHIVE without dependency-zero',
    'service_role or elevated database secrets in Flutter',
  ];
}

/// Result intake for Platform Database Ownership Closure Master Pack.
///
/// Captures the operator-supplied SQL 00/01/05/06/07/08/09/10 evidence.
/// This is intentionally conservative: inventory and owner mapping were read,
/// but dependency-zero, negative RLS UAT, browser-console cleanliness, exact
/// public table replacement, archive/delete, and production approval are all
/// still blocked.
class PwfDatabaseOwnershipClosureResultIntake20260526 {
  const PwfDatabaseOwnershipClosureResultIntake20260526._();

  static const String batchKey =
      'platform_database_ownership_result_intake_dependency_zero_blocked_2026_05_26';

  static const String decision =
      'DATABASE_OWNERSHIP_RESULT_INTAKEN_DEPENDENCY_ZERO_BLOCKED_PRODUCTION_NOT_APPROVED';

  static const int databaseObjectCount = 409;
  static const int routineCount = 586;
  static const bool inventoryReadOnly = true;

  static const int flutterDirectLegacyDependencyCount = 502;
  static const bool dependencyZeroCertified = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool dropLegacyPublicTablesAuthorized = false;
  static const bool browserConsoleCleanAccepted = false;
  static const bool rlsNegativeUatAccepted = false;
  static const bool productionApproved = false;

  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;
  static const bool destructiveSqlAuthorized = false;

  static const List<String> blockerFamilies = [
    'flutter_direct_legacy_table_references',
    'db_views_or_functions_depending_on_public_legacy',
    'missing_owner_schema_or_shadow_target',
    'missing_public_compatibility_view_or_rpc',
    'browser_console_errors_after_reroute',
    'rls_negative_uat_not_passed',
  ];

  static const List<String> rlsActorCasesStillOpen = [
    'anonymous',
    'unauthorized_authenticated_user',
    'wrong_unit_user',
    'scoped_user',
    'platform_admin',
    'superuser',
  ];

  static const List<String> allowedNextSqlFiles = [
    '00_database_ownership_master_inventory_read_only.sql',
    '01_schema_owner_mapping_matrix_read_only.sql',
    '05_flutter_reroute_dependency_read_only.sql',
    '06_dependency_zero_gate_read_only.sql',
    '07_rls_negative_uat_matrix_read_only.sql',
    '08_legacy_archive_delete_blocker_read_only.sql',
    '09_database_ownership_result_intake_read_only.sql',
    '10_production_gate_redecision_read_only.sql',
  ];

  static const List<String> blockedCandidateSqlFiles = [
    '02_owner_schema_shadow_targets_candidate_guarded.sql',
    '03_platform_media_services_content_sync_candidate_guarded.sql',
    '04_public_compatibility_surface_candidate_guarded.sql',
  ];
}

/// Dependency Reduction + Owner Wrapper Remediation result marker.
///
/// This batch centralizes Flutter PostgREST `.from(...)` database surface
/// references behind `PwfDatabaseOwnerSurfaces`. It is a Flutter/runtime
/// dependency-reduction step only; it does not authorize destructive SQL,
/// exact public table-name replacement, archive/delete, or production approval.
class PwfDatabaseOwnershipDependencyReduction20260526 {
  const PwfDatabaseOwnershipDependencyReduction20260526._();

  static const String batchKey =
      'platform_database_ownership_dependency_reduction_owner_wrapper_remediation_2026_05_26';
  static const String decision =
      'DATABASE_OWNERSHIP_DEPENDENCY_REDUCTION_APPLIED_RETEST_REQUIRED_PRODUCTION_NOT_APPROVED';

  static const int intakeFlutterDirectLegacyDependencyCount = 502;
  static const int intakeFlutterDirectFromLiteralCount = 319;
  static const int centralizedDatabaseSurfaceCount = 39;
  static const int changedFlutterFileCount = 45;
  static const int remainingScannedDirectFromLiteralCount = 0;

  static const bool dependencyZeroCertified = false;
  static const bool rlsNegativeUatAccepted = false;
  static const bool browserConsoleCleanAccepted = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool dropLegacyPublicTablesAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool productionApproved = false;

  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> appliedRemediationFamilies = [
    'centralized Flutter PostgREST database surface names',
    'added owner-schema target metadata for scanned surfaces',
    'removed direct `.from(legacy_literal)` usage from scanned Flutter files',
    'kept runtime surface values stable until SQL/RLS/browser retest evidence is supplied',
  ];

  static const List<String> requiredRetest = [
    'flutter analyze',
    'flutter run -d edge or chrome',
    'SQL 05 flutter reroute dependency read-only',
    'SQL 06 dependency-zero gate read-only',
    'SQL 07 actual RLS negative UAT matrix',
    'SQL 08 archive/delete blocker confirmation',
    'SQL 09 result intake',
    'SQL 10 production gate redecision',
    'Browser console UAT for approved admin/public/system route matrix',
  ];
}

/// Retest intake and classifier gate after owner-wrapper remediation.
///
/// The post-remediation SQL evidence still reports 502 DB-side public
/// dependencies. This is not a rollback of the Flutter literal remediation:
/// the scanned Flutter direct `.from('...')` literal count remains zero.
/// The remaining 502 count must be classified as database object dependencies,
/// missing owner targets, missing compatibility wrappers, RLS/UAT gaps, and
/// browser-console evidence gaps before any archive/delete or exact table-name
/// replacement can be authorized.
class PwfDatabaseOwnershipDependencyRetestClassifier20260526 {
  const PwfDatabaseOwnershipDependencyRetestClassifier20260526._();

  static const String batchKey =
      'platform_database_ownership_dependency_retest_classifier_gate_2026_05_26';
  static const String decision =
      'DB_PUBLIC_DEPENDENCIES_REMAIN_FLUTTER_LITERAL_REMEDIATION_ACCEPTED_CLASSIFICATION_REQUIRED';

  static const int latestDbPublicDependencyCount = 502;
  static const int intakeFlutterDirectFromLiteralCount = 319;
  static const int centralizedDatabaseSurfaceCount = 39;
  static const int changedFlutterFileCount = 45;
  static const int remainingScannedDirectFromLiteralCount = 0;

  static const bool flutterLiteralRemediationAccepted = true;
  static const bool dbDependencyClassificationRequired = true;
  static const bool dependencyZeroCertified = false;
  static const bool rlsNegativeUatAccepted = false;
  static const bool browserConsoleCleanAccepted = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool dropLegacyPublicTablesAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool productionApproved = false;

  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> interpretedResult = [
    'Flutter direct `.from(legacy_literal)` remediation is accepted for scanned files',
    'SQL 05 still counts DB-side public dependencies through pg_depend/pg_rewrite',
    'dependency-zero remains blocked until DB dependencies are classified and remediated or explicitly accepted',
    'RLS negative UAT and browser-console evidence are still required',
    'archive/delete/drop/exact public replacement remains blocked',
  ];

  static const List<String> nextSqlFiles = [
    '14_dependency_reduction_retest_result_intake_read_only.sql',
    '15_db_public_dependency_classifier_read_only.sql',
    '16_dependency_resolution_next_gate_read_only.sql',
  ];
}

/// SQL 15 aggregate-function hotfix for the DB public dependency classifier.
///
/// The first classifier attempted to inspect pg_proc definitions and could hit
/// aggregate routines such as `array_agg`, which makes pg_get_functiondef throw
/// ERROR 42809. SQL 15A materializes only normal functions/procedures before
/// source-text inspection and keeps the entire operation read-only.
class PwfDatabaseOwnershipClassifierAggregateHotfix20260526 {
  const PwfDatabaseOwnershipClassifierAggregateHotfix20260526._();

  static const String batchKey =
      'platform_database_ownership_classifier_aggregate_hotfix_2026_05_26';
  static const String decision =
      'SQL_15_CLASSIFIER_HOTFIXED_TO_EXCLUDE_AGGREGATE_ROUTINES_RETRY_REQUIRED';

  static const String blockedError =
      'ERROR 42809: "array_agg" is an aggregate function';
  static const String patchedSql =
      '15_db_public_dependency_classifier_read_only.sql';
  static const String markerSql =
      '17_db_public_dependency_classifier_aggregate_hotfix_read_only.sql';

  static const bool sqlProductionChange = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool dependencyZeroCertified = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> retrySequence = [
    '17_db_public_dependency_classifier_aggregate_hotfix_read_only.sql',
    '15_db_public_dependency_classifier_read_only.sql',
    '16_dependency_resolution_next_gate_read_only.sql',
  ];
}

/// Marker for classifier result intake and Wave A planning.
class PwfDatabaseOwnershipClassifierWaveAPlan20260526 {
  const PwfDatabaseOwnershipClassifierWaveAPlan20260526._();

  static const String batchKey =
      'platform_database_ownership_classifier_result_intake_wave_a_plan_2026_05_26';
  static const String decision =
      'CLASSIFIER_OUTPUT_ACCEPTED_RAW_502_NOT_FLAT_BLOCKER_WAVE_A_REQUIRED';

  static const bool classifierOutputAccepted = true;
  static const bool rawDependencyCountIsFlatBlocker = false;
  static const bool flutterLiteralRemediationAccepted = true;
  static const bool waveARemediationPlanRequired = true;
  static const bool dependencyZeroCertified = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> normalizedBuckets = <String>[
    'public_surface_self_reference_or_legacy_wrapper',
    'owner_schema_dependency_needs_wrapper_review',
    'protected_sovereign_reference_review_only',
    'unclassified_dependency_review_required',
    'routine_source_mentions_public',
    'view_or_rule_dependency',
  ];
}

/// DB Dependency Remediation Pack Wave A — consolidated planning marker.
///
/// This marker is added after SQL 18/19/20 confirmed that the raw 502 DB
/// dependencies are not a flat blocker. Wave A separates actual remediation
/// candidates from accepted public compatibility surfaces, sovereign review-only
/// references, source-text mentions, and manually classified extension/runtime
/// items. It does not execute schema changes.
class PwfDatabaseDependencyRemediationWaveA20260526 {
  const PwfDatabaseDependencyRemediationWaveA20260526._();

  static const String batchKey =
      'platform_database_dependency_remediation_wave_a_consolidated_pack_2026_05_26';
  static const String decision =
      'RAW_502_NORMALIZED_WAVE_A_DESIGN_ONLY_EXECUTION_BLOCKED';

  static const bool classifierOutputAccepted = true;
  static const bool raw502IsFlatBlocker = false;
  static const bool bucketNormalizationAccepted = true;
  static const bool waveAExecutionDesignPrepared = true;

  static const bool dependencyZeroCertified = false;
  static const bool rlsNegativeUatAccepted = false;
  static const bool browserConsoleCleanAccepted = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool productionApproved = false;

  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> waveACandidateBuckets = <String>[
    'owner_schema_dependency_needs_wrapper_review',
    'view_or_rule_dependency',
  ];

  static const List<String> acceptedOrReviewOnlyBuckets = <String>[
    'public_surface_self_reference_or_legacy_wrapper',
    'routine_source_mentions_public',
    'protected_sovereign_reference_review_only',
    'unclassified_dependency_review_required',
  ];

  static const List<String> waveAScopeFamilies = <String>[
    'core helper functions and views',
    'assistant helper functions',
    'tasks helper functions',
    'platform_access compatibility views',
    'platform_content compatibility views',
    'media_center compatibility views/RPCs',
    'platform_services compatibility surfaces',
    'document intelligence RPC compatibility surfaces',
  ];

  static const List<String> excludedFromExecutionInThisPack = <String>[
    'auth.users',
    'waqf / waqf_assets',
    'awqaf_system',
    'gis writes',
    'extensions/realtime/graphql/topology without manual classification',
    'public compatibility wrappers accepted until explicit replacement',
  ];

  static const List<String> readOnlySqlSequence = <String>[
    '21_wave_a_consolidated_remediation_plan_read_only.sql',
    '22_wave_a_guarded_execution_blocker_read_only.sql',
    '23_wave_a_next_gate_read_only.sql',
  ];
}

/// Result intake for SQL 21/22/23 and Wave A exact body review gate.
///
/// This marker records that Wave A planning has accepted the classifier and
/// bucket normalization results, but execution remains blocked. The next safe
/// step is to export exact candidate bodies for review only; it is not a DDL,
/// DML, GRANT, DROP, archive/delete, or exact public table replacement step.
class PwfDatabaseDependencyWaveAResultIntakeExactBodyReview20260526 {
  const PwfDatabaseDependencyWaveAResultIntakeExactBodyReview20260526._();

  static const String batchKey =
      'platform_database_dependency_wave_a_result_intake_exact_body_review_gate_2026_05_26';
  static const String decision =
      'WAVE_A_RESULTS_ACCEPTED_EXACT_BODY_REVIEW_REQUIRED_EXECUTION_BLOCKED';

  static const bool classifierOutputIntaken = true;
  static const bool flutterLiteralRemediationAccepted = true;
  static const bool raw502IsFlatBlocker = false;
  static const bool bucketNormalizationComplete = true;
  static const bool waveAExecutionDesignRequired = true;
  static const bool exactBodyExportRequired = true;

  static const bool rlsNegativeUatAccepted = false;
  static const bool browserConsoleCleanAccepted = false;
  static const bool tokenBackupGovernanceAccepted = false;
  static const bool dependencyZeroCertified = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool productionApproved = false;

  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> acceptedWaveABuckets = <String>[
    'owner_schema_dependency_needs_wrapper_review',
    'view_or_rule_dependency',
  ];

  static const List<String> blockedExecutionFamilies = <String>[
    'guarded_sql_02_03_04_without_token_backup_governance',
    'archive_delete_drop_exact_public_replacement',
    'auth_users_migration',
    'flutter_elevated_secret',
    'waqf_assets_or_waqf_or_awqaf_system_mutation',
  ];

  static const List<String> nextReadOnlySqlSequence = <String>[
    '24_wave_a_result_intake_exact_body_review_gate_read_only.sql',
    '25_wave_a_candidate_exact_body_export_read_only.sql',
    '26_wave_a_execution_authorization_gate_read_only.sql',
    '27_wave_a_rls_browser_evidence_matrix_read_only.sql',
  ];
}

/// Intake of SQL 24/25/26/27 and exact body export review posture.
///
/// This marker records that exact candidate bodies were exported for review.
/// It does not approve execution. The review narrows Wave A to candidate body
/// families and keeps risky DML/import/sovereign surfaces out of execution.
class PwfDatabaseDependencyWaveAExactBodyExportReviewIntake20260526 {
  const PwfDatabaseDependencyWaveAExactBodyExportReviewIntake20260526._();

  static const String batchKey =
      'platform_database_dependency_wave_a_exact_body_export_review_intake_2026_05_26';
  static const String decision =
      'EXACT_BODY_EXPORT_ACCEPTED_FOR_REVIEW_EXECUTION_STILL_BLOCKED';

  static const bool sql24ResultIntakeAccepted = true;
  static const bool sql25ExactBodyExportSupplied = true;
  static const bool sql26ExecutionGateStillBlocked = true;
  static const bool sql27RlsBrowserEvidenceMatrixOpen = true;

  static const bool exactBodyReviewComplete = false;
  static const bool executionAuthorized = false;
  static const bool dependencyZeroCertified = false;
  static const bool rlsNegativeUatAccepted = false;
  static const bool browserConsoleCleanAccepted = false;
  static const bool tokenBackupGovernanceAccepted = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool productionApproved = false;

  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> exactBodyFamiliesReviewed = <String>[
    'assistant_admin_access_helpers_public_admin_users_dependency',
    'core_admin_unit_access_helpers_public_admin_users_dependency',
    'tasks_audit_access_helpers_public_admin_users_dependency',
    'media_center_public_view_already_owner_schema_view',
  ];

  static const List<String> excludedFromWaveAExecution = <String>[
    'core legacy waqf/community import loaders containing operational DML',
    'awqaf_system or waqf or waqf_assets functions',
    'gis protected read-only wrappers',
    'extensions/realtime/graphql/topology unclassified objects',
    'public compatibility wrappers accepted until explicit replacement',
  ];

  static const List<String> nextReadOnlySqlSequence = <String>[
    '28_wave_a_exact_body_export_result_intake_read_only.sql',
    '29_wave_a_exact_body_review_matrix_read_only.sql',
    '30_wave_a_execution_preconditions_gate_read_only.sql',
    '31_wave_a_authorization_package_next_gate_read_only.sql',
  ];
}

/// Hotfix for SQL 29 relation "core" parser failure.
///
/// The SQL 29 review matrix was rewritten without VALUES recordset syntax after
/// Supabase/PostgreSQL reported ERROR 42P01: relation "core" does not exist.
/// This marker does not authorize execution; it only records the safe retry path.
class PwfDatabaseDependencyWaveASql29CoreRelationHotfix20260526 {
  const PwfDatabaseDependencyWaveASql29CoreRelationHotfix20260526._();

  static const String batchKey =
      'platform_database_dependency_wave_a_sql29_core_relation_hotfix_2026_05_26';
  static const String decision =
      'SQL29A_CORE_RELATION_HOTFIX_APPLIED_RETRY_REQUIRED_EXECUTION_BLOCKED';

  static const bool sql28ResultIntakeAccepted = true;
  static const bool sql25ExactBodyExportSupplied = true;
  static const bool sql29MatrixRewritten = true;
  static const bool exactBodyReviewComplete = false;
  static const bool executionAuthorized = false;
  static const bool dependencyZeroCertified = false;
  static const bool rlsNegativeUatAccepted = false;
  static const bool browserConsoleCleanAccepted = false;
  static const bool tokenBackupGovernanceAccepted = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool productionApproved = false;

  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> retryReadOnlySqlSequence = <String>[
    '32_wave_a_sql29_core_relation_hotfix_read_only.sql',
    '29_wave_a_exact_body_review_matrix_read_only.sql',
    '30_wave_a_execution_preconditions_gate_read_only.sql',
    '31_wave_a_authorization_package_next_gate_read_only.sql',
  ];
}

/// SQL29B safe bypass after SQL 29 continued to fail in the SQL runner.
///
/// This marker retires SQL 29 as a runnable matrix and moves the read-only path
/// to SQL 33/34/35. It does not authorize execution or production approval.
class PwfDatabaseDependencyWaveASql29BSafeBypass20260526 {
  const PwfDatabaseDependencyWaveASql29BSafeBypass20260526._();

  static const String batchKey =
      'platform_database_dependency_wave_a_sql29b_safe_bypass_2026_05_26';
  static const String decision =
      'SQL29_RETIRED_SQL33_34_35_SAFE_PATH_REQUIRED_EXECUTION_BLOCKED';

  static const bool sql29Retired = true;
  static const bool sql33SafeMatrixAdded = true;
  static const bool exactBodyReviewComplete = false;
  static const bool executionAuthorized = false;
  static const bool dependencyZeroCertified = false;
  static const bool rlsNegativeUatAccepted = false;
  static const bool browserConsoleCleanAccepted = false;
  static const bool tokenBackupGovernanceAccepted = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool productionApproved = false;

  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> nextReadOnlySqlSequence = <String>[
    '33_wave_a_sql29b_no_schema_token_review_matrix_read_only.sql',
    '34_wave_a_sql29b_safe_execution_preconditions_read_only.sql',
    '35_wave_a_sql29b_safe_next_gate_read_only.sql',
  ];
}

/// Wave A actual remediation pack for access helpers.
///
/// This marker records that actual guarded replacement SQL bodies were drafted
/// for assistant/core/tasks access helpers. Execution remains fail-closed and
/// is not approved by this baseline.
class PwfDatabaseDependencyWaveAAccessHelpersActualRemediation20260526 {
  const PwfDatabaseDependencyWaveAAccessHelpersActualRemediation20260526._();

  static const String batchKey =
      'platform_database_dependency_wave_a_access_helpers_actual_remediation_2026_05_26';
  static const String decision =
      'ACTUAL_REMEDIATION_PACK_PREPARED_EXECUTION_FAIL_CLOSED';

  static const bool sql29Retired = true;
  static const bool actualReplacementBodiesDrafted = true;
  static const bool limitedToAccessHelpers = true;
  static const bool executionAuthorized = false;
  static const bool dependencyZeroCertified = false;
  static const bool rlsNegativeUatAccepted = false;
  static const bool browserConsoleCleanAccepted = false;
  static const bool tokenBackupGovernanceAccepted = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool productionApproved = false;

  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> guardedSqlSequence = <String>[
    '36_wave_a_access_helpers_preflight_read_only.sql',
    '37_wave_a_access_helpers_guarded_replacement_DRAFT_NOT_RUN.sql',
    '38_wave_a_access_helpers_post_apply_validation_read_only.sql',
    '39_wave_a_access_helpers_rls_browser_uat_matrix_read_only.sql',
    '40_wave_a_access_helpers_next_gate_read_only.sql',
  ];
}

/// Result intake after SQL 36 access-helper preflight passed.
///
/// This marker confirms that the compatibility surfaces and target helper
/// routines required for reviewing SQL 37 exist. It does not authorize SQL 37
/// execution or any destructive database operation.
class PwfDatabaseDependencyWaveAAccessHelpersPreflightPassed20260526 {
  const PwfDatabaseDependencyWaveAAccessHelpersPreflightPassed20260526._();

  static const String batchKey =
      'platform_database_dependency_wave_a_access_helpers_preflight_passed_intake_2026_05_26';
  static const String decision =
      'SQL36_PREFLIGHT_PASSED_SQL37_REVIEW_REQUIRED_EXECUTION_BLOCKED';

  static const bool sql36PreflightPassed = true;
  static const bool guardedSql37Reviewable = true;
  static const bool sql37ExecutionAuthorized = false;
  static const bool dependencyZeroCertified = false;
  static const bool rlsNegativeUatAccepted = false;
  static const bool browserConsoleCleanAccepted = false;
  static const bool tokenBackupGovernanceAccepted = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool productionApproved = false;

  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> nextOperatorChecks = <String>[
    'review_37_wave_a_access_helpers_guarded_replacement_DRAFT_NOT_RUN.sql',
    'document_backup_restore_point',
    'supply_governance_token',
    'attach_rls_negative_uat_actor_evidence',
    'attach_browser_network_clean_evidence',
  ];
}

/// Safe stop and architectural re-decision for Database Ownership Wave A.
///
/// Wave A is closed as analysis/classification/preflight only. Access-helper
/// replacement is cancelled in this track and deferred to a future Auth/RBAC
/// controlled migration.
class PwfDatabaseOwnershipWaveASafeStopArchitecturalRedecision20260526 {
  const PwfDatabaseOwnershipWaveASafeStopArchitecturalRedecision20260526._();

  static const String batchKey =
      'platform_database_ownership_wave_a_safe_stop_architectural_redecision_2026_05_26';
  static const String decision =
      'DO_NOT_EXECUTE_WAVE_A_ACCESS_HELPER_REPLACEMENT';

  static const bool waveAClosedAsDesignPreflightOnly = true;
  static const bool sql36PreflightPassed = true;
  static const bool sql37Executed = false;
  static const bool sql37GuardBlockedExpected = true;
  static const bool publicCompatibilityLayerAccepted = true;
  static const bool dependencyZeroDeferred = true;
  static const bool accessHelperRewriteDeferredToAuthRbac = true;

  static const bool sql29DoNotRun = true;
  static const bool sql37DoNotRun = true;
  static const bool sql38DoNotRun = true;
  static const bool sql39DoNotRun = true;
  static const bool sql40DoNotRun = true;
  static const bool guardedSql02To04DoNotRun = true;

  static const bool executionAuthorized = false;
  static const bool dependencyZeroCertified = false;
  static const bool rlsNegativeUatAccepted = false;
  static const bool browserConsoleCleanAccepted = false;
  static const bool tokenBackupGovernanceAccepted = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool productionApproved = false;

  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> preservedEvidence = <String>[
    'dependency_inventory_and_raw_502_classification',
    'flutter_literal_remediation_scan_zero',
    'wave_a_scope_narrowing_to_access_helpers',
    'sql36_preflight_passed',
    'sql37_guard_blocked_before_execution',
  ];

  static const List<String> futureTrackRequirements = <String>[
    'auth_rbac_controlled_migration_pack',
    'exact_body_approval',
    'backup_restore_point',
    'governance_authorization_token',
    'actor_case_rls_negative_uat',
    'browser_network_clean_evidence',
    'rollback_plan',
  ];
}

/// Database Ownership Phase B — Media Center controlled ownership closure entry.
///
/// This does not resume Wave A access-helper replacement. It starts a bounded
/// media-only ownership closure with public compatibility preservation.
class PwfDatabaseOwnershipPhaseBMediaCenterControlledClosure20260526 {
  const PwfDatabaseOwnershipPhaseBMediaCenterControlledClosure20260526._();

  static const String batchKey =
      'database_ownership_phase_b_media_center_controlled_ownership_closure_2026_05_26';
  static const String decision =
      'PHASE_B_MEDIA_CENTER_ENTRY_APPROVED_READ_ONLY_INVENTORY_FIRST';

  static const bool waveASafeStopPreserved = true;
  static const bool mediaCenterOwnerSchemaTarget = true;
  static const bool publicCompatibilityLayerAccepted = true;
  static const bool legacyPublicMediaPreserved = true;
  static const bool mediaSyncExecutionAuthorized = false;
  static const bool sql05GuardedSyncCandidateDoNotRunNow = true;
  static const bool serviceCenterDeferredToNextPhase = true;
  static const bool authRbacOutOfScope = true;

  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;
  static const bool noGisMutation = true;

  static const List<String> runOrder = <String>[
    '01_phase_b_media_inventory_read_only.sql',
    '02_phase_b_media_owner_contract_read_only.sql',
    '03_phase_b_media_public_compat_surface_read_only.sql',
    '04_phase_b_media_counts_visibility_read_only.sql',
    '06_phase_b_media_browser_uat_matrix_read_only.sql',
    '07_phase_b_media_next_gate_read_only.sql',
  ];

  static const List<String> doNotRunNow = <String>[
    '05_phase_b_media_guarded_sync_candidate_DRAFT_NOT_RUN.sql',
    'SQL29',
    'SQL37',
    'SQL38',
    'SQL39',
    'SQL40',
    'SQL02',
    'SQL03',
    'SQL04',
  ];

  static const List<String> mediaScope = <String>[
    'public.news_articles',
    'public.announcements',
    'public.activities',
    'public.media_gallery_items',
    'media_center.content_items',
    'media_center.content_assets',
    'media_center.v_content_items_public_v1',
    'public.v_media_news_compat_v1',
    'public.v_media_announcements_compat_v1',
    'public.v_media_activities_compat_v1',
    'public.v_media_content_compat_v1',
    'public.rpc_media_content_compat_v1',
  ];
}

/// Database Ownership Phase B — Media Center Mega Closure Pack.
///
/// Consolidates Phase B Media into one engineered package: master census,
/// guarded one-shot apply, post-apply validation, browser/runtime UAT, and final gate.
class PwfDatabaseOwnershipPhaseBMediaCenterMegaClosure20260528 {
  const PwfDatabaseOwnershipPhaseBMediaCenterMegaClosure20260528._();

  static const String batchKey =
      'database_ownership_phase_b_media_center_mega_closure_pack_2026_05_28';
  static const String decision =
      'PHASE_B_MEDIA_CENTER_MEGA_CLOSURE_PREPARED_ONE_LARGE_BATCH';

  static const bool waveASafeStopPreserved = true;
  static const bool oneLargeBatch = true;
  static const bool masterCensusIncluded = true;
  static const bool guardedOneShotApplyIncluded = true;
  static const bool publicCompatibilityLayerPreserved = true;
  static const bool legacyPublicMediaPreserved = true;
  static const bool serviceCenterDeferred = true;
  static const bool authRbacOutOfScope = true;

  static const bool applyExecutionAuthorizedByDefault = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;
  static const bool noGisMutation = true;

  static const List<String> packageFiles = <String>[
    '00_EXECUTIVE_RUNBOOK.md',
    '01_MEDIA_CENTER_MASTER_CENSUS_READ_ONLY.sql',
    '02_MEDIA_CENTER_ONE_SHOT_CONTROLLED_APPLY_GUARDED.sql',
    '03_MEDIA_CENTER_POST_APPLY_VALIDATION_READ_ONLY.sql',
    '04_MEDIA_CENTER_BROWSER_UAT_AND_RUNTIME_MATRIX_READ_ONLY.sql',
    '05_MEDIA_CENTER_FINAL_CLOSURE_GATE_READ_ONLY.sql',
  ];

  static const List<String> hardDoNotRun = <String>[
    'SQL29',
    'SQL37',
    'SQL38',
    'SQL39',
    'SQL40',
    'SQL02',
    'SQL03',
    'SQL04',
  ];
}
