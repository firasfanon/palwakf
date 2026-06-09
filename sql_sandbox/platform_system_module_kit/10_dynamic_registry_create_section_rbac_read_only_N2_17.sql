-- 10_dynamic_registry_create_section_rbac_read_only_N2_17.sql
-- Read-only evidence script. Does not modify waqf, waqf_assets, or awqaf_system.

with checks as (
  select 'schema'::text as section,
         'platform_schema_exists'::text as check_key,
         exists(select 1 from information_schema.schemata where schema_name = 'platform') as passed,
         'platform schema must exist'::text as note
  union all
  select 'tables','system_registry_exists',
         exists(select 1 from information_schema.tables where table_schema='platform' and table_name='system_registry'),
         'platform.system_registry exists'
  union all
  select 'tables','system_sections_exists',
         exists(select 1 from information_schema.tables where table_schema='platform' and table_name='system_sections'),
         'platform.system_sections exists'
  union all
  select 'data','dynamic_system_records_present',
         coalesce((select count(*) > 0 from platform.system_registry), false),
         'At least one dynamic system record exists after browser create/update UAT'
  union all
  select 'data','dynamic_section_records_present',
         coalesce((select count(*) > 0 from platform.system_sections), false),
         'At least one dynamic section record exists after browser create/update UAT'
  union all
  select 'views','public_registry_view_exists',
         exists(select 1 from information_schema.views where table_schema='public' and table_name='v_platform_system_registry'),
         'public registry view exists'
  union all
  select 'views','public_sections_view_exists',
         exists(select 1 from information_schema.views where table_schema='public' and table_name='v_platform_system_sections'),
         'public sections view exists'
  union all
  select 'sovereign_boundary','no_waq_assets_mutation_in_this_script',
         true,
         'This UAT script is read-only and does not modify waqf, waqf_assets, or awqaf_system.'
)
select * from checks order by section, check_key;
