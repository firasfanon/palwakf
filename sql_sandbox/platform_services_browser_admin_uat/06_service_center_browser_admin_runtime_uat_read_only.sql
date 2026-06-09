-- Mega Batch M3 — Service Center Browser Admin Runtime UAT Read-only Verification
-- Purpose: verify backend/runtime readiness after Browser Admin UAT without mutating data.
-- Scope: platform_services + public RPC catalog checks only.
-- Safety: no INSERT/UPDATE/DELETE/ALTER/DROP and no waqf/awqaf_system mutation.

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
), required_rpcs as (
  select unnest(array[
    'rpc_services_forms_public_v1',
    'rpc_services_submit_request_v1',
    'rpc_services_track_request_public_v1',
    'rpc_services_admin_request_queue_v1',
    'rpc_services_admin_transition_request_v1'
  ]) as function_name
), installed_rpcs as (
  select p.proname as function_name
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
), form_counts as (
  select count(*)::int as runtime_forms
  from platform_services.service_forms_registry f
  where coalesce((to_jsonb(f)->>'public_visibility')::boolean, false) = true
    and coalesce(to_jsonb(f)->>'review_status', '') = 'approved'
    and (
      to_jsonb(f)->>'effective_to' is null
      or (to_jsonb(f)->>'effective_to')::date >= current_date
    )
), request_counts as (
  select
    count(*)::int as total_requests,
    count(*) filter (where status = 'received')::int as received_requests,
    count(*) filter (where status = 'triage')::int as triage_requests,
    count(*) filter (where status = 'under_review')::int as under_review_requests,
    count(*) filter (where status = 'waiting_applicant')::int as waiting_applicant_requests,
    count(*) filter (where status = 'routed')::int as routed_requests,
    count(*) filter (where status = 'closed')::int as closed_requests
  from platform_services.service_requests
), event_counts as (
  select count(*)::int as workflow_events
  from platform_services.service_request_status_events
), latest_requests as (
  select coalesce(jsonb_agg(jsonb_build_object(
    'tracking_code', tracking_code,
    'status', status,
    'created_at', created_at,
    'updated_at', updated_at
  ) order by created_at desc), '[]'::jsonb) as latest_json
  from (
    select tracking_code, status, created_at, updated_at
    from platform_services.service_requests
    order by created_at desc
    limit 5
  ) s
)
select * from (
  select
    'platform_services_required_tables' as check_key,
    (select count(*) from required_tables r join installed_tables i using(table_name)) = 4 as passed,
    'installed=' || (select count(*) from required_tables r join installed_tables i using(table_name)) || '/4' as note
  union all
  select
    'public_service_center_runtime_rpcs_exist',
    (select count(*) from required_rpcs r join installed_rpcs i using(function_name)) = 5,
    'installed=' || (select count(*) from required_rpcs r join installed_rpcs i using(function_name)) || '/5'
  union all
  select
    'runtime_forms_available_for_browser_uat',
    (select runtime_forms from form_counts) > 0,
    'runtime_forms=' || (select runtime_forms from form_counts)
  union all
  select
    'browser_submit_request_evidence_present',
    (select total_requests from request_counts) > 0,
    'total_requests=' || (select total_requests from request_counts) || '; latest=' || (select latest_json::text from latest_requests)
  union all
  select
    'workflow_events_evidence_present',
    (select workflow_events from event_counts) > 0,
    'workflow_events=' || (select workflow_events from event_counts) || '; expected after admin transition Browser UAT'
  union all
  select
    'admin_transition_requires_browser_jwt_context',
    true,
    'SQL Editor cannot prove authenticated admin transition success; use Browser Admin account and verify request status/events here.'
  union all
  select
    'public_tracking_sensitive_column_safety',
    true,
    'Browser UAT must verify tracking page exposes tracking/status/next-step only, not requester sensitive data.'
  union all
  select
    'no_waq_assets_mutation_in_this_script',
    true,
    'Read-only UAT. This script does not touch waqf schema or awqaf_system.'
) checks
order by check_key;
