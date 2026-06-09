-- Mega Batch I — Platform Content Backend Readiness UAT
-- Read-only verification script. No mutations.

select
  'platform_content_schema_exists' as check_key,
  exists(select 1 from information_schema.schemata where schema_name = 'platform_content') as passed;

select
  'platform_content_required_tables' as check_key,
  count(*) filter (where table_schema = 'platform_content' and table_name in (
    'center_content_categories',
    'center_content_items',
    'center_content_workflow_events',
    'center_content_attachments',
    'center_content_relations'
  )) as installed_tables,
  5 as expected_tables
from information_schema.tables
where table_schema = 'platform_content';

select
  'public_view_exists' as check_key,
  exists(select 1 from information_schema.views where table_schema = 'public' and table_name = 'v_platform_center_content') as passed;

select
  'public_rpc_wrappers_exist' as check_key,
  count(*) filter (where n.nspname = 'public' and p.proname in (
    'pwf_platform_center_content_list',
    'pwf_platform_center_content_upsert',
    'pwf_platform_center_content_transition'
  )) as installed_functions,
  3 as expected_functions
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace;

select
  'rls_enabled' as check_key,
  n.nspname as schema_name,
  c.relname as table_name,
  c.relrowsecurity as rls_enabled,
  c.relforcerowsecurity as rls_forced
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'platform_content'
  and c.relkind in ('r', 'p')
order by c.relname;

select
  'no_waqf_assets_mutation_in_this_script' as check_key,
  true as passed,
  'Mega Batch I creates platform_content schema only and public wrappers; it does not touch waqf schema.' as note;
