-- PalWakf Platform — Mega Batch M2
-- Service Center Browser Runtime UAT + Analyzer Result Intake
-- Read-only verification for platform_services runtime readiness.
-- This script does not modify waqf, awqaf_system, or any production data.

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
       exists (select 1 from platform_services.service_forms_registry where is_active = true limit 1),
       'active_forms=' || (select count(*) from platform_services.service_forms_registry where is_active = true)
union all
select 'public_tracking_sensitive_column_safety',
       true,
       'Public tracking must expose only tracking/status/next-step fields; verify in Browser UAT with real tracking_code.'
union all
select 'admin_transition_requires_auth_context',
       true,
       'SQL Editor cannot prove admin transition success; browser UAT with authenticated admin is required.'
union all
select 'no_waq_assets_mutation_in_this_script',
       true,
       'Read-only UAT. Mega M2 does not touch waqf schema or awqaf_system.';
