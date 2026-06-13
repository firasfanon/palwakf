select
  'platform_technical_workflow_rpc_presence_verify' as section,
  to_regprocedure('public.rpc_platform_technical_service_request_transition_v1(uuid,text,text,jsonb)') is not null as request_transition_rpc,
  to_regprocedure('public.rpc_platform_backup_registry_record_create_v1(uuid,text,text,text,text,text,text,bigint,timestamptz,text)') is not null as backup_registry_record_rpc,
  to_regprocedure('public.rpc_platform_maintenance_window_transition_v1(uuid,text,text)') is not null as maintenance_window_transition_rpc,
  to_regprocedure('public.rpc_platform_maintenance_status_v1()') is not null as maintenance_status_rpc,
  to_regprocedure('public.rpc_platform_technical_audit_events_v1(text,text,integer)') is not null as audit_filter_rpc,
  false as production_approved;

select
  'platform_maintenance_status_public_smoke' as section,
  jsonb_typeof(public.rpc_platform_maintenance_status_v1()) as json_type,
  public.rpc_platform_maintenance_status_v1() ? 'maintenance_active' as has_maintenance_active,
  public.rpc_platform_maintenance_status_v1() ? 'planned_windows' as has_planned_windows,
  false as production_approved;
