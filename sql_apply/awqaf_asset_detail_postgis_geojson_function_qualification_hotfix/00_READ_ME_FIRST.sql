-- Awqaf Asset Detail — PostGIS GeoJSON Function Qualification Hotfix
--
-- Authorization:
--   Awqaf Asset Detail — PostGIS GeoJSON Function Qualification Hotfix
--
-- Confirmed evidence:
--   postgis extension schema = extensions
--   st_asgeojson functions are in schema extensions
--   waqf_asset_geometries.geom/centroid udt_schema = extensions
--
-- Error:
--   ERROR 42883: function st_asgeojson(extensions.geometry) does not exist
--
-- Cause:
--   waqf.rpc_waqf_asset_detail_v1 is SECURITY DEFINER with search_path:
--     waqf, public, auth
--   but it calls unqualified st_asgeojson(...)
--
-- Fix:
--   Qualify PostGIS calls as:
--     extensions.st_asgeojson(g.geom)
--     extensions.st_asgeojson(g.centroid)
--
-- This pack DOES:
--   - CREATE OR REPLACE FUNCTION waqf.rpc_waqf_asset_detail_v1(uuid) only
--   - keep SECURITY DEFINER and stable function behavior
--   - keep RBAC check unchanged
--   - run authenticated smoke through public.rpc_waqf_asset_detail_v1
--
-- This pack DOES NOT:
--   - run DML
--   - change RBAC assignments
--   - grant SELECT on waqf.waqf_assets
--   - mutate waqf.waqf_assets
--   - add Flutter or Awqaf System files
--   - approve production

select
  'awqaf_asset_detail_postgis_geojson_qualification_read_me_first' as section,
  'SINGLE_FUNCTION_DDL_HOTFIX' as execution_mode,
  true as ddl_authorized_for_waqf_rpc_asset_detail_only,
  false as dml_authorized,
  false as rbac_change_authorized,
  false as waqf_assets_table_grant_authorized,
  false as waqf_assets_mutation_authorized,
  false as awqaf_system_files_included,
  false as flutter_changes_included,
  false as production_approved,
  'Run 00-04. Do not run 98 rollback unless explicitly needed.' as instruction;
