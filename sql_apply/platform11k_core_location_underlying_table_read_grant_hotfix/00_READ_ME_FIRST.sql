-- Platform 11K — Core Location Underlying Table Read Grant Hotfix
--
-- Trigger:
--   ERROR 42501: permission denied for table core_locations
--   HINT: GRANT SELECT ON core.core_locations TO authenticated;
--
-- Meaning:
--   The RPC/view path is still evaluated under authenticated/invoker privileges.
--   Granting SELECT on the exposed views was not enough; the underlying base tables
--   used by those views also require read access unless the RPCs/views are converted
--   to a reviewed SECURITY DEFINER pattern.
--
-- This pack only prepares least-privilege READ grants on exact underlying surfaces.
--
-- Does NOT:
--   - INSERT/UPDATE/DELETE
--   - add Flutter code
--   - add Awqaf System files
--   - recreate public.locations
--   - create gis.locations_boundary
--   - mutate waqf.waqf_assets
--   - switch RPC wrappers
--   - approve production

select
  'platform11k_core_location_underlying_table_read_grant_hotfix_read_me_first' as section,
  'PLATFORM_ONLY_UNDERLYING_READ_GRANT_HOTFIX' as execution_mode,
  true as grant_revoke_authorized_for_exact_underlying_read_surfaces_only,
  false as dml_authorized,
  false as ddl_table_view_function_recreation_authorized,
  false as public_locations_recreate_authorized,
  false as gis_locations_boundary_create_authorized,
  false as waqf_assets_mutation_authorized,
  false as awqaf_system_files_included,
  false as flutter_changes_included,
  false as rpc_wrapper_switch_authorized,
  false as production_approved,
  'Run 00-05. This hotfix grants SELECT on core.core_locations and related underlying read surfaces only.' as instruction;
