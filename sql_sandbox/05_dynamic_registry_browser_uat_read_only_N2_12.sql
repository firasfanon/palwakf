-- Mega Batch N2.12 — Dynamic Registry Browser UAT Read-only Evidence
-- Purpose: confirm dynamic registry runtime prerequisites without DML.
-- Boundary: read-only only; no waqf, waqf_assets, or awqaf_system mutation.

with checks as (
  select 'schema' as section, 'platform_schema_exists' as check_key,
    exists(select 1 from information_schema.schemata where schema_name = 'platform') as passed,
    'platform schema exists for dynamic registry' as note
  union all
  select 'tables', 'system_registry_exists',
    exists(select 1 from information_schema.tables where table_schema='platform' and table_name='system_registry'),
    'platform.system_registry exists'
  union all
  select 'tables', 'system_sections_exists',
    exists(select 1 from information_schema.tables where table_schema='platform' and table_name='system_sections'),
    'platform.system_sections exists'
  union all
  select 'views', 'public_dynamic_registry_views_exist',
    exists(select 1 from information_schema.views where table_schema='public' and table_name='v_platform_system_registry')
    and exists(select 1 from information_schema.views where table_schema='public' and table_name='v_platform_system_sections'),
    'public read wrappers exist'
  union all
  select 'rpc', 'dynamic_registry_visibility_rpcs_exist',
    exists(select 1 from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname like 'pwf_platform_system%'),
    'dynamic registry RPC surface exists'
  union all
  select 'sovereign_boundary', 'no_waq_assets_mutation_in_this_script',
    true,
    'This script is read-only and performs no DML on waqf, waqf_assets, or awqaf_system.'
)
select * from checks order by section, check_key;
