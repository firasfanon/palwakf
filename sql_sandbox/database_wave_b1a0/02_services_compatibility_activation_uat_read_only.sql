-- Database Wave B-1A.0 UAT
-- Read-only verification for service compatibility activation.
-- Does not mutate operational data.

with checks as (
  select 'b1a0_activation'::text as section, 'v_services_catalog_compat_v1_exists'::text as check_key,
    to_regclass('public.v_services_catalog_compat_v1') is not null as passed,
    'Service catalog compatibility facade must exist.'::text as note
  union all
  select 'b1a0_activation', 'v_service_types_compat_v1_exists',
    to_regclass('public.v_service_types_compat_v1') is not null,
    'Service type compatibility facade must exist.'
  union all
  select 'b1a0_activation', 'v_service_providers_compat_v1_exists',
    to_regclass('public.v_service_providers_compat_v1') is not null,
    'Service providers compatibility facade must exist.'
  union all
  select 'b1a0_activation', 'v_service_points_compat_v1_exists',
    to_regclass('public.v_service_points_compat_v1') is not null,
    'Service points compatibility facade must exist.'
  union all
  select 'b1a0_activation', 'v_home_services_compat_v1_exists',
    to_regclass('public.v_home_services_compat_v1') is not null,
    'Home services compatibility facade must exist.'
  union all
  select 'b1a0_activation', 'rpc_services_catalog_compat_v1_exists',
    exists (
      select 1 from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public' and p.proname = 'rpc_services_catalog_compat_v1'
    ),
    'Service catalog compatibility RPC must exist.'
  union all
  select 'b1a0_activation', 'rpc_home_services_compat_v1_exists',
    exists (
      select 1 from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public' and p.proname = 'rpc_home_services_compat_v1'
    ),
    'Home services compatibility RPC must exist.'
  union all
  select 'sovereign_boundary', 'no_waq_assets_mutation_in_this_script', true,
    'Read-only UAT only; this script does not mutate waqf/waqf_assets/awqaf_system.'
)
select * from checks order by section, check_key;

select
  'b1a0_row_counts'::text as section,
  'services_catalog_compat_v1'::text as contract_name,
  count(*)::bigint as row_count,
  'Rows visible through public.v_services_catalog_compat_v1.'::text as note
from public.v_services_catalog_compat_v1
union all
select 'b1a0_row_counts', 'home_services_compat_v1', count(*)::bigint, 'Rows visible through public.v_home_services_compat_v1.' from public.v_home_services_compat_v1
union all
select 'b1a0_row_counts', 'service_types_compat_v1', count(*)::bigint, 'Rows visible through public.v_service_types_compat_v1.' from public.v_service_types_compat_v1
union all
select 'b1a0_row_counts', 'service_providers_compat_v1', count(*)::bigint, 'Rows visible through public.v_service_providers_compat_v1.' from public.v_service_providers_compat_v1
union all
select 'b1a0_row_counts', 'service_points_compat_v1', count(*)::bigint, 'Rows visible through public.v_service_points_compat_v1.' from public.v_service_points_compat_v1
order by contract_name;
