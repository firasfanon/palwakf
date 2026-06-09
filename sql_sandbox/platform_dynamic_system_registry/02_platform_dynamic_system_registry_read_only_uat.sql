-- Mega Batch N2.10 read-only UAT evidence
-- No DML; no waqf/waqf_assets mutation.
with checks as (
  select 'schema' as section, 'platform_schema_exists' as check_key,
    exists(select 1 from information_schema.schemata where schema_name = 'platform') as passed,
    'platform schema required for dynamic system registry' as note
  union all
  select 'tables','system_registry_exists',
    exists(select 1 from information_schema.tables where table_schema='platform' and table_name='system_registry'),
    'platform.system_registry stores dynamic systems/services/modules'
  union all
  select 'tables','system_sections_exists',
    exists(select 1 from information_schema.tables where table_schema='platform' and table_name='system_sections'),
    'platform.system_sections stores dynamic sections per system'
  union all
  select 'tables','role_permission_catalog_exists',
    (select count(*) = 2 from information_schema.tables where table_schema='platform' and table_name in ('system_role_catalog','system_permission_catalog')),
    'dynamic role and permission catalogs exist'
  union all
  select 'tables','dynamic_user_assignment_tables_exist',
    (select count(*) = 2 from information_schema.tables where table_schema='platform' and table_name in ('system_user_roles','system_user_permissions')),
    'dynamic user role/permission assignment tables exist'
  union all
  select 'views','public_dynamic_views_exist',
    (select count(*) = 2 from information_schema.views where table_schema='public' and table_name in ('v_platform_system_registry','v_platform_system_sections')),
    'public read wrappers exist'
  union all
  select 'rpc','dynamic_registry_rpcs_exist',
    (select count(*) >= 6 from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname in (
      'pwf_platform_visible_systems_for_user_v1',
      'pwf_platform_system_registry_list_v1',
      'pwf_platform_system_sections_list_v1',
      'pwf_platform_system_upsert_v1',
      'pwf_platform_system_section_upsert_v1',
      'pwf_platform_user_can_manage_system_registry_v1'
    )),
    'RPC wrappers for list/upsert/visibility exist'
  union all
  select 'sovereign_boundary','no_waq_assets_mutation_in_this_script', true,
    'This UAT script is read-only and does not modify waqf, waqf_assets, or awqaf_system.'
)
select * from checks order by section, check_key;
