begin;
set local role authenticated;

select set_config('request.jwt.claim.sub','96f6cdc2-67f9-4352-b9f8-775ef509fed8',true);
select set_config('request.jwt.claims','{"sub":"96f6cdc2-67f9-4352-b9f8-775ef509fed8","role":"authenticated","email":"firasfanon@gmail.com"}',true);

with request_created as (
  select public.rpc_platform_technical_service_request_create_v1(
    'backup',
    'uat_backup_metadata_request',
    'UAT backup metadata request',
    'Smoke request created by workflow closure batch.',
    'low',
    null,
    jsonb_build_object('smoke', true)
  ) as request_id
),
request_approved as (
  select public.rpc_platform_technical_service_request_transition_v1(
    request_id,
    'approve',
    'Smoke approve',
    jsonb_build_object('smoke', true)
  ) as dashboard_after_approve,
  request_id
  from request_created
),
backup_recorded as (
  select public.rpc_platform_backup_registry_record_create_v1(
    request_id,
    'database',
    'supabase',
    'UAT metadata backup record',
    null,
    'recorded',
    null,
    null,
    null,
    'Smoke metadata only; no export executed.'
  ) as backup_id
  from request_approved
)
select
  'platform_technical_workflow_smoke_result' as section,
  (select request_id from request_created) as request_id,
  (select backup_id from backup_recorded) as backup_id,
  jsonb_typeof(public.rpc_platform_technical_services_dashboard_v1()) as dashboard_json_type,
  false as backup_export_executed,
  false as production_approved;

rollback;
