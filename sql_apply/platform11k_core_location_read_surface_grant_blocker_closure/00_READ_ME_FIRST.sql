-- Platform 11K — Core Location Read Surface Grant Blocker Closure
-- Scope: Platform-only read grant/security correction.
-- No DML. No Flutter. No Awqaf System files. No public.locations recreate.
-- No gis.locations_boundary. No waqf.waqf_assets mutation. No production approval.

select
  'platform11k_core_location_grant_blocker_read_me_first' as section,
  'PLATFORM_ONLY_GRANT_SECURITY_CORRECTION' as execution_mode,
  true as grant_revoke_authorized_for_listed_surfaces_only,
  false as dml_authorized,
  false as ddl_table_view_function_recreation_authorized,
  false as public_locations_recreate_authorized,
  false as gis_locations_boundary_create_authorized,
  false as waqf_assets_mutation_authorized,
  false as awqaf_system_files_included,
  false as flutter_changes_included,
  false as rpc_wrapper_switch_authorized,
  false as production_approved,
  'Run 00-06. Do not run 99 unless separately authorized by owner review.' as instruction;
