-- 01_PREFLIGHT_postgis_and_function_read_only.sql

select
  'postgis_extension_schema_probe' as section,
  e.extname,
  n.nspname as extension_schema,
  false as production_approved
from pg_extension e
join pg_namespace n on n.oid = e.extnamespace
where e.extname = 'postgis';

select
  'st_asgeojson_function_probe' as section,
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  false as production_approved
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where lower(p.proname) = 'st_asgeojson'
order by n.nspname, pg_get_function_identity_arguments(p.oid);

select
  'waqf_asset_geometries_geometry_columns_probe' as section,
  column_name,
  udt_schema,
  udt_name,
  data_type,
  false as production_approved
from information_schema.columns
where table_schema = 'waqf'
  and table_name = 'waqf_asset_geometries'
  and column_name in ('geom', 'centroid')
order by ordinal_position;

select
  'waqf_asset_detail_function_preflight_probe' as section,
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  p.prosecdef as security_definer,
  r.rolname as function_owner,
  p.proconfig as function_config,
  position('st_asgeojson(g.geom)' in lower(pg_get_functiondef(p.oid))) > 0 as has_unqualified_geom_call,
  position('extensions.st_asgeojson(g.geom)' in lower(pg_get_functiondef(p.oid))) > 0 as has_qualified_geom_call,
  false as production_approved
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
join pg_roles r on r.oid = p.proowner
where n.nspname = 'waqf'
  and p.proname = 'rpc_waqf_asset_detail_v1';
