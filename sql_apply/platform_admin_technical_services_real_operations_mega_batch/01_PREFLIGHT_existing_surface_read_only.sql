-- 01_PREFLIGHT_existing_surface_read_only.sql

select
  'platform_technical_preflight' as section,
  to_regnamespace('platform_technical') is not null as platform_technical_schema_exists,
  to_regclass('public.admin_users') is not null as public_admin_users_exists,
  to_regclass('platform_access.platform_role_permission_map') is not null as platform_role_permission_map_exists,
  to_regprocedure('public.rpc_waqf_asset_detail_v1(uuid)') is not null as waqf_asset_detail_rpc_exists,
  to_regprocedure('public.rpc_core_location_runtime_certification_v1()') is not null as core_location_runtime_certification_rpc_exists,
  false as production_approved;

select
  'postgis_preflight' as section,
  e.extname,
  n.nspname as extension_schema,
  false as production_approved
from pg_extension e
join pg_namespace n on n.oid = e.extnamespace
where e.extname = 'postgis';
