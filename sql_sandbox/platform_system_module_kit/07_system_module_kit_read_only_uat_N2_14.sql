-- Mega Batch N2.14 read-only UAT
-- Confirms System Module Kit metadata and public wrappers are present.
-- This script performs read-only checks only.

with checks as (
  select 'schema' as section, 'platform_schema_exists' as check_key,
    exists(select 1 from information_schema.schemata where schema_name='platform') as passed,
    'platform schema exists for system module kit' as note
  union all
  select 'tables','system_registry_exists', to_regclass('platform.system_registry') is not null,
    'platform.system_registry stores bounded systems/modules'
  union all
  select 'tables','system_sections_exists', to_regclass('platform.system_sections') is not null,
    'platform.system_sections stores system sections dynamically'
  union all
  select 'columns','system_registry_module_kit_columns_exist',
    (select count(*) = 10 from information_schema.columns where table_schema='platform' and table_name='system_registry' and column_name in ('system_type','sensitivity_level','route_base','public_home_enabled','health_check_key','operational_status','maintenance_mode','error_boundary_key','assistant_scope_key','usage_guide_scope_key')),
    'system registry has system type, sensitivity, route, health, maintenance, error boundary, assistant and usage guide scope columns'
  union all
  select 'columns','system_sections_module_kit_columns_exist',
    (select count(*) = 8 from information_schema.columns where table_schema='platform' and table_name='system_sections' and column_name in ('section_scope','public_visibility','health_check_key','operational_status','maintenance_mode','error_boundary_key','assistant_scope_key','usage_guide_scope_key')),
    'system sections has scope, public visibility, health, maintenance, error boundary, assistant and usage guide scope columns'
  union all
  select 'views','public_wrappers_exist',
    to_regclass('public.v_platform_system_registry') is not null and to_regclass('public.v_platform_system_sections') is not null,
    'public wrappers expose dynamic systems and sections safely'
  union all
  select 'rpc','system_module_kit_contract_rpc_exists',
    exists(select 1 from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname='pwf_platform_system_module_kit_contract_v1'),
    'read-only contract RPC exists'
  union all
  select 'sovereign_boundary','no_waq_assets_mutation_in_this_script', true,
    'This UAT script is read-only and does not modify waqf, waqf_assets, or awqaf_system.'
)
select * from checks order by section, check_key;
