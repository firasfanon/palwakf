-- Mega Batch N2.15 — System Module Kit Analyzer/Browser UAT Read-only Evidence
-- Read-only checks only. No DML. No waqf/waq_assets/awqaf_system mutation.

with checks as (
  select 'schema'::text as section,
         'platform_schema_exists'::text as check_key,
         exists(select 1 from information_schema.schemata where schema_name = 'platform') as passed,
         'platform schema exists for Dynamic Registry/System Module Kit'::text as note
  union all
  select 'views','registry_view_exists',
         to_regclass('public.v_platform_system_registry') is not null,
         'public.v_platform_system_registry exists'
  union all
  select 'views','sections_view_exists',
         to_regclass('public.v_platform_system_sections') is not null,
         'public.v_platform_system_sections exists'
  union all
  select 'views','registry_view_order_preserved',
         exists(
           select 1 from information_schema.columns
           where table_schema='public'
             and table_name='v_platform_system_registry'
             and column_name='admin_route_path'
             and ordinal_position=7
         ),
         'N2.10 view contract order is preserved: admin_route_path remains column 7'
  union all
  select 'views','system_module_kit_columns_available',
         exists(select 1 from information_schema.columns where table_schema='public' and table_name='v_platform_system_registry' and column_name='system_type')
         and exists(select 1 from information_schema.columns where table_schema='public' and table_name='v_platform_system_registry' and column_name='sensitivity_level')
         and exists(select 1 from information_schema.columns where table_schema='public' and table_name='v_platform_system_registry' and column_name='maintenance_mode'),
         'N2.14 System Module Kit columns are available in registry public contract'
  union all
  select 'views','system_sections_module_kit_columns_available',
         exists(select 1 from information_schema.columns where table_schema='public' and table_name='v_platform_system_sections' and column_name='section_type')
         and exists(select 1 from information_schema.columns where table_schema='public' and table_name='v_platform_system_sections' and column_name='maintenance_mode'),
         'N2.14 System Module Kit columns are available in sections public contract'
  union all
  select 'sovereign_boundary','no_waq_assets_mutation_in_this_script',
         true,
         'This UAT script is read-only and does not modify waqf, waqf_assets, or awqaf_system.'
)
select * from checks order by section, check_key;
