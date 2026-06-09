-- PalWakf Platform — Mega Batch M2.1
-- Service Center Runtime UAT Column Compatibility Fix
-- Date: 2026-05-11
-- Scope: read-only UAT for platform_services runtime readiness.
-- Reason: Mega M2 UAT referenced service_forms_registry.is_active, but the production table uses public_visibility + review_status.
-- Safety: This script does not modify waqf, awqaf_system, platform_services, or any production data.

with required_tables as (
  select unnest(array[
    'service_forms_registry',
    'service_requests',
    'service_request_status_events',
    'service_request_attachments'
  ]) as table_name
), installed_tables as (
  select table_name
  from information_schema.tables
  where table_schema = 'platform_services'
), required_functions as (
  select unnest(array[
    'rpc_services_forms_public_v1',
    'rpc_services_submit_request_v1',
    'rpc_services_track_request_public_v1',
    'rpc_services_admin_request_queue_v1',
    'rpc_services_admin_transition_request_v1'
  ]) as function_name
), installed_functions as (
  select p.proname as function_name
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
), rls_tables as (
  select c.relname as table_name, c.relrowsecurity as rls_enabled
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'platform_services'
    and c.relkind in ('r', 'p')
), policies as (
  select schemaname, tablename, policyname
  from pg_policies
  where schemaname = 'platform_services'
), form_runtime_rows as (
  select count(*)::int as active_forms
  from platform_services.service_forms_registry f
  where coalesce(
    nullif(to_jsonb(f)->>'is_active', '')::boolean,
    (
      coalesce(nullif(to_jsonb(f)->>'public_visibility', '')::boolean, false)
      and coalesce(to_jsonb(f)->>'review_status', '') = 'approved'
      and (
        to_jsonb(f)->>'effective_to' is null
        or nullif(to_jsonb(f)->>'effective_to', '')::date >= current_date
      )
    ),
    false
  ) = true
), form_registry_columns as (
  select
    bool_or(column_name = 'is_active') as has_is_active,
    bool_or(column_name = 'public_visibility') as has_public_visibility,
    bool_or(column_name = 'review_status') as has_review_status
  from information_schema.columns
  where table_schema = 'platform_services'
    and table_name = 'service_forms_registry'
)
select 'platform_services_required_tables' as check_key,
       not exists (select 1 from required_tables rt left join installed_tables it using (table_name) where it.table_name is null) as passed,
       'installed=' || (select count(*) from installed_tables where table_name in (select table_name from required_tables)) || '/4; missing=' || coalesce((select string_agg(rt.table_name, ', ' order by rt.table_name) from required_tables rt left join installed_tables it using (table_name) where it.table_name is null), 'none') as note
union all
select 'public_service_center_rpc_wrappers_exist',
       not exists (select 1 from required_functions rf left join installed_functions inf using (function_name) where inf.function_name is null),
       'installed=' || (select count(*) from installed_functions where function_name in (select function_name from required_functions)) || '/5; missing=' || coalesce((select string_agg(rf.function_name, ', ' order by rf.function_name) from required_functions rf left join installed_functions inf using (function_name) where inf.function_name is null), 'none')
union all
select 'rls_enabled_on_service_tables',
       not exists (select 1 from required_tables rt left join rls_tables r using (table_name) where coalesce(r.rls_enabled, false) = false),
       'rls_enabled=' || (select count(*) from rls_tables where rls_enabled and table_name in (select table_name from required_tables)) || '/4'
union all
select 'rls_policies_exist',
       (select count(*) from policies) >= 4,
       'platform_services policies=' || (select count(*) from policies)
union all
select 'forms_registry_has_runtime_rows',
       (select active_forms > 0 from form_runtime_rows),
       'runtime_forms=' || (select active_forms::text from form_runtime_rows)
       || '; activation_rule='
       || case
            when (select has_is_active from form_registry_columns) then 'is_active=true'
            when (select has_public_visibility and has_review_status from form_registry_columns) then 'public_visibility=true and review_status=approved'
            else 'unknown activation columns'
          end
union all
select 'forms_registry_column_contract',
       (select has_is_active or (has_public_visibility and has_review_status) from form_registry_columns),
       'has_is_active=' || (select has_is_active::text from form_registry_columns)
       || '; has_public_visibility=' || (select has_public_visibility::text from form_registry_columns)
       || '; has_review_status=' || (select has_review_status::text from form_registry_columns)
union all
select 'public_tracking_sensitive_column_safety',
       true,
       'Public tracking must expose only tracking/status/next-step fields; verify in Browser UAT with real tracking_code.'
union all
select 'admin_transition_requires_auth_context',
       true,
       'SQL Editor cannot prove authenticated admin transition success; browser UAT with authenticated admin is required.'
union all
select 'no_waq_assets_mutation_in_this_script',
       true,
       'Read-only UAT. Mega M2.1 does not touch waqf schema or awqaf_system.';
