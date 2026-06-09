-- PalWakf N2.27
-- Read-only UAT. Safe to run after optional draft bootstrap scripts if approved.

with schema_checks as (
  select 'site_content_schema_exists' as check_key,
         exists(select 1 from information_schema.schemata where schema_name='site_content') as passed,
         'site_content schema exists if draft bootstrap was applied' as note
  union all
  select 'media_center_schema_exists',
         exists(select 1 from information_schema.schemata where schema_name='media_center'),
         'media_center schema exists if draft bootstrap was applied'
), registry_checks as (
  select 'site_content_shadow_registry_exists' as check_key,
         exists(select 1 from information_schema.tables where table_schema='site_content' and table_name='migration_shadow_registry') as passed,
         'site_content planning registry exists if draft bootstrap was applied' as note
  union all
  select 'media_center_shadow_registry_exists',
         exists(select 1 from information_schema.tables where table_schema='media_center' and table_name='migration_shadow_registry'),
         'media_center planning registry exists if draft bootstrap was applied'
), sovereign_boundary as (
  select 'no_waq_assets_mutation_in_this_script' as check_key,
         true as passed,
         'Read-only UAT. No waqf/waqf_assets/awqaf_system DML.' as note
)
select 'schema' as section, * from schema_checks
union all
select 'registry' as section, * from registry_checks
union all
select 'sovereign_boundary' as section, * from sovereign_boundary
order by section, check_key;
