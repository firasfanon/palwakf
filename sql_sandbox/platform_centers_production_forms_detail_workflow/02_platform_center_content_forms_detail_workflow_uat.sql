-- Mega Batch L — read-only verification for production forms/detail/workflow hardening.
with required_functions as (
  select unnest(array[
    'pwf_platform_center_content_get',
    'pwf_platform_center_content_upsert',
    'pwf_platform_center_content_transition'
  ]) as function_name
), installed_functions as (
  select p.proname as function_name
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
), view_columns as (
  select column_name
  from information_schema.columns
  where table_schema = 'public'
    and table_name = 'v_platform_center_content'
), state_machine_source as (
  select pg_get_functiondef(p.oid) as source_sql
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
    and p.proname = 'pwf_platform_center_content_transition'
  limit 1
)
select 'detail_rpc_exists' as check_key,
       exists (select 1 from installed_functions where function_name = 'pwf_platform_center_content_get') as passed,
       'public.pwf_platform_center_content_get must exist for /family/:id pages' as note
union all
select 'extended_upsert_rpc_exists',
       exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname='public' and p.proname='pwf_platform_center_content_upsert' and p.pronargs >= 10),
       'upsert must accept id/body/category/document_url/metadata fields'
union all
select 'public_view_detail_columns',
       not exists (
         select 1 from unnest(array['body_ar','category_key','metadata','unit_slug']) c
         where not exists (select 1 from view_columns vc where vc.column_name = c)
       ),
       'public.v_platform_center_content includes detail-safe columns'
union all
select 'transition_state_machine_hardened',
       exists (select 1 from state_machine_source where source_sql like '%انتقال سير العمل غير مسموح%' and source_sql like '%v_new_status is null%'),
       'transition RPC rejects illegal state changes at DB level'
union all
select 'no_waqf_assets_mutation_in_this_script',
       true,
       'Read-only UAT. Mega L does not touch waqf schema or awqaf_system.';
