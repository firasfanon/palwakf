/// Service Center Browser UAT route-alias and hero switcher hotfix contract.
///
/// This contract records the narrow runtime fixes applied after Service Center
/// UAT screenshots on 2026-05-31. It is intentionally declarative: no SQL,
/// Supabase client, service-role usage, or runtime mutation is introduced here.
class PwfServiceCenterBrowserUatRouteAliasHotfixContract {
  const PwfServiceCenterBrowserUatRouteAliasHotfixContract._();

  static const String batchKey =
      'service-center-browser-uat-route-alias-hero-switcher-hotfix-2026-05-31';

  static const String decision =
      'service-center-browser-uat-partial-accepted-route-alias-and-hero-switcher-hotfix-applied';

  static const List<String> acceptedEvidence = <String>[
    'admin-surfaces-services-opened',
    'admin-request-queue-rpc-backed-visual-evidence',
    'admin-forms-registry-rpc-backed-visual-evidence',
    'home-hero-overflow-remained-closed',
    'public-services-and-media-root-cutover-markers-preserved',
  ];

  static const List<String> fixedRuntimeFindings = <String>[
    'animatedswitcher-duplicate-key-from-reused-hero-image-url',
    'home-request-service-legacy-alias-gap',
    'home-service-request-tracking-legacy-alias-gap',
    'home-service-request-traking-defensive-typo-alias-gap',
  ];

  static const List<String> preservedBoundaries = <String>[
    'no-sql-production',
    'no-ddl-dml-grant-drop',
    'no-service-role-in-flutter',
    'no-platform-services-direct-table-write',
    'no-public-legacy-delete-or-archive',
    'no-waqf-waqf-assets-awqaf-system-gis-mutation',
    'production-not-approved',
  ];

  static const List<String> retestRoutes = <String>[
    '#/home/services/request',
    '#/home/request-service',
    '#/home/services/track',
    '#/home/service-request-tracking',
    '#/admin/surfaces-services',
    '#/admin/surfaces-services/request-queue',
    '#/admin/surfaces-services/forms-registry',
  ];
}
