select
  'platform_technical_evidence_notifications_presence_verify' as section,
  to_regclass('platform_technical.technical_service_evidence') is not null as evidence_table,
  to_regclass('platform_technical.technical_notifications') is not null as notifications_table,
  to_regclass('platform_technical.technical_operation_decisions') is not null as decisions_table,
  to_regprocedure('public.rpc_platform_technical_evidence_add_v1(uuid,text,text,text,text,text,text,text,timestamptz,jsonb)') is not null as evidence_add_rpc,
  to_regprocedure('public.rpc_platform_technical_operation_decision_record_v1(uuid,text,text,text,jsonb)') is not null as decision_record_rpc,
  to_regprocedure('public.rpc_platform_technical_notification_mark_read_v1(uuid)') is not null as notification_mark_read_rpc,
  false as production_approved;

begin;
set local role authenticated;

select set_config('request.jwt.claim.sub','96f6cdc2-67f9-4352-b9f8-775ef509fed8',true);
select set_config('request.jwt.claims','{"sub":"96f6cdc2-67f9-4352-b9f8-775ef509fed8","role":"authenticated","email":"firasfanon@gmail.com"}',true);

select
  'platform_technical_dashboard_enriched_smoke' as section,
  jsonb_typeof(public.rpc_platform_technical_services_dashboard_v1()) as dashboard_json_type,
  public.rpc_platform_technical_services_dashboard_v1() ? 'evidence' as has_evidence,
  public.rpc_platform_technical_services_dashboard_v1() ? 'notifications' as has_notifications,
  public.rpc_platform_technical_services_dashboard_v1() ? 'operation_decisions' as has_operation_decisions,
  false as production_approved;

rollback;
