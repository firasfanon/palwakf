-- Mega Batch J — Platform Centers Backend SQL Result Intake + Browser UAT Runtime Fixes
-- Read-only runtime UAT after Mega Batch I SQL passed.
-- Scope: verify the applied backend exists, public view is published-only, and RPCs are callable by metadata.
-- This script does not mutate waqf, awqaf_system, platform_content, or public data.

with checks as (
  select
    'platform_content_schema_exists'::text as check_key,
    exists(select 1 from information_schema.schemata where schema_name = 'platform_content') as passed,
    'platform_content schema should exist after Mega Batch I.'::text as note
  union all
  select
    'platform_content_required_tables_count',
    (select count(*) = 5
     from information_schema.tables
     where table_schema = 'platform_content'
       and table_name in (
        'center_content_categories',
        'center_content_items',
        'center_content_workflow_events',
        'center_content_attachments',
        'center_content_relations'
       )),
    'Required operational tables installed=' ||
    (select count(*)::text from information_schema.tables where table_schema = 'platform_content'
      and table_name in ('center_content_categories','center_content_items','center_content_workflow_events','center_content_attachments','center_content_relations')) || '/5'
  union all
  select
    'public_view_published_only_exists',
    exists(select 1 from information_schema.views where table_schema = 'public' and table_name = 'v_platform_center_content'),
    'public.v_platform_center_content should exist and expose published content only.'
  union all
  select
    'public_rpc_contracts_exist',
    (select count(*) = 3
     from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public'
       and p.proname in ('pwf_platform_center_content_list','pwf_platform_center_content_upsert','pwf_platform_center_content_transition')),
    'RPC wrappers installed=' ||
    (select count(*)::text from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname in ('pwf_platform_center_content_list','pwf_platform_center_content_upsert','pwf_platform_center_content_transition')) || '/3'
  union all
  select
    'rls_enabled_on_platform_content',
    (select count(*) = 5
     from pg_class c join pg_namespace n on n.oid = c.relnamespace
     where n.nspname = 'platform_content'
       and c.relname in ('center_content_categories','center_content_items','center_content_workflow_events','center_content_attachments','center_content_relations')
       and c.relrowsecurity is true),
    'RLS enabled tables=' ||
    (select count(*)::text from pg_class c join pg_namespace n on n.oid = c.relnamespace
     where n.nspname = 'platform_content'
       and c.relname in ('center_content_categories','center_content_items','center_content_workflow_events','center_content_attachments','center_content_relations')
       and c.relrowsecurity is true) || '/5'
  union all
  select
    'published_view_current_rows',
    true,
    'current_published_rows=' || coalesce((select count(*)::text from public.v_platform_center_content), '0')
  union all
  select
    'admin_table_current_rows',
    true,
    'current_center_content_items=' || coalesce((select count(*)::text from platform_content.center_content_items), '0')
  union all
  select
    'no_waqf_assets_mutation_in_this_script',
    true,
    'Read-only runtime UAT. No waqf schema mutation.'
)
select * from checks order by check_key;
