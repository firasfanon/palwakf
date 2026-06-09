-- Mega Batch I — Platform Content Backend Readiness UAT — Single Result Matrix
-- Purpose: Supabase SQL Editor sometimes displays only the last SELECT result.
-- This script returns all checks in one result table.
-- Read-only. No mutations.

with required_tables as (
  select unnest(array[
    'center_content_categories',
    'center_content_items',
    'center_content_workflow_events',
    'center_content_attachments',
    'center_content_relations'
  ]) as table_name
), installed_tables as (
  select table_name
  from information_schema.tables
  where table_schema = 'platform_content'
), required_functions as (
  select unnest(array[
    'pwf_platform_center_content_list',
    'pwf_platform_center_content_upsert',
    'pwf_platform_center_content_transition'
  ]) as function_name
), installed_functions as (
  select p.proname as function_name
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
), rls_tables as (
  select
    c.relname as table_name,
    c.relrowsecurity as rls_enabled,
    c.relforcerowsecurity as rls_forced
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'platform_content'
    and c.relkind in ('r', 'p')
), public_view_cols as (
  select column_name
  from information_schema.columns
  where table_schema = 'public'
    and table_name = 'v_platform_center_content'
), required_view_cols as (
  select unnest(array[
    'id',
    'family_key',
    'title_ar',
    'summary_ar',
    'owner_name',
    'scope_type',
    'workflow_status',
    'public_route',
    'published_at',
    'document_url'
  ]) as column_name
), category_seed as (
  select count(*) as seed_count
  from platform_content.center_content_categories
), policy_count as (
  select count(*) as policies_count
  from pg_policies
  where schemaname = 'platform_content'
), waqf_guard as (
  select true as passed
)
select
  'platform_content_schema_exists' as check_key,
  exists(select 1 from information_schema.schemata where schema_name = 'platform_content') as passed,
  case when exists(select 1 from information_schema.schemata where schema_name = 'platform_content')
    then 'platform_content schema exists'
    else 'platform_content schema is missing; run 01_platform_content_schema_tables_views_rpc_production_readiness.sql first'
  end as note
union all
select
  'platform_content_required_tables',
  (select count(*) from required_tables rt join installed_tables it using (table_name)) = 5,
  'installed=' || (select count(*) from required_tables rt join installed_tables it using (table_name)) || '/5; missing=' || coalesce((select string_agg(rt.table_name, ', ' order by rt.table_name) from required_tables rt left join installed_tables it using (table_name) where it.table_name is null), 'none')
union all
select
  'public_view_exists',
  exists(select 1 from information_schema.views where table_schema = 'public' and table_name = 'v_platform_center_content'),
  case when exists(select 1 from information_schema.views where table_schema = 'public' and table_name = 'v_platform_center_content')
    then 'public.v_platform_center_content exists'
    else 'public.v_platform_center_content is missing'
  end
union all
select
  'public_view_required_columns',
  (select count(*) from required_view_cols rvc join public_view_cols pvc using (column_name)) = 10,
  'installed=' || (select count(*) from required_view_cols rvc join public_view_cols pvc using (column_name)) || '/10; missing=' || coalesce((select string_agg(rvc.column_name, ', ' order by rvc.column_name) from required_view_cols rvc left join public_view_cols pvc using (column_name) where pvc.column_name is null), 'none')
union all
select
  'public_rpc_wrappers_exist',
  (select count(*) from required_functions rf join installed_functions inf using (function_name)) = 3,
  'installed=' || (select count(*) from required_functions rf join installed_functions inf using (function_name)) || '/3; missing=' || coalesce((select string_agg(rf.function_name, ', ' order by rf.function_name) from required_functions rf left join installed_functions inf using (function_name) where inf.function_name is null), 'none')
union all
select
  'rls_enabled_on_required_tables',
  (select count(*) from required_tables rt join rls_tables r using (table_name) where r.rls_enabled) = 5,
  'rls_enabled=' || (select count(*) from required_tables rt join rls_tables r using (table_name) where r.rls_enabled) || '/5; missing_or_disabled=' || coalesce((select string_agg(rt.table_name, ', ' order by rt.table_name) from required_tables rt left join rls_tables r using (table_name) where coalesce(r.rls_enabled, false) is false), 'none')
union all
select
  'rls_policies_exist',
  (select policies_count from policy_count) >= 5,
  'platform_content policies=' || (select policies_count from policy_count)::text
union all
select
  'categories_seed_exists',
  (select seed_count from category_seed) >= 10,
  'seed_categories=' || (select seed_count from category_seed)::text
union all
select
  'published_only_view_safety',
  not exists (
    select 1
    from public.v_platform_center_content
    where coalesce(workflow_status, '') <> 'published'
  ),
  case when not exists (
    select 1
    from public.v_platform_center_content
    where coalesce(workflow_status, '') <> 'published'
  ) then 'public view exposes published rows only or no rows yet'
  else 'public view exposes non-published rows; review view definition'
  end
union all
select
  'no_waqf_assets_mutation_in_this_script',
  true,
  'Read-only UAT. No waqf schema mutation.'
order by check_key;
