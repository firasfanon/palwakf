-- Mega Batch N2.18 — Dynamic Registry Create/Section Create + Admin Assistant Evidence Read-only UAT
-- Safe read-only checks. No DML. No waqf/waqf_assets/awqaf_system mutation.

with checks as (
  select 'schema'::text as section,
         'platform_schema_exists'::text as check_key,
         exists(select 1 from information_schema.schemata where schema_name = 'platform') as passed,
         'platform schema exists'::text as note
  union all
  select 'tables','system_registry_exists',
         to_regclass('platform.system_registry') is not null,
         'platform.system_registry exists'
  union all
  select 'tables','system_sections_exists',
         to_regclass('platform.system_sections') is not null,
         'platform.system_sections exists'
  union all
  select 'views','registry_view_exists',
         to_regclass('public.v_platform_system_registry') is not null,
         'public.v_platform_system_registry exists'
  union all
  select 'views','sections_view_exists',
         to_regclass('public.v_platform_system_sections') is not null,
         'public.v_platform_system_sections exists'
  union all
  select 'records','dynamic_system_records_available',
         coalesce((select count(*) > 0 from platform.system_registry), false),
         'Expected true only after creating at least one dynamic system record'
  union all
  select 'records','dynamic_section_records_available',
         coalesce((select count(*) > 0 from platform.system_sections), false),
         'Expected true only after creating at least one dynamic section record'
  union all
  select 'sovereign_boundary','no_waq_assets_mutation_in_this_script',
         true,
         'This script is read-only and does not modify waqf, waqf_assets, or awqaf_system.'
)
select * from checks order by section, check_key;

-- Optional operator review queries after creating a test system/section:
-- select system_key, name_ar, system_type, sensitivity_level, route_base, show_in_sidebar, show_in_dashboard, is_active
-- from platform.system_registry
-- order by created_at desc nulls last, system_key
-- limit 20;
--
-- select system_key, section_key, title_ar, route_path, required_permission_key, is_active
-- from platform.system_sections
-- order by created_at desc nulls last, system_key, section_key
-- limit 50;
