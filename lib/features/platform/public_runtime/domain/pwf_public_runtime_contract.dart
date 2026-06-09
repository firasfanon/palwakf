/// Public platform runtime consolidation contract.
///
/// This file is intentionally declarative. It documents the runtime status of
/// the current public surfaces without executing migrations or changing route
/// guards. Future public mega batches should update this registry instead of
/// creating micro-patches for every screenshot/log intake.
class PwfPublicRuntimeSurface {
  final String key;
  final String routePattern;
  final String owner;
  final String readContract;
  final String runtimeStatus;
  final String productionGate;
  final List<String> uatChecks;

  const PwfPublicRuntimeSurface({
    required this.key,
    required this.routePattern,
    required this.owner,
    required this.readContract,
    required this.runtimeStatus,
    required this.productionGate,
    required this.uatChecks,
  });

  bool get isProductionApproved => productionGate == 'approved';
  bool get isStagingCandidate => runtimeStatus == 'staging-candidate';
  bool get isBlocked => runtimeStatus == 'blocked';
}

class PwfPublicRuntimeRegistry {
  static const String methodology =
      'mega-batches-only-after-b1a; micro-patches only for compile/sql/runtime blockers';

  static const List<PwfPublicRuntimeSurface> surfaces = [
    PwfPublicRuntimeSurface(
      key: 'public_home',
      routePattern: '/home',
      owner: 'site_content/public compatibility',
      readContract:
          'dynamic homepage sections + legacy-compatible public widgets',
      runtimeStatus: 'staging-candidate',
      productionGate: 'production-candidate-approved-not-deployed',
      uatChecks: [
        'home route opens',
        'hero and breaking news do not overflow',
        'public header/footer remain visible',
        'browser console review is clean',
      ],
    ),
    PwfPublicRuntimeSurface(
      key: 'public_news_list',
      routePattern: '/home/news',
      owner: 'media_center via public compatibility wrapper',
      readContract: 'public.v_media_news_compat_v1 with legacy fallback',
      runtimeStatus: 'staging-candidate',
      productionGate: 'production-candidate-approved-not-deployed',
      uatChecks: [
        'list route opens',
        'filters render',
        'at least one card opens detail',
        'browser console review is clean',
      ],
    ),
    PwfPublicRuntimeSurface(
      key: 'public_news_detail',
      routePattern: '/home/news/:id',
      owner: 'media_center via public compatibility wrapper',
      readContract: 'public.v_media_news_compat_v1 + detail resolver fallback',
      runtimeStatus: 'staging-candidate',
      productionGate: 'production-candidate-approved-not-deployed',
      uatChecks: [
        'detail route opens by stable id',
        'metadata and body render',
        'back/copy actions are available',
        'browser console review is clean',
      ],
    ),
    PwfPublicRuntimeSurface(
      key: 'public_announcements_list',
      routePattern: '/home/announcements',
      owner: 'media_center via public compatibility wrapper',
      readContract:
          'public.v_media_announcements_compat_v1 with legacy fallback',
      runtimeStatus: 'staging-candidate',
      productionGate: 'production-candidate-approved-not-deployed',
      uatChecks: [
        'list route opens',
        'priority filters render',
        'at least one card opens detail',
        'browser console review is clean',
      ],
    ),
    PwfPublicRuntimeSurface(
      key: 'public_announcements_detail',
      routePattern: '/home/announcements/:id',
      owner: 'media_center via public compatibility wrapper',
      readContract:
          'public.v_media_announcements_compat_v1 + stable family key resolver',
      runtimeStatus: 'staging-candidate',
      productionGate: 'production-candidate-approved-not-deployed',
      uatChecks: [
        'detail route opens by stable id',
        'loading does not persist',
        'metadata and validity render',
        'browser console review is clean',
      ],
    ),
    PwfPublicRuntimeSurface(
      key: 'public_services_catalog',
      routePattern: '/home/services',
      owner: 'platform_services via public compatibility wrapper',
      readContract: 'public.v_services_catalog_compat_v1',
      runtimeStatus: 'staging-candidate',
      productionGate: 'production-candidate-approved-not-deployed',
      uatChecks: [
        'catalog route opens',
        'service cards render from compatibility wrapper',
        'no servicepoints/serviceproviders reroute is assumed',
        'browser console review is clean',
      ],
    ),
    PwfPublicRuntimeSurface(
      key: 'public_press_releases',
      routePattern: '/home/press-releases',
      owner: 'platform_center public view contract',
      readContract:
          'public.v_platform_center_content published-only public read path',
      runtimeStatus: 'staging-candidate',
      productionGate: 'production-candidate-approved-not-deployed',
      uatChecks: [
        'press-releases route opens',
        'official data/cards render',
        'no header/footer singleton 406 appears',
        'browser console review is clean',
      ],
    ),
    PwfPublicRuntimeSurface(
      key: 'public_zakat',
      routePattern: '/home/zakat',
      owner: 'public religious-services shell',
      readContract:
          'local/runtime-safe calculation shell with platform header/footer',
      runtimeStatus: 'staging-candidate',
      productionGate: 'production-candidate-approved-not-deployed',
      uatChecks: [
        'zakat route opens',
        'calculator shell renders',
        'platform header/footer remain stable',
        'browser console review is clean',
      ],
    ),
    PwfPublicRuntimeSurface(
      key: 'public_activities',
      routePattern: '/home/activities',
      owner: 'legacy public.activities pending media_center mapping',
      readContract: 'legacy public.activities only',
      runtimeStatus: 'blocked',
      productionGate: 'blocked-zero-media-center-rows',
      uatChecks: [
        'do not reroute until media_center activity rows are present',
        'do not extract legacy public activities in this mega batch',
      ],
    ),
    PwfPublicRuntimeSurface(
      key: 'public_gallery',
      routePattern: '/home/gallery',
      owner: 'legacy public.media_gallery_items pending asset/content mapping',
      readContract: 'legacy gallery only',
      runtimeStatus: 'blocked',
      productionGate: 'blocked-asset-content-mapping-pending',
      uatChecks: [
        'do not reroute until gallery asset/content mapping is approved',
        'do not extract legacy public gallery in this mega batch',
      ],
    ),
  ];

  static Iterable<PwfPublicRuntimeSurface> get stagingCandidates =>
      surfaces.where((surface) => surface.isStagingCandidate);

  static Iterable<PwfPublicRuntimeSurface> get blocked =>
      surfaces.where((surface) => surface.isBlocked);

  static PwfPublicRuntimeSurface? byKey(String key) {
    for (final surface in surfaces) {
      if (surface.key == key) return surface;
    }
    return null;
  }
}

/// Public runtime UAT closure evidence captured after the public runtime
/// consolidation mega batch.
///
/// This is a declarative evidence snapshot, not a database migration and not a
/// production approval. It records the SQL UAT values submitted by the operator
/// so future mega batches can reason about service/media shell readiness without
/// reopening B-1A micro-patches.
class PwfPublicRuntimeClosureEvidence {
  static const String evidenceBatch =
      'mega_batch_public_runtime_uat_services_media_shell_closure_2026_05_21';

  static const int mediaNewsCompatRows = 93;
  static const int mediaAnnouncementsCompatRows = 90;
  static const int servicesCatalogCompatRows = 9;
  static const int homepageSectionsRows = 137;

  static const bool mediaContractsPresent = true;
  static const bool servicesCatalogContractPresent = true;
  static const bool homepageSectionsContractPresent = true;
  static const bool sovereignBoundaryPreserved = true;

  static const String mediaShellDecision =
      'media-news-announcements-staging-browser-uat-accepted-console-pending';
  static const String servicesShellDecision =
      'services-catalog-sql-contract-ready-browser-uat-pending';
  static const String productionGate = 'production-not-approved';
  static const String nextWorkPolicy =
      'mega-batch-only-unless-compile-sql-runtime-blocker';
}

/// Final public shell certification gate for homepage, services, news, and announcements.
///
/// This evidence gate deliberately does not approve production without submitted
/// browser click-through screenshots and clean console review for all listed
/// public routes. It is kept declarative so runtime code can inspect the current
/// shell status without changing routing, database ownership, or public data.
class PwfPublicRuntimeFinalShellCertification {
  static const String certificationBatch =
      'mega_batch_public_runtime_browser_console_uat_closure_homepage_services_final_shell_certification_2026_05_21';

  static const List<String> requiredRoutes = [
    '/home',
    '/home/news',
    '/home/news/1963512572',
    '/home/announcements',
    '/home/announcements/1295789704',
    '/home/services',
  ];

  static const bool sqlContractsAccepted = true;
  static const bool browserConsoleEvidenceSubmitted = true;
  static const bool homepageShellCertified = false;
  static const bool servicesShellCertified = false;
  static const bool mediaShellCertifiedForProduction = false;
  static const bool productionApproved = false;

  static const String certificationDecision =
      'final-shell-certification-deferred-console-errors-present';
  static const String nextRecommendedBatch =
      'mega_batch_public_runtime_console_error_hardening_asset_fallback_cleanup';

  static const bool browserRoutesDisplayed = true;
  static const bool consoleClean = false;
  static const bool consoleErrorsPresent = true;
  static const String consoleDecision =
      'console-clean-failed-external-assets-and-public-requests';
  static const List<String> consoleErrorFamilies = [
    'external-image-resource-404',
    'supabase-postgrest-400-406-public-runtime-requests',
    'site-pages-request-err-connection-closed',
  ];

  static bool get canApproveProduction =>
      sqlContractsAccepted &&
      browserConsoleEvidenceSubmitted &&
      homepageShellCertified &&
      servicesShellCertified &&
      mediaShellCertifiedForProduction;
}

/// Browser/Console evidence result submitted after the final shell certification gate.
///
/// Browser display passed for all required routes, but production remains blocked
/// because the submitted Console screenshots contain red errors.
class PwfPublicRuntimeBrowserConsoleEvidenceDecision {
  static const String evidenceBatch =
      'mega_batch_public_runtime_browser_console_evidence_intake_final_certification_decision_2026_05_21';

  static const bool homeDisplayed = true;
  static const bool newsListDisplayed = true;
  static const bool newsDetailDisplayed = true;
  static const bool announcementsListDisplayed = true;
  static const bool announcementsDetailDisplayed = true;
  static const bool servicesDisplayed = true;

  static const bool consoleClean = false;
  static const bool productionApproved = false;

  static const String decision =
      'final-shell-certification-deferred-console-errors-present';
  static const String nextRecommendedBatch =
      'mega_batch_public_runtime_console_error_hardening_asset_fallback_cleanup';
}

/// Console/Error hardening pack after Browser evidence showed red Console errors.
///
/// This is not a production approval. It records the applied mitigations and the
/// required retest scope after replacing unsafe external demo images and
/// suppressing optional `site_pages` public runtime lookups.
class PwfPublicRuntimeConsoleHardeningDecision {
  static const String hardeningBatch =
      'mega_batch_public_runtime_console_error_hardening_asset_fallback_cleanup_2026_05_21';

  static const bool externalUnsplashFallbackApplied = true;
  static const bool optionalSitePagesRuntimeLookupSuppressed = true;
  static const bool mediaAndServicesRuntimeContractsPreserved = true;
  static const bool productionApproved = false;

  static const String decision =
      'console-error-hardening-applied-browser-console-retest-required';
  static const String nextRecommendedBatch =
      'public_runtime_final_console_retest_result_intake_inside_next_mega_batch';
}

/// Root-cause console hardening, without disabling working public surfaces.
///
/// This decision keeps Header/Footer/Gallery/Platform Center sections alive,
/// but removes known red-console probes by aligning runtime reads with stable
/// public contracts:
/// - optional singleton settings use bounded maybe-single reads + local default;
/// - public platform-center strips read from public.v_platform_center_content
///   before any admin/RPC workflow surface;
/// - public gallery uses the legacy stable column contract until media assets
///   receive a governed media_center/content_assets migration.
class PwfPublicRuntimeConsoleRootCauseDecision {
  const PwfPublicRuntimeConsoleRootCauseDecision._();

  static const String decision =
      'root-cause-console-contract-fix-applied-without-disabling-public-surfaces';
  static const bool disablesHeaderFooter = false;
  static const bool disablesGallery = false;
  static const bool disablesPlatformCenterContent = false;
  static const bool requiresBrowserConsoleRetest = true;
  static const bool productionApproved = false;
}

/// Final grouped public-runtime shell decision after root-cause retest evidence.
///
/// This decision closes the public runtime shell loop as a production candidate
/// for the tested public surfaces. It is not a deployment action, does not
/// authorize Wave B-1B, and does not authorize public media extraction.
class PwfPublicRuntimeRootCauseRetestFinalDecision {
  const PwfPublicRuntimeRootCauseRetestFinalDecision._();

  static const String evidenceBatch =
      'mega_batch_public_runtime_root_cause_retest_evidence_final_shell_decision_2026_05_21';

  static const List<String> acceptedRoutes = [
    '/home/zakat',
    '/home',
    '/home/news',
    '/home/news/1963512572',
    '/home/announcements',
    '/home/announcements/1295789704',
    '/home/services',
    '/home/press-releases',
  ];

  static const bool browserRoutesDisplayed = true;
  static const bool consoleCleanForProvidedRoutes = true;
  static const bool finalShellCertificationAccepted = true;
  static const bool productionCandidateApproved = true;
  static const bool deployedToProduction = false;

  static const String decision =
      'public-runtime-production-candidate-approved-not-deployed';
  static const String boundary =
      'no-wave-b1b-no-public-media-extraction-no-locations-activation-no-waqf-assets-mutation';
}

/// Completion marker for the public platform runtime, media, and services shell.
///
/// The goal of this marker is to stop the public-runtime loop from blocking
/// other bounded systems. Future work should move to system-specific mega
/// batches unless a true compile, SQL, or runtime blocker is found in this shell.
class PwfPublicPlatformRuntimeCompletionDecision {
  const PwfPublicPlatformRuntimeCompletionDecision._();

  static const String completionBatch =
      'mega_batch_public_platform_runtime_completion_media_services_operational_hardening_2026_05_21';

  static const bool publicRuntimeShellClosedAsProductionCandidate = true;
  static const bool newsRuntimeCandidateAccepted = true;
  static const bool announcementsRuntimeCandidateAccepted = true;
  static const bool servicesCatalogRuntimeCandidateAccepted = true;
  static const bool pressReleasesRuntimeCandidateAccepted = true;
  static const bool zakatRuntimeCandidateAccepted = true;

  static const bool unblockOtherSystemsDevelopment = true;
  static const bool allowOnlyMegaBatchesAfterThisPoint = true;
  static const bool allowMicroPatchesOnlyForRealBlockers = true;

  static const bool waveB1bAuthorized = false;
  static const bool publicMediaExtractionAuthorized = false;
  static const bool locationsActivationAuthorized = false;
  static const bool activitiesGalleryRerouteAuthorized = false;
  static const bool waqfAssetsMutationAuthorized = false;
  static const bool productionDeploymentAuthorized = false;

  static const String finalDecision =
      'public-platform-runtime-completion-accepted-other-systems-unblocked';
  static const String nextRecommendedWork =
      'resume-high-value-bounded-system-mega-batches-awqaf-nosok-mustakshif-cases-billing';
}

/// Platform Data Ownership Stabilization Controlled Execution contract.
///
/// This decision is tied to the controlled execution pack and is intentionally
/// explicit: public remains a compatibility surface; media_center/platform_services/core/gis
/// remain the owners. Runtime reroute is allowed only through compatibility
/// wrappers and after grouped UAT.
class PwfPlatformDataOwnershipControlledExecutionDecision {
  static const String decision =
      'controlled-execution-runtime-reroute-uat-pack-prepared-user-sql-apply-required';
  static const String mediaOwner = 'media_center';
  static const String servicesOwner = 'platform_services';
  static const String orgUnitsOwner = 'core';
  static const String spatialOwner = 'gis';
  static const String publicRole = 'compatibility-views-rpc-wrappers-only';
  static const bool waqfAssetsMutationAllowed = false;
  static const bool legacyPublicDeletionAllowed = false;

  static const List<String> runtimeContracts = [
    'public.v_media_news_compat_v1',
    'public.v_media_announcements_compat_v1',
    'public.v_media_activities_compat_v1',
    'public.v_media_gallery_compat_v1',
    'public.v_locations_compat_v1',
    'public.rpc_locations_compat_v1',
    'public.v_services_catalog_compat_v1',
  ];
}

/// Canonical public route namespace decision.
///
/// Public pages are routed under `/home/*`. Root-level public paths remain
/// compatibility aliases only and should redirect to the canonical route without
/// changing data ownership, RBAC, or database contracts.
class PwfPublicRouteCanonicalizationDecision {
  const PwfPublicRouteCanonicalizationDecision._();

  static const String decisionBatch =
      'mega_batch_public_route_canonicalization_legacy_alias_navigation_contract_2026_05_22';
  static const String canonicalNamespace = '/home/*';
  static const String legacyAliasPolicy = 'root-public-routes-redirect-only';
  static const bool preservesLegacyLinks = true;
  static const bool changesDatabase = false;
  static const bool changesWaqfAssets = false;

  static const Map<String, String> canonicalExamples = {
    '/press-releases': '/home/press-releases',
    '/zakat': '/home/zakat',
    '/media': '/home/gallery',
    '/gallery': '/home/gallery',
    '/services': '/home/services',
  };

  static const List<String> requiredUatRoutes = [
    '/home',
    '/home/news',
    '/home/news/1963512572',
    '/home/announcements',
    '/home/announcements/1295789704',
    '/home/activities',
    '/home/gallery',
    '/home/services',
    '/home/press-releases',
    '/home/zakat',
  ];
}

/// Navigation-contract closure for the public chat route.
///
/// `/chat` remains a legacy alias only. The canonical public route is
/// `/home/chat` (or `/:unitSlug/chat` for unit-scoped public contexts). This
/// keeps the public-route namespace consistent with the `/home/*` contract
/// without disabling the existing chat page or breaking old links.
class PwfPublicChatRouteCanonicalizationDecision {
  const PwfPublicChatRouteCanonicalizationDecision._();

  static const String decision = 'public-chat-canonical-route-home-chat';
  static const String canonicalRoute = '/home/chat';
  static const String legacyAlias = '/chat';
  static const String legacyAliasMode = 'redirect-only';
  static const bool disablesChat = false;
  static const bool touchesDatabase = false;
  static const bool touchesWaqfAssets = false;
}

/// Public main pages inventory and PWF-SIS audit stage marker.
///
/// The detailed page registry is kept in
/// `pwf_public_main_pages_inventory_contract.dart`. This marker records the
/// governance rule: no public page should be treated as complete until it has a
/// canonical `/home/*` route, a PWF-SIS visual classification, an official data
/// source contract, and grouped Browser/Console evidence.
class PwfPublicMainPagesPwfSisAuditDecision {
  const PwfPublicMainPagesPwfSisAuditDecision._();

  static const String batch =
      'mega_batch_public_main_pages_pwf_sis_inventory_official_data_polish_2026_05_22';
  static const String decision =
      'comprehensive-inventory-and-polish-contract-created-execution-pending-audit-results';
  static const bool mutatesDatabase = false;
  static const bool mutatesWaqfAssets = false;
  static const bool disablesWorkingPages = false;
  static const bool requiresOfficialDataSourceForEveryPage = true;
  static const bool requiresPwfSisVisualTemplateForEveryPage = true;
  static const bool allowsMicroPatchLoop = false;

  static const List<String> mandatoryAuditAxes = [
    'canonical_route_under_home_namespace',
    'official_data_owner_and_public_wrapper',
    'pwf_sis_visual_template_family',
    'rtl_responsive_overflow_console_clean',
    'hardcoded_or_demo_data_rejection',
  ];
}

class PwfPublicMainPagesPwfSisPolishExecutionDecision {
  const PwfPublicMainPagesPwfSisPolishExecutionDecision._();

  static const String batch =
      'mega_batch_public_main_pages_pwf_sis_polish_official_data_binding_execution_2026_05_22';
  static const String decision =
      'public-main-pages-pwf-sis-polish-executed-official-data-binding-added-browser-uat-required';
  static const String routeNamespace =
      '/home/* canonical; root routes aliases only';
  static const String officialDataRule =
      'display official source contract on tool pages; do not certify pages with source gaps as complete';
  static const List<String> certifiedDataCandidates = [
    '/home',
    '/home/news',
    '/home/news/:id',
    '/home/announcements',
    '/home/announcements/:id',
    '/home/activities',
    '/home/services',
    '/home/press-releases',
  ];
  static const List<String> guardedNotComplete = [
    '/home/gallery',
    '/home/zakat',
    '/home/chat',
  ];
}

/// Browser/Console evidence closure for the public main pages PWF-SIS polish.
///
/// This decision is evidence-only. It records that analyzer and Chrome startup
/// passed locally and that the provided Browser/Console screenshots showed the
/// main public routes working without visible red Console errors. It also keeps
/// `/home/zakat` out of full visual certification because the user explicitly
/// observed that its layout still differs from the PWF-SIS public page family.
class PwfPublicMainPagesPwfSisPolishEvidenceClosureDecision {
  const PwfPublicMainPagesPwfSisPolishEvidenceClosureDecision._();

  static const String batch =
      'mega_batch_public_main_pages_pwf_sis_polish_browser_console_uat_evidence_closure_2026_05_22';
  static const String decision =
      'runtime-certification-accepted-with-zakat-visual-gap';
  static const String analyzerEvidence = 'flutter-analyze-no-issues-found';
  static const String chromeEvidence =
      'chrome-startup-passed-supabase-visual-identity-loaded';
  static const String certificationScope =
      'public-main-pages-browser-console-runtime-evidence; not production deployment';
  static const bool mutatesDatabase = false;
  static const bool mutatesFlutterRuntime = false;
  static const bool touchesWaqfAssets = false;
  static const bool productionApproved = false;
  static const bool runtimeCertificationAccepted = true;
  static const bool fullPwfSisVisualCertificationAccepted = false;
  static const String remainingVisualGap = '/home/zakat';

  static const List<String> acceptedRuntimeRoutes = [
    '/home',
    '/home/news',
    '/home/news/:id',
    '/home/announcements',
    '/home/announcements/:id',
    '/home/activities',
    '/home/gallery',
    '/home/services',
    '/home/press-releases',
    '/home/chat',
    '/home/zakat',
  ];

  static const List<String> guardedVisualRoutes = ['/home/zakat'];
}

class PwfZakatPublicPagePwfSisVisualHarmonizationDecision {
  static const String batch =
      'mega_batch_zakat_public_page_pwf_sis_visual_harmonization_official_config_contract_2026_05_22';
  static const String decision =
      'zakat-public-page-visual-harmonized-official-config-contract-declared-browser-uat-required';
  static const String canonicalRoute = '/home/zakat';
  static const bool noSqlProductionChange = true;
  static const bool noWaqfAssetsMutation = true;
}

/// Evidence intake decision for the Zakat PWF-SIS visual harmonization UAT.
/// This does not approve production deployment; it accepts staging runtime/browser
/// evidence and leaves the dedicated official config wrapper as a production guard.
class PwfZakatPublicPagePwfSisVisualHarmonizationUatDecision {
  const PwfZakatPublicPagePwfSisVisualHarmonizationUatDecision._();

  static const String batch =
      'mega_batch_zakat_public_page_pwf_sis_visual_harmonization_uat_result_intake_official_config_gate_decision_2026_05_22';
  static const String decision =
      'final-zakat-runtime-visual-certification-accepted-with-config-wrapper-pending';
  static const String canonicalRoute = '/home/zakat';
  static const bool analyzerClean = true;
  static const bool chromeStartupPassed = true;
  static const bool browserConsoleEvidenceAccepted = true;
  static const bool visualGapClosedForRuntime = true;
  static const bool productionApproved = false;
  static const bool noSqlProductionChange = true;
  static const bool noWaqfAssetsMutation = true;
  static const String remainingProductionGuard =
      'dedicated-zakat-official-config-wrapper-or-rpc-required';
}

class ZakatOfficialConfigWrapperProductionDecision {
  const ZakatOfficialConfigWrapperProductionDecision._();

  static const String decision =
      'zakat-official-config-wrapper-prepared-production-content-certification-pending-sql-browser-uat';
  static const String canonicalRoute = '/home/zakat';
  static const String officialSource = 'public.v_zakat_public_config_v1';
  static const String owner = 'zakat';
  static const bool flutterRuntimeBindingPrepared = true;
  static const bool sqlApplyRequired = true;
  static const bool productionApprovalGranted = false;
  static const bool noWaqfAssetsMutation = true;
}

class PwfZakatDomainOwnershipRealignmentDecision {
  const PwfZakatDomainOwnershipRealignmentDecision._();

  static const String batch =
      'mega_batch_zakat_domain_ownership_realignment_billing_integration_contract_2026_05_22';
  static const String decision =
      'zakat-schema-operational-owner-billing-system-financial-owner-public-wrapper-only';
  static const bool previousPlatformServicesConfigOwnerSuperseded = true;
  static const bool flutterReadsPublicWrapperOnly = true;
  static const bool paymentWorkflowImplemented = false;
  static const bool waqfAssetsMutation = false;
  static const List<String> ownership = [
    'zakat: operational configuration, nisab, rates, guidance, campaigns',
    'billing_system: payment intents, receipts, transactions, receivables',
    'platform_services: public service/request interface only',
    'public: views/RPC wrappers only',
  ];
}

/// Contract-only bootstrap for the financial system namespace.
/// This class deliberately does not enable payment processing. It only records
/// that billing_system is the future financial owner and exposes the Zakat
/// readiness bridge as a non-transactional contract.
class PwfBillingSystemFinancialContractBootstrapDecision {
  const PwfBillingSystemFinancialContractBootstrapDecision._();

  static const String batch =
      'mega_batch_billing_system_financial_contract_bootstrap_zakat_payment_readiness_only_2026_05_22';
  static const String decision =
      'billing-system-financial-contract-bootstrap-prepared-zakat-payment-readiness-only';
  static const String ownerSchema = 'billing_system';
  static const String zakatOperationalOwner = 'zakat';
  static const String publicReadinessView =
      'public.v_billing_zakat_payment_readiness_v1';
  static const String publicReadinessRpc =
      'public.rpc_billing_zakat_payment_readiness_v1()';
  static const bool paymentWorkflowImplemented = false;
  static const bool paymentGatewayEnabled = false;
  static const bool receiptIssuanceEnabled = false;
  static const bool transactionPostingEnabled = false;
  static const bool productionFinancialApprovalGranted = false;
  static const bool flutterRuntimeMutation = false;
  static const bool noWaqfAssetsMutation = true;
  static const List<String> allowedScope = [
    'create billing_system schema if missing',
    'declare non-transactional payment-intent and receipt contracts',
    'declare Zakat payment readiness bridge',
    'publish public read-only wrappers for readiness only',
  ];
  static const List<String> prohibitedScope = [
    'no real payment gateway integration',
    'no receipt issuance',
    'no transaction ledger posting',
    'no refund or settlement workflow',
    'no production financial approval',
  ];
}

/// Final ownership closure decision for Media Center and Services Center.
/// This is a contract-only declaration. It does not delete legacy public tables
/// and does not authorize destructive SQL. Runtime should depend on public
/// compatibility wrappers, while ownership remains with media_center and
/// platform_services.
class PwfMediaServicesOwnershipFinalClosureDecision {
  const PwfMediaServicesOwnershipFinalClosureDecision._();

  static const String batch =
      'mega_batch_media_services_data_ownership_final_closure_legacy_quarantine_decision_2026_05_22';
  static const String decision =
      'MEDIA_SERVICES_OWNERSHIP_FINAL_CLOSURE_ACCEPTED_WITH_LEGACY_QUARANTINE_NO_DELETE';
  static const String mediaOwner = 'media_center';
  static const String servicesOwner = 'platform_services';
  static const String publicRole = 'compatibility_views_rpc_wrappers_only';
  static const bool legacyTablesDeleted = false;
  static const bool publicMediaExtractionPerformed = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool noWaqfAssetsMutation = true;
  static const List<String> canonicalMediaWrappers = [
    'public.v_media_content_compat_v1',
    'public.v_media_news_compat_v1',
    'public.v_media_announcements_compat_v1',
    'public.v_media_activities_compat_v1',
    'public.v_media_gallery_compat_v1',
    'public.rpc_media_content_compat_v1(...)',
  ];
  static const List<String> canonicalServicesWrappers = [
    'public.v_services_catalog_compat_v1',
  ];
  static const List<String> quarantinedLegacyTables = [
    'public.news_articles',
    'public.announcements',
    'public.activities',
    'public.media_gallery_items',
    'public.services',
    'public.servicepoints',
    'public.serviceproviders',
    'public.servicetypes',
  ];
  static const List<String> pendingOnlyWhenRowsAppear = [
    'gallery/content_assets mapping remains empty-certified until public/media asset rows exist',
    'legacy deletion/archive requires a separate explicit approval',
  ];
}

/// Public Schema Sovereignty Inventory decision.
class PwfPublicSchemaSovereigntyDecision {
  static const String decision =
      'PUBLIC_SCHEMA_SOVEREIGNTY_INVENTORY_COMPLETE_OWNERSHIP_ASSIGNMENT_DECISION_ONLY';
  static const String publicRole = 'wrappers_rpc_views_aliases_only';
  static const bool migrationExecuted = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool noWaqfAssetsMutation = true;
  static const List<String> targetOwnerRules = [
    'platform pages/settings/navigation/theme/site_pages -> platform',
    'user profile and administrative linkage -> core; auth.users remains auth source',
    'roles/permissions/RBAC/system visibility -> platform governance',
    'media -> media_center; public wrappers only',
    'services -> platform_services; public wrappers only',
    'zakat -> zakat; public wrappers only',
    'billing -> billing_system readiness/payment owner; public readiness wrappers only',
  ];
}

/// Controlled migration decision for the public schema ownership cleanup.
///
/// This records that the migration pack creates owner-schema shadow tables and
/// public compatibility wrappers, while preserving all legacy public tables.
/// It does not replace old table names and does not approve archive/delete.
class PwfPublicSchemaControlledOwnershipMigrationDecision {
  const PwfPublicSchemaControlledOwnershipMigrationDecision._();

  static const String batch =
      'mega_batch_public_schema_controlled_ownership_migration_compatibility_wrappers_2026_05_22';
  static const String decision =
      'CONTROLLED_OWNER_SHADOW_MIGRATION_DEPENDENCY_ANALYZER_BROWSER_UAT_GATE_ADDED';
  static const String publicRole = 'wrappers_rpc_views_aliases_only';
  static const bool sqlExecutedByAssistant = false;
  static const bool legacyDeleteAuthorized = false;
  static const bool exactPublicTableReplacementPerformed = false;
  static const bool authUsersMigrated = false;
  static const bool noWaqfAssetsMutation = true;
  static const List<String> targetOwners = [
    'platform shell/settings/access -> platform',
    'admin/user/org linkage -> core, auth.users remains auth source',
    'assistant/chat -> assistant',
    'media -> media_center, services -> platform_services',
    'zakat -> zakat, billing readiness -> billing_system',
  ];
  static const List<String> certificationGuards = [
    'SQL dependency inventory result intake required',
    'SQL runtime certification gate must report zero blockers',
    'Flutter dependency/analyzer evidence required before replacing public table names',
    'Browser/console UAT evidence required before runtime certification',
    'legacy archive/delete requires a later explicit Mega Batch',
    'production approval is not granted by this pack',
  ];
}

/// Runtime gate added after the owner-shadow migration result intake.
class PwfPublicSchemaControlledMigrationRuntimeCertificationGateDecision {
  const PwfPublicSchemaControlledMigrationRuntimeCertificationGateDecision._();

  static const String batch =
      'mega_batch_public_schema_controlled_migration_dependency_analyzer_browser_uat_runtime_certification_gate_2026_05_22';
  static const String decision =
      'PUBLIC_SCHEMA_RUNTIME_CERTIFICATION_GATE_ADDED_DEPENDENCY_ZERO_NOT_YET_CERTIFIED';
  static const bool dependencyZeroCertified = false;
  static const bool browserUatAccepted = false;
  static const bool analyzerAccepted = false;
  static const bool productionApproved = false;
  static const bool legacyPublicTablesPreserved = true;
  static const bool destructiveSqlAuthorized = false;
  static const bool exactPublicTableNameReplacementPerformed = false;
  static const bool noWaqfAssetsMutation = true;
  static const List<String> requiredEvidence = [
    'SQL 01 dependency surface inventory',
    'SQL 02 runtime certification gate decision',
    'SQL 03 browser/role/console matrix',
    'flutter analyze local result',
    'flutter run -d chrome startup result',
    'browser console screenshots/logs for public/admin routes',
  ];
}
