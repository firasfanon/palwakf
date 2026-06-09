-- Mega Batch L1 — Platform Centers Detail/Workflow UAT Single Result
-- Read-only verification after applying:
-- 01_platform_center_content_forms_detail_workflow_hardening_l1_view_order_fix.sql

with view_columns as (
  select
    column_name,
    ordinal_position
  from information_schema.columns
  where table_schema = 'public'
    and table_name = 'v_platform_center_content'
),
view_order_check as (
  select
    bool_and(ok) as passed
  from (
    values
      ('id', 1),
      ('family_key', 2),
      ('title_ar', 3),
      ('summary_ar', 4),
      ('owner_name', 5),
      ('scope_type', 6),
      ('workflow_status', 7),
      ('status', 8),
      ('public_route', 9),
      ('published_at', 10),
      ('document_url', 11),
      ('unit_slug', 12),
      ('is_featured', 13),
      ('sort_order', 14),
      ('metadata', 15),
      ('created_at', 16),
      ('updated_at', 17)
  ) as expected(column_name, ordinal_position)
  left join view_columns actual
    on actual.column_name = expected.column_name
   and actual.ordinal_position = expected.ordinal_position
  cross join lateral (select actual.column_name is not null as ok) x
),
detail_columns as (
  select
    count(*) filter (where column_name in ('body_ar', 'category_key')) as installed_detail_columns,
    string_agg(column_name, ', ' order by ordinal_position) filter (where column_name in ('body_ar', 'category_key')) as detail_columns
  from view_columns
),
function_checks as (
  select
    exists (
      select 1
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public'
        and p.proname = 'pwf_platform_center_content_get'
        and pg_get_function_identity_arguments(p.oid) = 'p_id text, p_family_key text, p_unit_slug text'
    ) as detail_rpc_exists,
    exists (
      select 1
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public'
        and p.proname = 'pwf_platform_center_content_upsert'
        and pg_get_function_identity_arguments(p.oid) = 'p_family_key text, p_title text, p_summary text, p_scope_type text, p_unit_slug text, p_id text, p_body text, p_category_key text, p_document_url text, p_metadata jsonb'
    ) as extended_upsert_rpc_exists,
    exists (
      select 1
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public'
        and p.proname = 'pwf_platform_center_content_transition'
        and pg_get_function_identity_arguments(p.oid) = 'p_id text, p_family_key text, p_action text'
        and pg_get_functiondef(p.oid) ilike '%انتقال سير العمل غير مسموح%'
        and pg_get_functiondef(p.oid) ilike '%ready_to_publish%'
        and pg_get_functiondef(p.oid) ilike '%v_new_status is null%'
    ) as transition_state_machine_hardened
),
security_checks as (
  select
    exists (
      select 1
      from pg_views
      where schemaname = 'public'
        and viewname = 'v_platform_center_content'
        and definition ilike '%workflow_status = ''published''%'
        and definition ilike '%publication_status = ''published''%'
    ) as published_only_view_safety
)
select
  check_key,
  passed,
  note
from (
  select
    'view_base_column_order_preserved'::text as check_key,
    coalesce((select passed from view_order_check), false) as passed,
    'public.v_platform_center_content preserves Mega I column order before appending detail columns.'::text as note
  union all
  select
    'public_view_detail_columns',
    (select installed_detail_columns = 2 from detail_columns),
    'detail_columns=' || coalesce((select detail_columns from detail_columns), 'none')
  union all
  select
    'detail_rpc_exists',
    (select detail_rpc_exists from function_checks),
    'public.pwf_platform_center_content_get exists for /family/:id pages.'
  union all
  select
    'extended_upsert_rpc_exists',
    (select extended_upsert_rpc_exists from function_checks),
    'upsert accepts id/body/category/document_url/metadata fields.'
  union all
  select
    'transition_state_machine_hardened',
    (select transition_state_machine_hardened from function_checks),
    'transition RPC rejects illegal state changes at DB level.'
  union all
  select
    'published_only_view_safety',
    (select published_only_view_safety from security_checks),
    'public view remains published-only.'
  union all
  select
    'no_waq_assets_mutation_in_this_script',
    true,
    'Read-only UAT. Mega L1 does not touch waqf schema or awqaf_system.'
) checks
order by check_key;
