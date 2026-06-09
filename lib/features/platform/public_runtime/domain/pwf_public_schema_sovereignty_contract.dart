/// Public Schema Sovereignty Inventory + Ownership Assignment Decision.
///
/// This contract is declarative. It does not perform migration, runtime routing,
/// archive, deletion, or database writes. It documents where public-owned objects
/// must move in later controlled migration packs.
class PwfPublicSchemaSovereigntyContract {
  static const String decision =
      'PUBLIC_SCHEMA_SOVEREIGNTY_INVENTORY_COMPLETE_OWNERSHIP_ASSIGNMENT_DECISION_ONLY';

  static const String publicRole = 'wrappers_rpc_views_aliases_only';
  static const bool migrationExecuted = false;
  static const bool destructiveSqlAuthorized = false;
  static const bool noWaqfAssetsMutation = true;

  static const Map<String, String> targetOwners = {
    'platform_pages_and_shell': 'platform',
    'users_profiles_and_org_linkage': 'core',
    'access_rbac_and_system_visibility': 'platform',
    'media_content': 'media_center',
    'services_catalog_and_requests': 'platform_services',
    'zakat_rules_and_config': 'zakat',
    'financial_payments_and_receipts': 'billing_system',
    'spatial_locations_geometry': 'gis',
    'authentication': 'auth',
    'public_exposure': 'public',
  };

  static const List<String> platformMigrationCandidates = [
    'public.homepage_sections',
    'public.header_settings',
    'public.footer_settings',
    'public.site_pages',
    'public.navigation_items',
    'public.theme_settings',
    'public.visual_identity_overrides',
    'public.platform_routes',
    'public.public_pages',
    'public.app_settings',
  ];

  static const List<String> coreMigrationCandidates = [
    'public.admin_users',
    'public.user_profiles',
    'public.profiles',
    'public.employees',
    'public.staff_profiles',
    'public.org_unit_users',
    'public.org_units_cache',
    'public.pwf_org_units_cache',
  ];

  static const List<String> platformAccessMigrationCandidates = [
    'public.roles',
    'public.permissions',
    'public.user_roles',
    'public.user_permissions',
    'public.user_system_roles',
    'public.user_system_permissions',
    'public.admin_permissions',
    'public.access_profiles',
    'public.system_roles',
  ];

  static const List<String> alreadyClosedOrQuarantinedFamilies = [
    'media_center owns media; public media tables are preserved/quarantined',
    'platform_services owns services; public service legacy tables are preserved/quarantined',
    'zakat owns Zakat rules/config; public exposes zakat wrappers only',
    'billing_system is financial owner; payment workflow remains disabled',
  ];

  static const List<String> nextAllowedActions = [
    'Run read-only public schema inventory SQL scripts 01-06',
    'Review ownership matrix and high-risk user/access objects',
    'Prepare controlled migration pack only after explicit approval',
    'Keep auth.users in Supabase auth; never migrate it',
    'Do not delete or archive legacy public tables without a dedicated Mega Batch',
  ];
}
