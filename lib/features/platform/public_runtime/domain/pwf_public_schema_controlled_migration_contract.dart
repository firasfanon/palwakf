/// Contract for Mega Batch — Public Schema Controlled Ownership Migration
/// + Dependency / Analyzer / Browser UAT / Runtime Certification Gate.
///
/// This contract is intentionally declarative. Runtime code must not infer that
/// legacy public table deletion, alias replacement, or production approval has
/// occurred. The SQL pack creates target owner shadow tables and public
/// compatibility wrappers while preserving existing public legacy tables.
class PwfPublicSchemaControlledMigrationContract {
  const PwfPublicSchemaControlledMigrationContract._();

  static const String batchKey =
      'mega_batch_public_schema_controlled_migration_dependency_analyzer_browser_uat_runtime_certification_gate_2026_05_22';

  static const String decision =
      'CONTROLLED_OWNER_SHADOW_MIGRATION_DEPENDENCY_ANALYZER_BROWSER_UAT_GATE_ADDED';

  static const String publicRole = 'wrappers_rpc_views_aliases_only';

  static const bool legacyPublicTablesDeleted = false;
  static const bool authUsersMigrated = false;
  static const bool exactPublicTableNameReplacementPerformed = false;
  static const bool productionApproved = false;
  static const bool dependencyZeroCertified = false;
  static const bool analyzerEvidenceAccepted = false;
  static const bool browserConsoleUatEvidenceAccepted = false;
  static const bool runtimeCertificationApproved = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> platformShellTables = [
    'platform.app_settings',
    'platform.footer_settings',
    'platform.header_settings',
    'platform.homepage_sections',
    'platform.site_pages',
    'platform.site_settings',
    'platform.home_config',
    'platform.hero_slides',
    'platform.home_stats',
    'platform.home_services',
    'platform.home_hero_slides',
    'platform.breaking_news',
  ];

  static const List<String> platformAccessTables = [
    'platform.platform_permissions',
    'platform.platform_systems',
    'platform.user_permissions',
    'platform.user_system_permissions',
    'platform.user_system_roles',
  ];

  static const List<String> coreLinkageTables = [
    'core.admin_users',
    'core.user_accounts',
    'core.org_units_cache',
    'core.pwf_org_units_cache',
  ];

  static const List<String> assistantTables = [
    'assistant.assistant_conversations',
    'assistant.assistant_messages',
    'assistant.chatbot_conversations',
    'assistant.chatbot_messages',
    'assistant.chatbot_intents',
    'assistant.chatbot_retention_policies',
  ];

  static const List<String> publicCompatibilityWrappers = [
    'public.v_platform_homepage_sections_compat_v1',
    'public.v_platform_header_settings_compat_v1',
    'public.v_platform_footer_settings_compat_v1',
    'public.v_platform_site_pages_compat_v1',
    'public.v_platform_user_system_roles_compat_v1',
    'public.v_platform_user_system_permissions_compat_v1',
    'public.v_core_admin_users_compat_v1',
    'public.v_assistant_chatbot_messages_compat_v1',
    'public.v_public_schema_controlled_migration_status_v1',
    'public.rpc_public_schema_controlled_migration_status_v1()',
  ];

  static const List<String> executionGuards = [
    'do not delete or drop public legacy tables',
    'do not migrate auth.users',
    'do not mutate waqf/waq_assets/awqaf_system',
    'do not replace legacy public table names before dependency-zero evidence',
    'run SQL UAT and Browser/Analyzer evidence before certification',
  ];
}

class PwfPublicSchemaControlledMigrationDependencyGate {
  const PwfPublicSchemaControlledMigrationDependencyGate._();

  static const String gateDecision =
      'BLOCKED_UNTIL_DEPENDENCY_ZERO_ANALYZER_BROWSER_UAT_EVIDENCE';

  static const List<String> requiredSqlScripts = [
    '01_public_schema_dependency_surface_inventory_read_only.sql',
    '02_public_schema_runtime_certification_gate_read_only.sql',
    '03_public_schema_browser_uat_matrix_read_only.sql',
  ];

  static const List<String> blockerFamilies = [
    'direct Flutter PostgREST references to legacy public tables',
    'database views/functions depending on legacy public table OIDs',
    'missing owner-shadow targets',
    'missing public compatibility wrappers',
    'browser console errors tied to migrated public objects',
  ];

  static const List<String> certificationRequirements = [
    'dependency_blocker_count == 0 from SQL 02',
    'missing_target_count == 0 from SQL 02',
    'missing_surface_count == 0 from SQL 02',
    'flutter analyze accepted after this baseline is applied',
    'browser UAT evidence accepted for public/admin routes in SQL 03 matrix',
    'explicit governance approval before archive/delete/exact table-name replacement',
  ];

  static const List<String> prohibitedUntilExplicitApproval = [
    'DROP public legacy tables',
    'DELETE public legacy rows',
    'ARCHIVE public legacy objects',
    'RENAME owner tables to exact legacy public names',
    'replace public table names while dependencies remain non-zero',
    'touch waqf_assets, waqf, or awqaf_system from platform-public migration',
  ];
}

class PwfPublicSchemaControlledMigrationStaticScanSnapshot {
  const PwfPublicSchemaControlledMigrationStaticScanSnapshot._();

  static const int directPostgrestReferenceCount = 29;
  static const int uniqueDirectPostgrestFiles = 16;
  static const int publicTextReferenceFiles = 16;

  static const List<String> highRiskDirectRuntimeFiles = [
    'lib/core/access/access_repository.dart',
    'lib/core/visual_identity/visual_identity_publish_repository.dart',
    'lib/data/repositories/admin_users_repository.dart',
    'lib/data/repositories/auth_repository.dart',
    'lib/data/repositories/footer_repository.dart',
    'lib/data/repositories/header_repository.dart',
    'lib/data/repositories/homepage_repository.dart',
    'lib/data/repositories/rbac_admin_repository.dart',
    'lib/features/platform/home/data/repositories/pwf_site_pages_repository.dart',
    'lib/features/tasks_system/data/repositories/admin_users_repository.dart',
    'lib/features/tasks_system/data/repositories/auth_repository.dart',
    'lib/features/tasks_system/data/repositories/footer_repository.dart',
    'lib/features/tasks_system/data/repositories/header_repository.dart',
    'lib/features/tasks_system/data/repositories/homepage_repository.dart',
    'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart',
    'lib/presentation/screens/admin/main/management/home_management/pwf_unit_pages_repository.dart',
  ];

  static const String conclusion =
      'exact-public-table-name-replacement-and-legacy-archive-delete-remain-blocked';
}

/// Result-intake snapshot for analyzer/Chrome/SQL evidence received after the
/// controlled migration runtime certification gate. This does not override the
/// destructive-step blockers in [PwfPublicSchemaControlledMigrationDependencyGate].
class PwfPublicSchemaControlledMigrationGateResultIntakeSnapshot {
  const PwfPublicSchemaControlledMigrationGateResultIntakeSnapshot._();

  static const String batchKey =
      'public_schema_controlled_migration_gate_result_intake_analyzer_chrome_sql_evidence_2026_05_22';

  static const String decision =
      'SQL_SAFETY_ANALYZER_CHROME_ACCEPTED_CONSOLE_AND_DEPENDENCY_ZERO_PENDING';

  static const bool sqlSafetyGatePassed = true;
  static const bool analyzerEvidenceAccepted = true;
  static const bool chromeStartupEvidenceAccepted = true;
  static const bool browserConsoleCleanEvidenceAccepted = false;
  static const bool dependencyZeroCertified = false;
  static const bool runtimeCertificationApproved = false;
  static const bool productionApproved = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableNameReplacementAuthorized = false;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> acceptedEvidence = [
    'sql safety boundary: no destructive SQL',
    'sovereign boundary: no waqf_assets/waqf/awqaf_system mutation',
    'flutter analyze: No issues found',
    'flutter run -d chrome: debug service started',
    'Supabase initialized successfully',
    'Visual identity bootstrap loaded 2 published overrides',
  ];

  static const List<String> pendingEvidence = [
    'browser console clean evidence for public/admin routes',
    'dependency-zero SQL certification before exact replacement/archive/delete',
    'explicit governance approval before destructive or exact replacement step',
  ];
}

/// Route-console evidence intake and dependency-zero runtime reroute planning
/// snapshot. This is deliberately stricter than the analyzer/Chrome result
/// intake: startup success does not authorize reroute.
class PwfPublicSchemaRouteConsoleReroutePlanningGate {
  const PwfPublicSchemaRouteConsoleReroutePlanningGate._();

  static const String batchKey =
      'public_schema_controlled_migration_route_console_evidence_intake_dependency_zero_reroute_planning_gate_2026_05_22';

  static const String decision =
      'REROUTE_BLOCKED_DEPENDENCY_OR_CONSOLE_OR_APPROVAL_PENDING';

  static const bool analyzerCleanAccepted = true;
  static const bool chromeStartupAccepted = true;
  static const bool sqlSafetyGateAccepted = true;
  static const bool routeConsoleCleanEvidenceAccepted = false;
  static const bool dependencyZeroCertified = false;
  static const bool runtimeRerouteAuthorized = false;
  static const bool exactPublicTableNameReplacementAuthorized = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool productionApproved = false;
  static const bool noWaqfAssetsMutation = true;

  static const int staticDirectPostgrestUniqueFileTablePairCount = 29;
  static const int staticDirectPostgrestFileCount = 16;

  static const List<String> requiredRouteConsoleEvidence = [
    '/home',
    '/home/news',
    '/home/news/:id',
    '/home/announcements',
    '/home/announcements/:id',
    '/home/gallery',
    '/home/zakat',
    '/zakat',
    '/press-releases',
    '/admin/database-migration',
  ];

  static const List<String> reroutePrerequisites = [
    'browser route-console evidence accepted for all route matrix entries',
    'dependency_blocker_count == 0 from SQL 06',
    'static Flutter legacy public references == 0 or reviewed non-blocking adapter plan',
    'one-family-at-a-time reroute plan with rollback flag',
    'explicit governance approval before runtime source switch',
  ];

  static const List<String> stillBlocked = [
    'runtime reroute',
    'exact public table-name replacement',
    'archive/delete/drop/rename',
    'production approval',
    'any waqf_assets/waqf/awqaf_system mutation',
  ];
}

/// Direct-dependency remediation plan snapshot. This freezes the 29 direct
/// PostgREST file/table pairs detected after SQL06 retest and turns them into
/// a family-by-family remediation plan. It does not authorize runtime reroute.
class PwfPublicSchemaDirectDependencyRemediationPlan {
  const PwfPublicSchemaDirectDependencyRemediationPlan._();

  static const String batchKey =
      'public_schema_direct_dependency_remediation_plan_route_console_evidence_pack_2026_05_23';

  static const String decision =
      'DIRECT_DEPENDENCY_REMEDIATION_PLAN_ADDED_REROUTE_STILL_BLOCKED';

  static const int directPostgrestUniqueFileTablePairCount = 29;
  static const int uniqueDirectFileCount = 16;
  static const bool dependencyZeroCertified = false;
  static const bool routeConsoleEvidenceAccepted = false;
  static const bool runtimeRerouteAuthorized = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableNameReplacementAuthorized = false;
  static const bool productionApproved = false;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> remediationFamilies = [
    'phase_1_platform_shell_site_content: 14 direct pairs',
    'phase_2_platform_access_rbac: 10 direct pairs',
    'phase_3_core_linkage: 5 direct pairs',
    'phase_4_assistant: no current direct pair, kept as future guard',
  ];

  static const List<String> routeConsoleEvidenceRoutes = [
    '/home',
    '/home/news',
    '/home/news/:id',
    '/home/announcements',
    '/home/announcements/:id',
    '/home/gallery',
    '/home/zakat',
    '/zakat',
    '/press-releases',
    '/admin/database-migration',
  ];

  static const List<String> remediationRules = [
    'use typed repository adapters instead of raw direct legacy public table reads',
    'public wrappers/RPCs remain the stable runtime surface',
    'owner schemas remain internal authority, not public route contracts',
    'reroute one family at a time only',
    'each reroute family requires rollback flag and browser console evidence',
    'no archive/delete/drop/rename/exact replacement before dependency-zero and explicit approval',
  ];
}

/// Phase 1 adapter remediation constants for platform shell/site-content.
///
/// This batch redirects runtime reads for site pages, homepage sections,
/// header, footer, site settings, hero slides, and breaking news to public
/// compatibility wrappers while preserving legacy public write tables pending
/// explicit owner-write RPC approval.
class PwfPublicSchemaPhase1SiteContentRemediationContract {
  static const String batchKey =
      'public_schema_phase1_platform_shell_site_content_adapter_remediation_browser_console_uat';

  static const List<String> remediatedRuntimeReadSurfaces = <String>[
    'public.v_platform_site_pages_compat_v1',
    'public.v_platform_homepage_sections_compat_v1',
    'public.v_platform_header_settings_compat_v1',
    'public.v_platform_footer_settings_compat_v1',
    'public.v_platform_site_settings_compat_v1',
    'public.v_platform_hero_slides_compat_v1',
    'public.v_platform_breaking_news_compat_v1',
  ];

  static const List<String> intentionallyPreservedWriteTables = <String>[
    'public.site_pages',
    'public.homepage_sections',
    'public.header_settings',
    'public.footer_settings',
    'public.site_settings',
    'public.hero_slides',
    'public.breaking_news',
  ];

  static const bool runtimeRerouteAuthorized = false;
  static const bool exactReplacementAuthorized = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool productionApproved = false;
  static const bool waqfAssetsMutationAllowed = false;
}

/// Phase 1 retest result intake after SQL12 scope hotfix and compile hotfix.
/// This accepts analyzer and Chrome startup evidence, but does not accept Route
/// Console evidence and does not authorize any replacement/destructive step.
class PwfPublicSchemaPhase1RetestResultIntakeSnapshot {
  const PwfPublicSchemaPhase1RetestResultIntakeSnapshot._();

  static const String batchKey =
      'public_schema_phase1_retest_result_intake_analyzer_chrome_sql12_14_2026_05_23';

  static const String decision =
      'PHASE1_RETEST_ACCEPTED_RBAC_AND_CORE_REMAIN_PENDING';

  static const bool dartFormatPassed = true;
  static const bool analyzerClean = true;
  static const bool chromeStartupPassed = true;
  static const bool sql12HotfixValidated = true;
  static const bool routeConsoleEvidenceAccepted = false;
  static const bool runtimeRerouteAuthorized = false;
  static const bool exactReplacementAuthorized = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool productionApproved = false;
  static const bool noWaqfAssetsMutation = true;

  static const int pendingPlatformAccessRbacPairs = 10;
  static const int pendingCoreLinkagePairs = 5;

  static const List<String> acceptedEvidence = <String>[
    'dart format succeeded on the four hotfix files',
    'flutter analyze returned No issues found',
    'flutter run -d chrome reached Debug Service',
    'Supabase initialized successfully',
    'Visual Identity bootstrap loaded 2 published overrides',
    'SQL 12 hotfix validated pending families only',
    'SQL 14 sovereign/destructive-sql boundary passed',
  ];

  static const List<String> pendingEvidence = <String>[
    'route console clean evidence for public/admin routes',
    'Phase 2 platform_access_rbac remediation and role UAT',
    'Phase 3 core_linkage remediation and auth/admin checks',
  ];
}

/// Route Console evidence closure request. Since no clean per-route console
/// evidence was supplied, the closure is recorded as pending/blocked rather than
/// accepted. Startup success alone is not a console-clean certification.
class PwfPublicSchemaRouteConsoleEvidenceClosureContract {
  const PwfPublicSchemaRouteConsoleEvidenceClosureContract._();

  static const String batchKey =
      'public_schema_route_console_evidence_closure_phase2_rbac_planning_gate_2026_05_23';

  static const String decision =
      'ROUTE_CONSOLE_EVIDENCE_NOT_SUPPLIED_CLOSURE_RECORDED_AS_PENDING';

  static const bool analyzerCleanAccepted = true;
  static const bool chromeStartupAccepted = true;
  static const bool routeConsoleCleanEvidenceAccepted = false;
  static const bool runtimeRerouteAuthorized = false;
  static const bool exactPublicTableNameReplacementAuthorized = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool productionApproved = false;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> requiredClosureRoutes = <String>[
    '/home',
    '/home/news',
    '/home/news/:id',
    '/home/announcements',
    '/home/announcements/:id',
    '/home/gallery',
    '/home/services',
    '/zakat',
    '/press-releases',
    '/admin/database-migration',
  ];
}

/// Phase 2 planning gate for platform access/RBAC direct dependencies.
/// This is planning-only: it inventories the 10 high-risk pairs and defines the
/// browser/role/RLS evidence required before an actual adapter remediation patch.
class PwfPublicSchemaPhase2RbacPlanningGateContract {
  const PwfPublicSchemaPhase2RbacPlanningGateContract._();

  static const String phaseKey = 'phase_2_platform_access_rbac';
  static const String decision =
      'PHASE2_RBAC_PLANNING_ONLY_RUNTIME_REMEDIATION_NOT_EXECUTED';

  static const int platformAccessRbacDirectPairs = 10;
  static const int uniqueLegacyPublicTables = 4;
  static const int uniqueRepositoryGroups = 3;

  static const bool phase2RuntimeRemediationExecuted = false;
  static const bool roleUatEvidenceAccepted = false;
  static const bool rlsEvidenceAccepted = false;
  static const bool browserConsoleEvidenceAccepted = false;
  static const bool runtimeRerouteAuthorized = false;
  static const bool exactReplacementAuthorized = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool productionApproved = false;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> affectedLegacyPublicTables = <String>[
    'public.user_system_permissions',
    'public.user_system_roles',
    'public.platform_permissions',
    'public.platform_systems',
  ];

  static const List<String> affectedFiles = <String>[
    'lib/core/access/access_repository.dart',
    'lib/data/repositories/rbac_admin_repository.dart',
    'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart',
  ];

  static const List<String> requiredBeforeImplementation = <String>[
    'confirm read wrappers/RPC contracts for platform RBAC access surfaces',
    'define rollback flag and legacy-read fallback per repository group',
    'run role UAT for super_admin, platform_admin, unit_admin, scoped user, unauthorized user, and anonymous user',
    'verify RLS policies do not leak platform-wide RBAC data',
    'provide Browser Console clean evidence for /admin/database-migration and RBAC/admin routes',
  ];
}

/// Phase 2 implementation result for platform access/RBAC adapters.
/// Runtime read paths are moved to public compatibility wrappers while admin
/// write paths stay on legacy public tables until owner-write RPCs are
/// explicitly designed, tested, and authorized.
class PwfPublicSchemaPhase2RbacAdapterRemediationContract {
  const PwfPublicSchemaPhase2RbacAdapterRemediationContract._();

  static const String phaseKey = 'phase_2_platform_access_rbac';
  static const String batchKey =
      'public_schema_phase2_rbac_adapter_remediation_implementation_role_rls_browser_uat_2026_05_23';

  static const String decision =
      'PHASE2_RBAC_READ_ADAPTERS_REMEDIATED_WRITE_PATHS_LEGACY_RPC_PENDING';

  static const bool runtimeReadAdaptersRemediated = true;
  static const bool adminWritePathsPreservedOnLegacyPublicTables = true;
  static const bool ownerWriteRpcsCreated = false;
  static const bool coreLinkageRemediated = false;
  static const bool authUsersMigrated = false;
  static const bool routeConsoleCleanEvidenceAccepted = false;
  static const bool roleUatEvidenceAccepted = false;
  static const bool rlsEvidenceAccepted = false;
  static const bool browserConsoleEvidenceAccepted = false;
  static const bool exactReplacementAuthorized = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool productionApproved = false;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> readCompatibilitySurfaces = <String>[
    'public.v_platform_systems_compat_v1',
    'public.v_platform_permissions_compat_v1',
    'public.v_platform_user_system_roles_compat_v1',
    'public.v_platform_user_system_permissions_compat_v1',
  ];

  static const List<String> remediatedFiles = <String>[
    'lib/core/access/access_repository.dart',
    'lib/data/repositories/rbac_admin_repository.dart',
    'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart',
  ];

  static const List<String> legacyWriteTablesStillUsed = <String>[
    'public.platform_systems',
    'public.user_system_roles',
    'public.user_system_permissions',
  ];

  static const List<String> requiredRetestEvidence = <String>[
    'dart format on the three RBAC adapter files and this contract/page if changed',
    'flutter analyze: No issues found',
    'flutter run -d chrome reaches Debug Service',
    'Browser Console clean evidence for RBAC/admin routes',
    'Role UAT for superuser/platform admin/unit admin/scoped user/unauthorized/anonymous',
    'RLS evidence showing no RBAC leakage from compatibility wrappers',
  ];
}

/// Development 9 — Phase 3 Core/Admin/Auth linkage planning gate.
/// This class records planning evidence only. It does not mean runtime code was
/// remediated, auth.users was migrated, owner-write RPCs were created, or
/// production was approved.
class PwfPublicSchemaPhase3CoreAdminAuthPlanningGateContract {
  const PwfPublicSchemaPhase3CoreAdminAuthPlanningGateContract._();

  static const String phaseKey = 'phase_3_core_admin_auth_linkage';
  static const String batchKey =
      'public_schema_phase3_core_admin_auth_owner_write_rpc_design_pack_2026_05_23';

  static const String decision =
      'PHASE3_CORE_ADMIN_AUTH_LINKAGE_PLANNING_ONLY_RUNTIME_REMEDIATION_NOT_EXECUTED';

  static const bool coreLinkageRuntimeRemediated = false;
  static const bool adminUserRuntimeAdaptersRemediated = false;
  static const bool authUsersMigrated = false;
  static const bool ownerWriteRpcsCreated = false;
  static const bool roleRlsBrowserConsoleEvidenceAccepted = false;
  static const bool runtimeRerouteAuthorized = false;
  static const bool exactReplacementAuthorized = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool productionApproved = false;
  static const bool noWaqfAssetsMutation = true;

  static const int coreAdminAuthDirectPairs = 5;

  static const List<String> affectedFiles = <String>[
    'lib/core/access/access_repository.dart',
    'lib/data/repositories/admin_users_repository.dart',
    'lib/data/repositories/auth_repository.dart',
    'lib/features/tasks_system/data/repositories/admin_users_repository.dart',
    'lib/features/tasks_system/data/repositories/auth_repository.dart',
  ];

  static const List<String> affectedLegacyPublicSurfaces = <String>[
    'public.admin_users',
  ];

  static const List<String> requiredBeforeRuntimeRemediation = <String>[
    'define core/admin compatibility read wrapper contract',
    'design and review core owner-write RPCs for admin profile operations',
    'preserve auth.users as Supabase auth source; do not migrate it',
    'verify auth.uid/admin scope enforcement inside RPCs, not only in Flutter',
    'close Role/RLS/Browser Console evidence for admin/core/RBAC routes',
  ];
}

/// Development 9 — Owner-write RPC design contract.
/// This is a design surface only. The proposed RPCs are not created by this
/// batch and must not be assumed by repositories until a later implementation
/// pack installs and tests them.
class PwfOwnerWriteRpcDesignContract {
  const PwfOwnerWriteRpcDesignContract._();

  static const String decision =
      'OWNER_WRITE_RPC_DESIGN_ONLY_DDL_NOT_RUN_RUNTIME_REROUTE_BLOCKED';

  static const bool designPackAdded = true;
  static const bool rpcDdlIncludedForExecution = false;
  static const bool rpcInstalled = false;
  static const bool flutterWriteRerouteAuthorized = false;
  static const bool legacyWriteFallbackStillRequired = true;
  static const bool rlsAuditRollbackReviewRequired = true;
  static const bool productionApproved = false;

  static const List<String> proposedPlatformWriteRpcs = <String>[
    'public.rpc_platform_system_register_v1',
    'public.rpc_platform_user_role_upsert_v1',
    'public.rpc_platform_user_role_delete_v1',
    'public.rpc_platform_user_permission_grant_v1',
    'public.rpc_platform_user_permission_revoke_v1',
  ];

  static const List<String> proposedCoreAdminWriteRpcs = <String>[
    'public.rpc_core_admin_user_profile_update_v1',
    'public.rpc_core_admin_user_link_v1',
    'public.rpc_core_admin_user_deactivate_v1',
  ];

  static const List<String> nonNegotiableGuards = <String>[
    'no service_role inside Flutter',
    'locked search_path for SECURITY DEFINER if used',
    'auth.uid and admin scope checks inside every RPC',
    'audit event for every write',
    'rollback flag before repository write reroute',
    'no direct auth.users write/migration',
  ];
}

/// Development 9 — Evidence intake and production gate re-decision.
class PwfDevelopment9EvidenceAndProductionGateDecision {
  const PwfDevelopment9EvidenceAndProductionGateDecision._();

  static const String decision =
      'PRODUCTION_NOT_APPROVED_PHASE3_AND_OWNER_WRITE_RPC_BLOCKERS_REMAIN';

  static const bool formatAnalyzeEvidenceSupplied = false;
  static const bool chromeStartupEvidenceSupplied = false;
  static const bool routeConsoleCleanEvidenceSupplied = false;
  static const bool roleUatEvidenceSupplied = false;
  static const bool rlsEvidenceSupplied = false;
  static const bool productionApproved = false;

  static const List<String> nextEvidenceRequired = <String>[
    'dart format for changed Development 9 files',
    'flutter analyze clean',
    'flutter run -d chrome startup evidence',
    'Browser Console clean evidence for /admin/database-migration and RBAC/Admin routes',
    'Role UAT for superuser/platform admin/unit admin/scoped user/unauthorized/anonymous',
    'RLS evidence for core/admin/RBAC wrappers and proposed RPCs',
  ];
}

/// Development 9D — Core/Admin/Auth runtime read adapter remediation.
///
/// This contract intentionally covers read-path remediation only. Owner-write
/// RPCs remain a preflight review concern and are not created or consumed here.
class PwfDevelopment9DRuntimeReadAdapterRemediationContract {
  const PwfDevelopment9DRuntimeReadAdapterRemediationContract._();

  static const String batchKey =
      'development_9d_phase3_runtime_read_adapter_remediation_owner_write_rpc_preflight';

  static const String decision =
      'READ_ADAPTER_REMEDIATION_APPLIED_OWNER_WRITE_RPC_IMPLEMENTATION_BLOCKED';

  static const bool coreAdminAuthReadAdapterRemediationApplied = true;
  static const bool ownerWriteRpcImplementationAuthorized = false;
  static const bool ownerWriteRpcsCreated = false;
  static const bool runtimeWriteRerouteAuthorized = false;
  static const bool roleRlsBrowserConsoleEvidenceSupplied = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noWaqfAssetsMutation = true;

  static const String coreAdminReadSurface =
      'public.v_core_admin_users_compat_v1';

  static const List<String> remediatedReadFiles = <String>[
    'lib/core/access/access_repository.dart',
    'lib/data/repositories/admin_users_repository.dart',
    'lib/data/repositories/auth_repository.dart',
    'lib/features/tasks_system/data/repositories/admin_users_repository.dart',
    'lib/features/tasks_system/data/repositories/auth_repository.dart',
  ];

  static const List<String> remainingOwnerWriteBlockers = <String>[
    'lib/data/repositories/admin_users_repository.dart: setActive/setSuperuser/updateAdminUser/createAdminUser',
    'lib/data/repositories/auth_repository.dart: updateProfile',
    'lib/features/tasks_system/data/repositories/admin_users_repository.dart: setActive/setSuperuser/createAdminUser',
  ];

  static const List<String> requiredBeforeOwnerWriteRpcImplementation =
      <String>[
        'review exact SQL bodies for proposed owner-write RPCs',
        'verify auth.uid/admin/scope checks inside each RPC',
        'define audit event contract for every write action',
        'lock search_path for SECURITY DEFINER functions if used',
        'define rollback/feature flag for repository write reroute',
        'define self-lockout and privilege-escalation guards',
        'supply Role/RLS/Browser Console evidence',
      ];
}

/// Development 9D — Owner-write RPC implementation preflight review gate.
class PwfDevelopment9DOwnerWriteRpcPreflightReviewGate {
  const PwfDevelopment9DOwnerWriteRpcPreflightReviewGate._();

  static const String decision =
      'IMPLEMENTATION_PREFLIGHT_REVIEW_ONLY_OWNER_WRITE_RPCS_NOT_CREATED';

  static const bool rpcBodyReviewCompleted = false;
  static const bool rlsAndAuthUidGuardsReviewed = false;
  static const bool auditContractReviewed = false;
  static const bool securityDefinerSearchPathReviewed = false;
  static const bool rollbackFlagReviewed = false;
  static const bool selfLockoutGuardReviewed = false;
  static const bool implementationAuthorized = false;
  static const bool productionApproved = false;
}

/// Development 9E — Owner-write RPC body review and implementation gate.
///
/// This contract records review obligations only. It does not authorize RPC
/// creation or Flutter write reroute.
class PwfDevelopment9EOwnerWriteRpcBodyReviewContract {
  const PwfDevelopment9EOwnerWriteRpcBodyReviewContract._();

  static const String batchKey =
      'development_9e_owner_write_rpc_body_review_rls_audit_search_path_rollback_gate';

  static const String decision =
      'OWNER_WRITE_RPC_IMPLEMENTATION_NOT_AUTHORIZED_BODY_REVIEW_REQUIRED';

  static const bool sql30RuntimeReadAdapterUatAccepted = true;
  static const bool sql31PreflightBlockersAccepted = true;
  static const bool rpcBodyReviewCompleted = false;
  static const bool rlsAndAuthUidGuardsReviewed = false;
  static const bool auditContractReviewed = false;
  static const bool securityDefinerSearchPathLocked = false;
  static const bool rollbackFlagDefined = false;
  static const bool selfLockoutGuardDefined = false;
  static const bool roleRlsBrowserConsoleEvidenceSupplied = false;
  static const bool ownerWriteRpcsCreated = false;
  static const bool flutterWriteRerouteAuthorized = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> proposedRpcBodiesRequiringReview = <String>[
    'public.rpc_core_admin_user_profile_update_v1(uuid,jsonb)',
    'public.rpc_core_admin_user_link_v1(uuid,jsonb)',
    'public.rpc_core_admin_user_deactivate_v1(uuid,jsonb)',
    'public.rpc_platform_system_register_v1(text,jsonb)',
    'public.rpc_platform_user_role_upsert_v1(uuid,text,text,jsonb)',
    'public.rpc_platform_user_role_delete_v1(uuid,text,jsonb)',
    'public.rpc_platform_user_permission_grant_v1(uuid,text,text,jsonb)',
    'public.rpc_platform_user_permission_revoke_v1(uuid,text,text,jsonb)',
  ];

  static const List<String> mandatoryReviewGates = <String>[
    'exact SQL body review',
    'auth.uid and admin/scope checks inside SQL',
    'audit event contract',
    'locked search_path for SECURITY DEFINER if used',
    'rollback/feature flag for write reroute',
    'self-lockout and privilege escalation guards',
    'legacy direct write fallback disablement plan',
    'Role/RLS/Browser Console evidence',
  ];
}

/// Development 9F — Owner-write RPC implementation authorization review
/// and exact body draft gate.
///
/// Review-only. It does not authorize CREATE FUNCTION, GRANT, or Flutter
/// write reroute.
class PwfDevelopment9FOwnerWriteRpcAuthorizationReviewContract {
  const PwfDevelopment9FOwnerWriteRpcAuthorizationReviewContract._();

  static const String batchKey =
      'development_9f_owner_write_rpc_authorization_review_exact_body_draft_gate';

  static const String decision =
      'OWNER_WRITE_RPC_IMPLEMENTATION_NOT_AUTHORIZED_EXACT_BODY_DRAFT_GATE_ONLY';

  static const bool sql32BodyReviewResultAccepted = true;
  static const bool sql33ImplementationGateResultAccepted = true;
  static const bool exactBodyDraftGateOpened = true;
  static const bool createFunctionAuthorized = false;
  static const bool grantAuthorized = false;
  static const bool ownerWriteRpcsCreated = false;
  static const bool flutterWriteRerouteAuthorized = false;
  static const bool roleRlsBrowserConsoleEvidenceSupplied = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noDestructiveSql = true;
  static const bool noFlutterServiceRole = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> exactBodyDraftRequiredFor = <String>[
    'public.rpc_core_admin_user_profile_update_v1(uuid,jsonb)',
    'public.rpc_core_admin_user_link_v1(uuid,jsonb)',
    'public.rpc_core_admin_user_deactivate_v1(uuid,jsonb)',
    'public.rpc_platform_system_register_v1(text,jsonb)',
    'public.rpc_platform_user_role_upsert_v1(uuid,text,text,jsonb)',
    'public.rpc_platform_user_role_delete_v1(uuid,text,jsonb)',
    'public.rpc_platform_user_permission_grant_v1(uuid,text,text,jsonb)',
    'public.rpc_platform_user_permission_revoke_v1(uuid,text,text,jsonb)',
  ];

  static const List<String> exactBodyMandatorySections = <String>[
    'actor derivation from auth.uid()',
    'SQL-level admin/scope authorization',
    'jsonb payload allow-list',
    'audit/admin event emission',
    'locked search_path if SECURITY DEFINER is used',
    'rollback/feature flag contract',
    'self-lockout and privilege-escalation protection',
    'negative Role/RLS/Browser Console UAT evidence',
  ];
}

/// Development 9G — Owner-write RPC exact body review + negative UAT
/// planning gate.
///
/// This closes the Phase 3 review-only micro-patch loop. The next step must
/// be a single consolidated implementation-candidate pack or a final handoff.
class PwfDevelopment9GOwnerWriteRpcConsolidationGateContract {
  const PwfDevelopment9GOwnerWriteRpcConsolidationGateContract._();

  static const String batchKey =
      'development_9g_owner_write_rpc_exact_body_review_negative_uat_consolidation_gate';

  static const String decision =
      'PHASE3_REVIEW_ONLY_MICRO_PATCH_LOOP_CLOSED_NEXT_STEP_MUST_BE_CONSOLIDATED';

  static const bool sql34AuthorizationReviewAccepted = true;
  static const bool sql35ExactBodyDraftAccepted = true;
  static const bool phase3MicroPatchLoopClosed = true;
  static const bool singleConsolidatedPackRequired = true;
  static const bool implementationAuthorized = false;
  static const bool createFunctionAuthorized = false;
  static const bool grantAuthorized = false;
  static const bool flutterWriteRerouteAuthorized = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noDestructiveSql = true;
  static const bool noFlutterServiceRole = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> negativeUatActorCases = <String>[
    'anonymous',
    'unauthorized_authenticated_user',
    'scoped_user',
    'unit_admin',
    'platform_admin',
    'superuser',
  ];

  static const List<String> nextAllowedPaths = <String>[
    'consolidated_implementation_candidate_with_exact_bodies_and_evidence',
    'final_handoff_or_switch_to_another_platform_stream',
  ];
}

/// Platform Development 10 — consolidated implementation candidate readiness
/// blocker pack.
///
/// The user requested Platform Development 10, but SQL 37 keeps execution
/// blocked. This contract records that Development 10 is a consolidated
/// readiness/boundary pack, not an executable RPC implementation.
class PwfPlatformDevelopment10ConsolidatedCandidateGateContract {
  const PwfPlatformDevelopment10ConsolidatedCandidateGateContract._();

  static const String batchKey =
      'platform_development_10_consolidated_implementation_candidate_readiness_blocker_pack';

  static const String decision =
      'CONSOLIDATED_IMPLEMENTATION_CANDIDATE_BLOCKED_MISSING_EXACT_BODIES_AND_EVIDENCE';

  static const bool sql37NegativeUatPlanAccepted = true;
  static const bool singleConsolidatedPackRequired = true;
  static const bool exactSqlBodiesRequired = true;
  static const bool exactSqlBodiesSupplied = false;
  static const bool negativeUatRequired = true;
  static const bool negativeUatEvidenceSupplied = false;
  static const bool implementationAuthorized = false;
  static const bool createFunctionAuthorized = false;
  static const bool grantAuthorized = false;
  static const bool ownerWriteRpcsCreated = false;
  static const bool flutterWriteRerouteAuthorized = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noDestructiveSql = true;
  static const bool noFlutterServiceRole = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> requiredRpcBodies = <String>[
    'public.rpc_core_admin_user_profile_update_v1(uuid,jsonb)',
    'public.rpc_core_admin_user_link_v1(uuid,jsonb)',
    'public.rpc_core_admin_user_deactivate_v1(uuid,jsonb)',
    'public.rpc_platform_system_register_v1(text,jsonb)',
    'public.rpc_platform_user_role_upsert_v1(uuid,text,text,jsonb)',
    'public.rpc_platform_user_role_delete_v1(uuid,text,jsonb)',
    'public.rpc_platform_user_permission_grant_v1(uuid,text,text,jsonb)',
    'public.rpc_platform_user_permission_revoke_v1(uuid,text,text,jsonb)',
  ];

  static const List<String> negativeUatActorCases = <String>[
    'anonymous',
    'unauthorized_authenticated_user',
    'scoped_user',
    'unit_admin',
    'platform_admin',
    'superuser',
  ];

  static const String nextExecutableGate =
      'AUTHORIZE_OWNER_WRITE_RPC_EXECUTION=true';
}

/// Platform Development 10A — authorization token intake.
///
/// The explicit token was supplied by the user, but it is not sufficient alone.
/// Execution remains blocked until exact bodies and evidence are supplied.
class PwfPlatformDevelopment10AAuthorizationTokenGateContract {
  const PwfPlatformDevelopment10AAuthorizationTokenGateContract._();

  static const String batchKey =
      'platform_development_10a_authorization_token_intake_exact_body_negative_uat_blocker';

  static const String decision =
      'AUTHORIZATION_TOKEN_RECEIVED_BUT_EXECUTION_BLOCKED_MISSING_EXACT_BODIES_AND_NEGATIVE_UAT';

  static const bool authorizationTokenReceived = true;
  static const bool authorizationTokenSufficientAlone = false;
  static const bool allExactBodiesSupplied = false;
  static const bool allExactBodiesApproved = false;
  static const bool negativeUatEvidenceSupplied = false;
  static const bool roleRlsBrowserConsoleEvidenceSupplied = false;
  static const bool effectiveImplementationAuthorized = false;
  static const bool createFunctionAuthorized = false;
  static const bool grantAuthorized = false;
  static const bool flutterWriteRerouteAuthorized = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noDestructiveSql = true;
  static const bool noFlutterServiceRole = true;
  static const bool noWaqfAssetsMutation = true;

  static const String nextAllowedExecutablePack =
      'platform_development_10b_owner_write_rpc_executable_candidate_pack';
}

/// Platform Development 10B: executable owner-write RPC implementation pack
/// has been prepared with SQL-level guards and Flutter write reroute behind
/// PWF_OWNER_WRITE_RPC_WRITE_REROUTE. Production remains blocked until post-apply
/// SQL UAT, Negative UAT, Browser Console evidence, and rollback evidence pass.
class PwfPlatformDevelopment10BOwnerWriteRpcImplementationDecision {
  const PwfPlatformDevelopment10BOwnerWriteRpcImplementationDecision._();

  static const batchKey =
      'platform_development_10b_owner_write_rpc_executable_pack';
  static const executableSqlBodiesProvided = true;
  static const flutterWriteRerouteBehindFlag = true;
  static const defaultWriteRerouteEnabled = false;
  static const productionApproved = false;
  static const noAuthUsersMigration = true;
  static const noWaqfAssetsMutation = true;
}

/// Platform Development 10D: SQL 06 anon revoke evidence accepted and
/// public placeholder image console hardening applied. Production remains
/// blocked pending browser console retest and Negative UAT.
class PwfPlatformDevelopment10DAnonRevokeConsoleHardeningDecision {
  const PwfPlatformDevelopment10DAnonRevokeConsoleHardeningDecision._();

  static const batchKey =
      'platform_development_10d_anon_revoke_console_hardening';
  static const anonBlockedAllOwnerWriteRpcs = true;
  static const authenticatedExecuteRetained = true;
  static const ownerWriteRpcsInstalled = true;
  static const placeholderExternalRequestDetectedBeforePatch = true;
  static const publicPlaceholderImageHardeningApplied = true;
  static const browserConsoleRetestRequired = true;
  static const negativeUatPending = true;
  static const productionApproved = false;
  static const noAuthUsersMigration = true;
  static const noFlutterServiceRole = true;
  static const noWaqfAssetsMutation = true;
}

/// Platform Development 10F: staging reroute evidence accepted, public route
/// console retest accepted, but Negative UAT actor bundle remains pending.
class PwfPlatformDevelopment10FNegativeUatGateDecision {
  const PwfPlatformDevelopment10FNegativeUatGateDecision._();

  static const batchKey = 'platform_development_10f_negative_uat_actor_bundle';
  static const anonBlockedAllOwnerWriteRpcs = true;
  static const flutterRerouteStagingStartupPassed = true;
  static const publicRouteConsoleCleanEvidenceAccepted = true;
  static const negativeUatActorBundlePassed = false;
  static const productionApproved = false;
  static const flutterWriteRerouteProductionEnabled = false;
  static const noAuthUsersMigration = true;
  static const noFlutterServiceRole = true;
  static const noWaqfAssetsMutation = true;
}

/// Platform Development 10H: actual negative UAT evidence bundle prepared.
/// This provides an executable evidence runner, not production approval.
class PwfPlatformDevelopment10HActualNegativeUatEvidenceDecision {
  const PwfPlatformDevelopment10HActualNegativeUatEvidenceDecision._();

  static const batchKey =
      'platform_development_10h_actual_negative_uat_evidence_bundle';
  static const actualEvidenceRunnerPrepared = true;
  static const anonymousDeniedEvidenceRequired = true;
  static const unauthorizedAuthenticatedDeniedEvidenceRequired = true;
  static const scopedUserDeniedEvidenceRequired = true;
  static const unitAdminDeniedEvidenceRequired = true;
  static const platformAdminEscalationDeniedEvidenceRequired = true;
  static const superuserSelfLockoutDeniedEvidenceRequired = true;
  static const adminWriteSurfaceConsoleCleanRequired = true;
  static const sqlRlsNoUnsafeMutationProofRequired = true;
  static const productionApproved = false;
  static const noAuthUsersMigration = true;
  static const noFlutterElevatedSecret = true;
  static const noWaqfAssetsMutation = true;
}

/// Platform Development 10I: actual Negative UAT runner evidence accepted.
/// This closes the six-actor denial runner gate but does not approve production.
class PwfPlatformDevelopment10IActualNegativeUatResultDecision {
  const PwfPlatformDevelopment10IActualNegativeUatResultDecision._();

  static const batchKey =
      'platform_development_10i_actual_negative_uat_runner_result_intake';
  static const actualNegativeUatRunnerExecuted = true;
  static const allRequiredActorCasesDenied = true;
  static const unsafeSuccessCount = 0;
  static const missingConfigCount = 0;

  static const anonymousDeniedAllOwnerWriteRpcs = true;
  static const unauthorizedAuthenticatedDenied = true;
  static const scopedUserOutOfScopeDenied = true;
  static const unitAdminPlatformWideWriteDenied = true;
  static const platformAdminPrivilegeEscalationDenied = true;
  static const superuserSelfLockoutDenied = true;

  static const sqlRlsNoUnsafeMutationProofAccepted = false;
  static const adminWriteSurfaceConsoleCleanAccepted = false;
  static const explicitProductionOwnerWriteRerouteApproval = false;
  static const productionApproved = false;

  static const noAuthUsersMigration = true;
  static const noFlutterElevatedSecret = true;
  static const noWaqfAssetsMutation = true;

  static const List<String> remainingProductionGateProofs = <String>[
    'SQL/RLS no unsafe mutation proof after runner execution',
    'admin/write-surface Browser Console clean evidence',
    'explicit production owner-write reroute approval',
  ];
}

/// Platform Development 10J-0A: site content adapter compile fix.
/// This closes the missing adapter constant compile blocker found during
/// admin/write-surface browser evidence collection. It is not production
/// approval and does not enable production owner-write reroute.
class PwfPlatformDevelopment10J0ASiteContentAdapterCompileFixDecision {
  const PwfPlatformDevelopment10J0ASiteContentAdapterCompileFixDecision._();

  static const batchKey =
      'platform_development_10j0a_site_content_adapter_compile_fix';
  static const sql17AuthBoundaryPartialAccepted = true;
  static const noAuthUsersMutationInSql17Partial = true;
  static const missingSiteContentAdapterConstantsFixed = true;
  static const affectedFilesCount = 3;
  static const flutterStartupRetestRequired = true;
  static const adminWriteSurfaceConsoleCleanAccepted = false;
  static const sqlRlsNoUnsafeMutationProofFullyAccepted = false;
  static const explicitProductionOwnerWriteRerouteApproval = false;
  static const productionApproved = false;

  static const noSqlProductionChange = true;
  static const noAuthUsersMigration = true;
  static const noFlutterElevatedSecret = true;
  static const noWaqfAssetsMutation = true;
}

/// Platform Development 10J-0B: analyzer cleanup after the site content
/// adapter compile fix. Analyzer cleanup only; production gate remains pending.
class PwfPlatformDevelopment10J0BAnalyzerCleanupDecision {
  const PwfPlatformDevelopment10J0BAnalyzerCleanupDecision._();

  static const batchKey = 'platform_development_10j0b_analyzer_cleanup';
  static const previousCompileBlockerClosed = true;
  static const analyzerIssuesBeforePatch = 4;
  static const analyzerCleanupApplied = true;
  static const flutterAnalyzeRetestRequired = true;
  static const flutterRunCompletionEvidenceRequired = true;
  static const adminWriteSurfaceConsoleCleanAccepted = false;
  static const sqlRlsNoUnsafeMutationProofFullyAccepted = false;
  static const productionApproved = false;

  static const noSqlProductionChange = true;
  static const noAuthUsersMigration = true;
  static const noFlutterElevatedSecret = true;
  static const noWaqfAssetsMutation = true;
}

/// Platform Development 10J-0C: access-profile RBAC 406 console fix.
/// Dashboard runtime evidence after 10J-0B proved analyzer/startup success,
/// but admin dashboard access-profile reads still emitted PostgREST 406 for
/// optional/direct dynamic RBAC surfaces. This patch removes those runtime
/// calls and derives dynamic access aliases from the already-safe public
/// compatibility wrappers.
class PwfPlatformDevelopment10J0CAccessProfileRbac406FixDecision {
  const PwfPlatformDevelopment10J0CAccessProfileRbac406FixDecision._();

  static const batchKey =
      'platform_development_10j0c_access_profile_rbac_406_console_fix';
  static const flutterPubGetPassed = true;
  static const flutterAnalyzeCleanAccepted = true;
  static const flutterEdgeStartupPassed = true;
  static const dashboardLoaded = true;
  static const browserConsole406Detected = true;
  static const directDynamicRbacPostgrestReadsRemoved = true;
  static const accessProfileUsesCompatibilityWrappersOnly = true;
  static const adminWriteSurfaceConsoleRetestRequired = true;
  static const fullSql17OutputStillRequired = true;
  static const adminWriteSurfaceConsoleCleanAccepted = false;
  static const sqlRlsNoUnsafeMutationProofFullyAccepted = false;
  static const explicitProductionOwnerWriteRerouteApproval = false;
  static const productionApproved = false;

  static const noSqlProductionChange = true;
  static const noAuthUsersMigration = true;
  static const noFlutterElevatedSecret = true;
  static const noWaqfAssetsMutation = true;
}

/// Platform Development 10J-0D: optional observability 404 console fix.
/// Dashboard runtime evidence after 10J-0C proved analyzer/startup success,
/// but optional user activity/session/audit REST probes emitted PostgREST 404
/// for legacy observability tables that are not part of the current approved
/// public compatibility surface. This patch disables those browser-side probes
/// until reviewed public audit/session wrappers are installed.
class PwfPlatformDevelopment10J0DObservability404FixDecision {
  const PwfPlatformDevelopment10J0DObservability404FixDecision._();

  static const batchKey =
      'platform_development_10j0d_observability_404_console_fix';
  static const previousAnalyzerCleanAccepted = true;
  static const previousEdgeStartupPassed = true;
  static const dashboardLoaded = true;
  static const browserConsole404Detected = true;
  static const affectedLegacyTables = <String>[
    'user_activity_logs',
    'activity_logs',
    'user_sessions',
    'admin_user_sessions',
    'audit_logs',
  ];
  static const directLegacyObservabilityRestProbesRemoved = true;
  static const repositoryDegradesToEmptyReadModel = true;
  static const serverSideOwnerWriteAuditPreserved = true;
  static const publicAuditWrapperStillRequiredForRuntimeDisplay = true;
  static const adminWriteSurfaceConsoleRetestRequired = true;
  static const fullSql17OutputStillRequired = true;
  static const adminWriteSurfaceConsoleCleanAccepted = false;
  static const sqlRlsNoUnsafeMutationProofFullyAccepted = false;
  static const explicitProductionOwnerWriteRerouteApproval = false;
  static const productionApproved = false;

  static const noSqlProductionChange = true;
  static const noAuthUsersMigration = true;
  static const noFlutterElevatedSecret = true;
  static const noWaqfAssetsMutation = true;
}

/// 10J-0E runtime console and layout hardening snapshot.
/// Keeps production blocked until retest evidence and full SQL17 proof are supplied.
class PwfPublicSchema10J0ERuntimeConsoleLayoutFixDecision {
  const PwfPublicSchema10J0ERuntimeConsoleLayoutFixDecision._();

  static const String batchKey =
      'platform_development_10j0e_runtime_console_usage_guide_layout_fix_2026_05_24';

  static const String decision =
      'RUNTIME_CONSOLE_LAYOUT_FIX_APPLIED_RETEST_REQUIRED_PRODUCTION_NOT_APPROVED';

  static const bool negativeUatRunnerPassedPreserved = true;
  static const bool analyzerCleanPreserved = true;
  static const bool edgeStartupPassedPreserved = true;
  static const bool usageGuideUnboundedFlexFixApplied = true;
  static const bool platformCenterOptionalRpcReadsDisabledByDefault = true;
  static const bool publicMediaGalleryLegacyFallbackDisabled = true;
  static const bool browserConsoleCleanEvidenceAccepted = false;
  static const bool fullSql17ProofAccepted = false;
  static const bool productionApproved = false;
  static const bool authUsersMigrated = false;
  static const bool flutterElevatedSecretUsed = false;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> retestTargets = [
    '/admin/dashboard',
    '/admin/usage-guide',
    'public pages using platform center content sections',
    'public pages using media gallery sections',
  ];
}

/// 10J-0G runtime layout hardening for Admin Home/Unit Surfaces management.
/// Retest evidence after 10J-0F showed analyzer clean and Edge startup passed,
/// but the home-management workspace still rendered fixed-height split panels
/// inside a finite viewport, causing RenderFlex overflow and cascading hit-test
/// assertions. This decision records a Flutter-only responsive split repair.
class PwfPublicSchema10J0GHomeManagementResponsiveSplitFixDecision {
  const PwfPublicSchema10J0GHomeManagementResponsiveSplitFixDecision._();

  static const String batchKey =
      'platform_development_10j0g_home_management_responsive_split_layout_fix_2026_05_25';

  static const String decision =
      'HOME_MANAGEMENT_RESPONSIVE_SPLIT_LAYOUT_FIX_APPLIED_RETEST_REQUIRED_PRODUCTION_NOT_APPROVED';

  static const bool negativeUatRunnerPassedPreserved = true;
  static const bool sql17NoUnsafeMutationProofAccepted = true;
  static const bool analyzerCleanPriorToFixAccepted = true;
  static const bool edgeStartupPassedPriorToFixAccepted = true;
  static const bool homeManagementRenderFlexOverflowDetected = true;
  static const bool responsiveSplitUsesFinitePanelHeights = true;
  static const bool narrowSplitUsesListViewInsteadOfOverflowingColumn = true;
  static const bool
  wideSplitAllowsVerticalScrollWhenPanelHeightExceedsViewport = true;
  static const bool browserConsoleCleanEvidenceAccepted = false;
  static const bool productionApproved = false;
  static const bool noSqlProductionChange = true;
  static const bool authUsersMigrated = false;
  static const bool flutterElevatedSecretUsed = false;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> retestTargets = [
    '/admin/home-management',
    '/admin/unit-surfaces-management',
    '/admin/system-surfaces-management',
    '/admin/dashboard',
    '/admin/usage-guide',
  ];
}

/// 10J-0H runtime layout hardening for Home Management finite constraints.
/// Retest evidence after 10J-0G showed the first overflow was reduced, but
/// the page still emitted cascading render assertions and hit-test failures
/// inside `/admin/home-management`. This Flutter-only patch removes flex from
/// unbounded home-management split panels and makes the section-order panel
/// internally scroll-safe.
class PwfPublicSchema10J0HHomeManagementFiniteConstraintsDecision {
  const PwfPublicSchema10J0HHomeManagementFiniteConstraintsDecision._();

  static const String batchKey =
      'platform_development_10j0h_home_management_finite_constraints_fix_2026_05_25';

  static const String decision =
      'HOME_MANAGEMENT_FINITE_CONSTRAINTS_FIX_APPLIED_RETEST_REQUIRED_PRODUCTION_NOT_APPROVED';

  static const bool negativeUatRunnerPassedPreserved = true;
  static const bool sql17NoUnsafeMutationProofAccepted = true;
  static const bool analyzerCleanPriorToFixAccepted = true;
  static const bool edgeStartupPassedPriorToFixAccepted = true;
  static const bool homeManagementResidualRenderAssertionsDetected = true;
  static const bool responsiveSplitUsesExplicitWidthsWithoutExpanded = true;
  static const bool narrowSplitUsesCustomScrollViewSlivers = true;
  static const bool sectionOrderPanelUsesInternalSingleChildScrollView = true;
  static const bool reorderableListUsesShrinkWrapInsideFinitePanel = true;
  static const bool browserConsoleCleanEvidenceAccepted = false;
  static const bool productionApproved = false;
  static const bool noSqlProductionChange = true;
  static const bool authUsersMigrated = false;
  static const bool flutterElevatedSecretUsed = false;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> retestTargets = [
    '/admin/home-management',
    '/admin/unit-surfaces-management',
    '/admin/system-surfaces-management',
    '/admin/dashboard',
    '/admin/usage-guide',
    '/home/contact',
  ];
}

/// 10J-0I runtime layout hardening for public platform-center cards.
/// Retest evidence after 10J-0H showed `/admin/home-management` was no
/// longer the first reported stack frame; the remaining unbounded flex source
/// moved to the public platform-center card renderer at
/// `pwf_platform_center_sections.dart:223`. This Flutter-only patch removes
/// flex from cards that are laid out inside Wrap/SingleChildScrollView.
class PwfPublicSchema10J0IPlatformCenterCardFiniteLayoutDecision {
  const PwfPublicSchema10J0IPlatformCenterCardFiniteLayoutDecision._();

  static const String batchKey =
      'platform_development_10j0i_platform_center_card_finite_layout_fix_2026_05_25';

  static const String decision =
      'PLATFORM_CENTER_CARD_FINITE_LAYOUT_FIX_APPLIED_RETEST_REQUIRED_PRODUCTION_NOT_APPROVED';

  static const bool negativeUatRunnerPassedPreserved = true;
  static const bool sql17NoUnsafeMutationProofAccepted = true;
  static const bool analyzerCleanPriorToFixAccepted = true;
  static const bool edgeStartupPassedPriorToFixAccepted = true;
  static const bool platformCenterCardUnboundedFlexDetected = true;
  static const bool centerCardExpandedDescriptionRemoved = true;
  static const bool centerCardUsesMainAxisSizeMin = true;
  static const bool centerCardDescriptionUsesBoundedEllipsis = true;
  static const bool browserConsoleCleanEvidenceAccepted = false;
  static const bool productionApproved = false;
  static const bool noSqlProductionChange = true;
  static const bool authUsersMigrated = false;
  static const bool flutterElevatedSecretUsed = false;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> retestTargets = [
    '/admin/home-management',
    '/admin/unit-surfaces-management',
    '/admin/system-surfaces-management',
    '/admin/dashboard',
    '/admin/usage-guide',
    '/home/contact',
    'public pages rendering platform-center sections',
  ];
}

/// 10J-0J dropdown menu finite-width hardening for admin surface selectors.
/// Retest evidence after 10J-0I moved the remaining first reported layout
/// blocker to `unit_surfaces_management_screen.dart:149`, where a DropdownMenu
/// item used a Row with flex children inside unbounded menu width constraints.
/// This Flutter-only patch bounds dropdown item rows and removes Expanded from
/// the selector menu item layout.
class PwfPublicSchema10J0JDropdownFiniteWidthDecision {
  const PwfPublicSchema10J0JDropdownFiniteWidthDecision._();

  static const String batchKey =
      'platform_development_10j0j_dropdown_finite_width_fix_2026_05_25';

  static const String decision =
      'DROPDOWN_FINITE_WIDTH_FIX_APPLIED_RETEST_REQUIRED_PRODUCTION_NOT_APPROVED';

  static const bool negativeUatRunnerPassedPreserved = true;
  static const bool sql17NoUnsafeMutationProofAccepted = true;
  static const bool unitSurfacesDropdownUnboundedRowDetected = true;
  static const bool dropdownItemsUseFiniteWidthConstrainedBox = true;
  static const bool dropdownItemsRemoveExpandedFromUnboundedRows = true;
  static const bool homeManagementSharedTargetDropdownAlsoHardened = true;
  static const bool browserConsoleCleanEvidenceAccepted = false;
  static const bool productionApproved = false;
  static const bool noSqlProductionChange = true;
  static const bool authUsersMigrated = false;
  static const bool flutterElevatedSecretUsed = false;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> retestTargets = [
    '/admin/home-management',
    '/admin/unit-surfaces-management',
    '/admin/system-surfaces-management',
    '/admin/dashboard',
    '/admin/usage-guide',
    '/home/contact',
  ];
}

/// 10J-0K visual unification for the public surface-management workspaces.
/// The screenshots supplied after 10J-0J showed that the home, unit, and
/// system surface management screens were operational but visually divergent:
/// different preview placement, control-panel proportions, and card shells.
/// This Flutter-only patch introduces a shared admin surface-management layout
/// contract and wires the three workspaces to the same two-panel pattern.
class PwfPublicSchema10J0KAdminSurfaceUnifiedLayoutDecision {
  const PwfPublicSchema10J0KAdminSurfaceUnifiedLayoutDecision._();

  static const String batchKey =
      'platform_development_10j0k_admin_surface_unified_layout_2026_05_25';

  static const String decision =
      'ADMIN_SURFACE_UNIFIED_LAYOUT_APPLIED_RETEST_REQUIRED_PRODUCTION_NOT_APPROVED';

  static const bool negativeUatRunnerPassedPreserved = true;
  static const bool sql17NoUnsafeMutationProofAccepted = true;
  static const bool threeSurfaceVisualDivergenceAccepted = true;
  static const bool sharedAdminSurfaceLayoutCreated = true;
  static const bool homeSurfaceUsesUnifiedPreviewFrame = true;
  static const bool unitSurfaceUsesUnifiedTwoPanelShell = true;
  static const bool systemSurfaceUsesUnifiedTwoPanelShell = true;
  static const bool browserConsoleCleanEvidenceAccepted = false;
  static const bool productionApproved = false;
  static const bool noSqlProductionChange = true;
  static const bool authUsersMigrated = false;
  static const bool flutterElevatedSecretUsed = false;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> unifiedSurfaceTargets = [
    '/admin/home-management',
    '/admin/unit-surfaces-management',
    '/admin/system-surfaces-management',
  ];

  static const List<String> retestTargets = [
    '/admin/home-management',
    '/admin/unit-surfaces-management',
    '/admin/system-surfaces-management',
    '/admin/dashboard',
    '/admin/usage-guide',
    '/home/contact',
  ];
}

/// 10J-0L compile and overflow stabilization after the unified admin-surface
/// layout retest. The submitted evidence showed analyzer regressions from an
/// orphan Awqaf apply-gate page with missing imports, plus runtime horizontal
/// overflows in the unit-pages execution screen. This patch provides a
/// compile-safe apply-gate shell and hardens narrow unit-page row cards.
class PwfPublicSchema10J0LCompileOverflowStabilizationDecision {
  const PwfPublicSchema10J0LCompileOverflowStabilizationDecision._();

  static const String batchKey =
      'platform_development_10j0l_compile_overflow_stabilization_2026_05_25';

  static const String decision =
      'COMPILE_OVERFLOW_STABILIZATION_APPLIED_RETEST_REQUIRED_PRODUCTION_NOT_APPROVED';

  static const bool negativeUatRunnerPassedPreserved = true;
  static const bool sql17NoUnsafeMutationProofAccepted = true;
  static const bool awqafApplyGateCompileShimApplied = true;
  static const bool unitPagesNarrowRowOverflowFixApplied = true;
  static const bool browserConsoleCleanEvidenceAccepted = false;
  static const bool productionApproved = false;
  static const bool noSqlProductionChange = true;
  static const bool authUsersMigrated = false;
  static const bool flutterElevatedSecretUsed = false;
  static const bool noWaqfAssetsMutation = true;
  static const bool noWaqfSchemaMutation = true;
  static const bool noAwqafSystemDatabaseMutation = true;

  static const List<String> retestTargets = [
    '/admin/home-management',
    '/admin/unit-surfaces-management',
    '/admin/system-surfaces-management',
    '/admin/unit-pages-execution',
    '/admin/dashboard',
    '/admin/usage-guide',
    '/home/contact',
  ];
}

/// 10J-0M overflow stabilization for platform-center governance pills and
/// unit-page execution row headers. Retest evidence after 10J-0L showed the
/// first remaining runtime overflow moved to `_Pill` in platform-center
/// sections and then to compact unit-page row cards. This Flutter-only patch
/// bounds pill labels and uses strict compact fallbacks for narrow row cards.
class PwfPublicSchema10J0MPillAndUnitRowOverflowDecision {
  const PwfPublicSchema10J0MPillAndUnitRowOverflowDecision._();

  static const String batchKey =
      'platform_development_10j0m_pill_unit_row_overflow_fix_2026_05_25';

  static const String decision =
      'PILL_UNIT_ROW_OVERFLOW_FIX_APPLIED_RETEST_REQUIRED_PRODUCTION_NOT_APPROVED';

  static const bool negativeUatRunnerPassedPreserved = true;
  static const bool sql17NoUnsafeMutationProofAccepted = true;
  static const bool platformCenterPillOverflowDetected = true;
  static const bool platformCenterPillsUseFiniteWidth = true;
  static const bool unitPageRowHeaderUsesCompactFallback = true;
  static const bool browserConsoleCleanEvidenceAccepted = false;
  static const bool productionApproved = false;
  static const bool noSqlProductionChange = true;
  static const bool authUsersMigrated = false;
  static const bool flutterElevatedSecretUsed = false;
  static const bool noWaqfAssetsMutation = true;
  static const bool noWaqfSchemaMutation = true;
  static const bool noAwqafSystemDatabaseMutation = true;

  static const List<String> retestTargets = [
    '/admin/home-management',
    '/admin/unit-surfaces-management',
    '/admin/system-surfaces-management',
    '/admin/unit-pages-execution',
    '/admin/dashboard',
    '/admin/usage-guide',
    '/home/contact',
  ];
}

/// Resulting governance marker for Platform Database Ownership Closure Master Pack.
class PwfPublicSchemaDatabaseOwnershipClosureMasterPackDecision {
  const PwfPublicSchemaDatabaseOwnershipClosureMasterPackDecision._();

  static const String batchKey =
      'platform_database_ownership_closure_master_pack_2026_05_25';
  static const String decision =
      'CONTROLLED_SCHEMA_OWNERSHIP_CLOSURE_MASTER_PACK_PREPARED_EXECUTION_PENDING';
  static const bool productionApproved = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool legacyPublicTablesDeleted = false;
  static const bool authUsersMigrated = false;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> requiredEvidenceBeforeClosure = [
    'SQL 00/01 inventory and owner mapping accepted',
    'SQL 05/06 dependency-zero evidence accepted',
    'RLS negative UAT accepted',
    'Flutter runtime repositories rerouted away from legacy public writes',
    'Browser console clean evidence for approved public/admin/system routes',
    'explicit governance approval before archive/delete/exact replacement',
  ];
}

/// Resulting governance marker for Database Ownership Closure result intake.
class PwfPublicSchemaDatabaseOwnershipResultIntakeDecision20260526 {
  const PwfPublicSchemaDatabaseOwnershipResultIntakeDecision20260526._();

  static const String batchKey =
      'platform_database_ownership_result_intake_dependency_zero_blocked_2026_05_26';
  static const String decision =
      'DATABASE_OWNERSHIP_RESULT_INTAKEN_DEPENDENCY_ZERO_BLOCKED_PRODUCTION_NOT_APPROVED';

  static const int databaseObjectCount = 409;
  static const int routineCount = 586;
  static const int flutterDirectLegacyDependencyCount = 502;
  static const bool dependencyZeroCertified = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool browserConsoleCleanAccepted = false;
  static const bool rlsNegativeUatAccepted = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;

  static const List<String> nextRequiredEvidence = [
    'reduce direct Flutter legacy public dependencies from 502 to accepted zero/equivalent governed exceptions',
    'prove owner schema/shadow targets and compatibility views/RPCs for each migrated family',
    'run actual negative RLS UAT for anonymous, unauthorized, wrong-unit, scoped, platform-admin, and superuser cases',
    'supply browser/console clean evidence after reroute',
    'obtain explicit backup and governance approval before archive/delete/exact public table replacement',
  ];
}

/// Public-schema governance marker for database ownership dependency reduction.
class PwfPublicSchemaDatabaseOwnershipDependencyReductionDecision20260526 {
  const PwfPublicSchemaDatabaseOwnershipDependencyReductionDecision20260526._();

  static const String batchKey =
      'platform_database_ownership_dependency_reduction_owner_wrapper_remediation_2026_05_26';
  static const String decision =
      'OWNER_WRAPPER_REMEDIATION_APPLIED_DEPENDENCY_ZERO_RETEST_REQUIRED';

  static const int intakeFlutterDirectLegacyDependencyCount = 502;
  static const int changedFlutterFileCount = 45;
  static const int centralizedSurfaceCount = 39;
  static const int remainingScannedDirectFromLiteralCount = 0;

  static const bool dependencyZeroCertified = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool browserConsoleCleanAccepted = false;
  static const bool rlsNegativeUatAccepted = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;
}

/// Public-schema governance marker for DB dependency retest classification.
class PwfPublicSchemaDatabaseOwnershipDependencyRetestClassifierDecision20260526 {
  const PwfPublicSchemaDatabaseOwnershipDependencyRetestClassifierDecision20260526._();

  static const String batchKey =
      'platform_database_ownership_dependency_retest_classifier_gate_2026_05_26';
  static const String decision =
      'DB_DEPENDENCIES_STILL_502_FLUTTER_LITERAL_SCAN_ZERO_CLASSIFICATION_REQUIRED';

  static const int dbPublicDependencyCount = 502;
  static const int remainingScannedDirectFromLiteralCount = 0;
  static const int centralizedSurfaceCount = 39;
  static const int changedFlutterFileCount = 45;

  static const bool flutterLiteralRemediationAccepted = true;
  static const bool dependencyZeroCertified = false;
  static const bool dbDependencyClassificationRequired = true;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool browserConsoleCleanAccepted = false;
  static const bool rlsNegativeUatAccepted = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;
}

/// Public-schema marker for SQL 15 aggregate classifier hotfix.
class PwfPublicSchemaDatabaseOwnershipClassifierAggregateHotfixDecision20260526 {
  const PwfPublicSchemaDatabaseOwnershipClassifierAggregateHotfixDecision20260526._();

  static const String batchKey =
      'platform_database_ownership_classifier_aggregate_hotfix_2026_05_26';
  static const String decision =
      'SQL_15A_AGGREGATE_FUNCTION_FILTER_APPLIED_CLASSIFIER_RETRY_REQUIRED';

  static const bool classifierSqlHotfixed = true;
  static const bool dependencyZeroCertified = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;
}

/// Public-schema marker for classifier output intake and Wave A planning.
class PwfPublicSchemaDatabaseOwnershipClassifierWaveADecision20260526 {
  const PwfPublicSchemaDatabaseOwnershipClassifierWaveADecision20260526._();

  static const String batchKey =
      'platform_database_ownership_classifier_result_intake_wave_a_plan_2026_05_26';
  static const String decision =
      'CLASSIFIER_OUTPUT_ACCEPTED_WAVE_A_REMEDIATION_PLANNING_REQUIRED';

  static const bool classifierOutputAccepted = true;
  static const bool dependencyZeroCertified = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;
}

/// Public-schema marker for DB Dependency Remediation Pack Wave A.
class PwfPublicSchemaDatabaseDependencyRemediationWaveADecision20260526 {
  const PwfPublicSchemaDatabaseDependencyRemediationWaveADecision20260526._();

  static const String batchKey =
      'platform_database_dependency_remediation_wave_a_consolidated_pack_2026_05_26';
  static const String decision =
      'WAVE_A_BUCKET_NORMALIZATION_ACCEPTED_EXECUTION_BLOCKED_PRODUCTION_NOT_APPROVED';

  static const bool raw502IsFlatBlocker = false;
  static const bool waveAPlanPrepared = true;
  static const bool dependencyZeroCertified = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;
}

/// Public-schema marker for SQL 21/22/23 result intake and Wave A exact body review.
class PwfPublicSchemaDatabaseDependencyWaveAResultIntakeExactBodyReviewDecision20260526 {
  const PwfPublicSchemaDatabaseDependencyWaveAResultIntakeExactBodyReviewDecision20260526._();

  static const String batchKey =
      'platform_database_dependency_wave_a_result_intake_exact_body_review_gate_2026_05_26';
  static const String decision =
      'WAVE_A_RESULTS_ACCEPTED_EXACT_BODY_REVIEW_REQUIRED_PRODUCTION_NOT_APPROVED';

  static const bool waveAResultsAccepted = true;
  static const bool raw502IsFlatBlocker = false;
  static const bool exactBodyReviewRequired = true;
  static const bool executionAuthorized = false;
  static const bool dependencyZeroCertified = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;
}

/// Public-schema marker for Wave A exact body export review intake.
class PwfPublicSchemaDatabaseDependencyWaveAExactBodyExportReviewDecision20260526 {
  const PwfPublicSchemaDatabaseDependencyWaveAExactBodyExportReviewDecision20260526._();

  static const String batchKey =
      'platform_database_dependency_wave_a_exact_body_export_review_intake_2026_05_26';
  static const String decision =
      'EXACT_BODY_EXPORT_REVIEW_INTAKEN_EXECUTION_BLOCKED_PRODUCTION_NOT_APPROVED';

  static const bool exactBodyExportSupplied = true;
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
}

/// Public-schema marker for SQL 29 core-relation parser hotfix.
class PwfPublicSchemaDatabaseDependencyWaveASql29CoreRelationHotfixDecision20260526 {
  const PwfPublicSchemaDatabaseDependencyWaveASql29CoreRelationHotfixDecision20260526._();

  static const String batchKey =
      'platform_database_dependency_wave_a_sql29_core_relation_hotfix_2026_05_26';
  static const String decision =
      'SQL29A_MATRIX_REWRITTEN_EXECUTION_BLOCKED_PRODUCTION_NOT_APPROVED';

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
}

/// Public-schema marker for SQL29B safe bypass path.
class PwfPublicSchemaDatabaseDependencyWaveASql29BSafeBypassDecision20260526 {
  const PwfPublicSchemaDatabaseDependencyWaveASql29BSafeBypassDecision20260526._();

  static const String batchKey =
      'platform_database_dependency_wave_a_sql29b_safe_bypass_2026_05_26';
  static const String decision =
      'SQL29_RETIRED_SQL33_34_35_SAFE_PATH_EXECUTION_BLOCKED_PRODUCTION_NOT_APPROVED';

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
}

/// Public-schema marker for SQL 36 access-helper preflight result intake.
class PwfPublicSchemaDatabaseDependencyWaveAAccessHelpersPreflightPassedDecision20260526 {
  const PwfPublicSchemaDatabaseDependencyWaveAAccessHelpersPreflightPassedDecision20260526._();

  static const String batchKey =
      'platform_database_dependency_wave_a_access_helpers_preflight_passed_intake_2026_05_26';
  static const String decision =
      'SQL36_PREFLIGHT_PASSED_EXECUTION_BLOCKED_PRODUCTION_NOT_APPROVED';

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
}

/// Public-schema marker for Database Ownership Wave A safe stop.
class PwfPublicSchemaDatabaseOwnershipWaveASafeStopDecision20260526 {
  const PwfPublicSchemaDatabaseOwnershipWaveASafeStopDecision20260526._();

  static const String batchKey =
      'platform_database_ownership_wave_a_safe_stop_architectural_redecision_2026_05_26';
  static const String decision =
      'PUBLIC_COMPATIBILITY_LAYER_ACCEPTED_ACCESS_HELPERS_DEFERRED_TO_AUTH_RBAC';

  static const bool publicCompatibilityLayerAccepted = true;
  static const bool dependencyZeroDeferred = true;
  static const bool accessHelperReplacementCancelled = true;
  static const bool authRbacMigrationRequiredForFutureAccessHelperRewrite =
      true;

  static const bool sql29DoNotRun = true;
  static const bool sql37DoNotRun = true;
  static const bool sql38To40DoNotRun = true;
  static const bool guardedSql02To04DoNotRun = true;

  static const bool executionAuthorized = false;
  static const bool dependencyZeroCertified = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;
}

/// Public-schema decision for Phase B Media Center closure.
class PwfPublicSchemaDatabaseOwnershipPhaseBMediaDecision20260526 {
  const PwfPublicSchemaDatabaseOwnershipPhaseBMediaDecision20260526._();

  static const String batchKey =
      'database_ownership_phase_b_media_center_controlled_ownership_closure_2026_05_26';
  static const String decision =
      'PUBLIC_MEDIA_COMPATIBILITY_SURFACE_PRESERVED_MEDIA_CENTER_OWNER_TARGET';

  static const bool publicMediaCompatibilityAccepted = true;
  static const bool legacyPublicMediaPreserved = true;
  static const bool mediaCenterOwnerSchemaTarget = true;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;
  static const bool noGisMutation = true;
}

/// Public-schema decision for Phase B Media Center Mega Closure Pack.
class PwfPublicSchemaDatabaseOwnershipPhaseBMediaMegaDecision20260528 {
  const PwfPublicSchemaDatabaseOwnershipPhaseBMediaMegaDecision20260528._();

  static const String batchKey =
      'database_ownership_phase_b_media_center_mega_closure_pack_2026_05_28';
  static const String decision =
      'PUBLIC_MEDIA_COMPATIBILITY_LAYER_PRESERVED_OWNER_MEDIA_CENTER_MEGA_PACK';

  static const bool publicCompatibilityLayerPreserved = true;
  static const bool legacyPublicMediaPreserved = true;
  static const bool ownerSchemaBackedCompatibilityViewsIncluded = true;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableReplacementAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool productionApproved = false;
  static const bool noAuthUsersMigration = true;
  static const bool noFlutterElevatedSecret = true;
  static const bool noWaqfAssetsMutation = true;
  static const bool noGisMutation = true;
}
