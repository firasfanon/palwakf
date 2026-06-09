-- Mega Batch N2.14.1 read-only UAT
-- Verifies System Module Kit SQL hotfix without mutating waqf / waqf_assets / awqaf_system.

with checks as (
  select
    'schema' as section,
    'platform_schema_exists' as check_key,
    exists(select 1 from information_schema.schemata where schema_name = 'platform') as passed,
    'platform schema exists' as note
  union all
  select
    'views',
    'registry_view_exists',
    to_regclass('public.v_platform_system_registry') is not null,
    'public.v_platform_system_registry exists'
  union all
  select
    'views',
    'sections_view_exists',
    to_regclass('public.v_platform_system_sections') is not null,
    'public.v_platform_system_sections exists'
  union all
  select
    'views',
    'registry_view_order_preserved',
    exists (
      select 1 from information_schema.columns
      where table_schema = 'public'
        and table_name = 'v_platform_system_registry'
        and column_name = 'admin_route_path'
        and ordinal_position = 7
    ),
    'N2.10 view order preserved: admin_route_path remains column 7'
  union all
  select
    'views',
    'registry_n2_14_columns_appended',
    exists (
      select 1 from information_schema.columns
      where table_schema = 'public'
        and table_name = 'v_platform_system_registry'
        and column_name = 'system_type'
        and ordinal_position > 17
    ),
    'N2.14 registry columns were appended instead of inserted before existing columns'
  union all
  select
    'views',
    'sections_n2_14_columns_appended',
    exists (
      select 1 from information_schema.columns
      where table_schema = 'public'
        and table_name = 'v_platform_system_sections'
        and column_name = 'section_scope'
        and ordinal_position > 13
    ),
    'N2.14 section columns were appended instead of inserted before existing columns'
  union all
  select
    'rpc',
    'module_kit_contract_rpc_exists',
    to_regprocedure('public.pwf_platform_system_module_kit_contract_v1()') is not null,
    'System Module Kit contract RPC exists'
  union all
  select
    'sovereign_boundary',
    'no_waq_assets_mutation_in_this_script',
    true,
    'This UAT script is read-only and does not modify waqf, waqf_assets, or awqaf_system.'
)
select * from checks order by section, check_key;
