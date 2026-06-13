-- 03_VERIFY_function_definition_and_rpc_smoke_read_only.sql

select
  'awqaf_asset_detail_postgis_geojson_qualification_verify_definition' as section,
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  p.prosecdef as security_definer,
  r.rolname as function_owner,
  p.proconfig as function_config,
  position('extensions.st_asgeojson(g.geom)' in lower(pg_get_functiondef(p.oid))) > 0 as has_qualified_geom_call,
  position('extensions.st_asgeojson(g.centroid)' in lower(pg_get_functiondef(p.oid))) > 0 as has_qualified_centroid_call,
  false as production_approved
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
join pg_roles r on r.oid = p.proowner
where n.nspname = 'waqf'
  and p.proname = 'rpc_waqf_asset_detail_v1';

begin;
set local role authenticated;

select set_config(
  'request.jwt.claim.sub',
  '96f6cdc2-67f9-4352-b9f8-775ef509fed8',
  true
);

select set_config(
  'request.jwt.claims',
  '{"sub":"96f6cdc2-67f9-4352-b9f8-775ef509fed8","role":"authenticated","email":"firasfanon@gmail.com"}',
  true
);

select
  'awqaf_asset_detail_postgis_geojson_qualified_rpc_smoke' as section,
  jsonb_typeof(public.rpc_waqf_asset_detail_v1('721abf33-b243-4bd2-9ece-577128c2fdf4'::uuid)) as result_json_type,
  public.rpc_waqf_asset_detail_v1('721abf33-b243-4bd2-9ece-577128c2fdf4'::uuid) ? 'asset' as has_asset_key,
  public.rpc_waqf_asset_detail_v1('721abf33-b243-4bd2-9ece-577128c2fdf4'::uuid) ? 'geometries' as has_geometries_key,
  false as production_approved;

rollback;
