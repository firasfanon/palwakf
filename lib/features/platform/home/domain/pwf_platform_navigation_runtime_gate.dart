/// PalWakf Platform Navigation runtime gate.
///
/// Root cutover decision — 2026-05-30:
/// `platform_navigation` owner-read wrappers are now the default runtime read
/// source for public services/home-services in staging. Legacy public surfaces
/// remain preserved and are used only as fallback/rollback surfaces.
class PwfPlatformNavigationRuntimeGate {
  const PwfPlatformNavigationRuntimeGate._();

  static const String batchKey =
      'public_services_runtime_source_root_cutover_2026_05_30';

  static const String sourceCertificationPatchKey =
      'runtime_source_certification_400_root_fix_2026_05_29';

  static const String legacyCompatibilityRepairPatchKey =
      'public_services_legacy_compatibility_repair_2026_05_30';

  static const String routeAliasCanonicalizationPatchKey =
      'public_services_route_alias_canonicalization_repair_2026_05_30';

  /// Emergency rollback only.
  ///
  /// Normal staging runtime uses platform_navigation owner-read wrappers by
  /// default. Operators may force the preserved legacy public compatibility
  /// path only for diagnosis/rollback with:
  /// `--dart-define=PWF_FORCE_LEGACY_PUBLIC_SERVICES=true`.
  static const bool forceLegacyPublicServices = bool.fromEnvironment(
    'PWF_FORCE_LEGACY_PUBLIC_SERVICES',
    defaultValue: false,
  );

  /// Backward-compatible name retained for existing callers.
  ///
  /// Root cutover flips the default from opt-in owner-read to default
  /// owner-read. The old `PWF_ENABLE_PLATFORM_NAVIGATION_OWNER_READS` flag is
  /// therefore no longer required for normal runtime.
  static const bool ownerReadAdapterEnabled = !forceLegacyPublicServices;

  static const bool ownerReadDefaultCutoverEnabled = true;
  static const bool legacyPublicServicesFallbackOnly = true;

  static const bool destructiveSqlAuthorized = false;
  static const bool archiveDeleteAuthorized = false;
  static const bool productionApproved = false;
  static const bool publicLegacyMutationAuthorized = false;
  static const bool waqfMutationAuthorized = false;
  static const bool awqafSystemMutationAuthorized = false;
  static const bool gisMutationAuthorized = false;

  static String get runtimeReadSourceDecision => forceLegacyPublicServices
      ? 'legacy-public-services-forced-by-emergency-dart-define'
      : 'platform-navigation-owner-read-default-root-cutover';

  static String get legacyCompatibilityDecision => forceLegacyPublicServices
      ? 'legacy-compat-forced-for-diagnostic-rollback'
      : 'legacy-compat-fallback-only-after-owner-read-failure-or-empty-result';

  static String get servicesCatalogSurface => forceLegacyPublicServices
      ? 'public.v_services_catalog_compat_v1'
      : 'public.v_platform_navigation_services_catalog_from_owner_v1';

  static String get homeServicesSurface => forceLegacyPublicServices
      ? 'footer_settings.services_links + static fallback'
      : 'public.v_platform_navigation_home_services_from_owner_v1';
}

// Root cutover note — 2026-05-30:
// The platform_navigation owner wrappers were certified by browser/console
// evidence. This patch removes legacy services compatibility from the default
// runtime path without deleting, archiving, or mutating public.services or
// public.home_services. Production approval remains deferred.
