-- Platform Role Permission Map — Awqaf Assets Access Bridge
-- Authorized: platform_role_permission_map
--
-- Creates platform_access.platform_role_permission_map and seeds mappings
-- from platform roles to Awqaf asset permission codes.
--
-- Does NOT alter waqf.has_waqf_asset_permission_v1 by default.
-- Does NOT insert/update waqf.waqf_asset_rbac_assignments.
-- Does NOT grant SELECT on waqf.waqf_assets.
-- Does NOT change Flutter or Awqaf System files.

select
  'platform_role_permission_map_read_me_first' as section,
  'PLATFORM_ACCESS_MAPPING_DDL_DML_SEED' as execution_mode,
  true as ddl_authorized_for_mapping_table,
  true as dml_authorized_for_mapping_seed,
  false as waqf_function_change_authorized_in_default_apply,
  false as direct_waqf_assignment_change_authorized,
  false as waqf_assets_table_grant_authorized,
  false as awqaf_system_files_included,
  false as flutter_changes_included,
  false as production_approved,
  'Run 00-05 only. Do not run 90 unless separately authorized.' as instruction;
