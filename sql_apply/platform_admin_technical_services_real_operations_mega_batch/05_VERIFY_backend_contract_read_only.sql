-- 05_VERIFY_backend_contract_read_only.sql

select
  'platform_technical_table_presence_verify' as section,
  to_regclass('platform_technical.technical_service_requests') is not null as requests_table,
  to_regclass('platform_technical.maintenance_windows') is not null as maintenance_windows_table,
  to_regclass('platform_technical.backup_registry') is not null as backup_registry_table,
  to_regclass('platform_technical.health_checks') is not null as health_checks_table,
  to_regclass('platform_technical.release_records') is not null as release_records_table,
  to_regclass('platform_technical.audit_events') is not null as audit_events_table,
  false as production_approved;

select
  'platform_technical_rpc_presence_verify' as section,
  to_regprocedure('public.rpc_platform_technical_services_dashboard_v1()') is not null as dashboard_rpc,
  to_regprocedure('public.rpc_platform_technical_service_request_create_v1(text,text,text,text,text,timestamptz,jsonb)') is not null as create_request_rpc,
  to_regprocedure('public.rpc_platform_maintenance_window_create_v1(text,text,timestamptz,timestamptz,text[])') is not null as maintenance_window_rpc,
  to_regprocedure('public.rpc_platform_technical_release_record_create_v1(text,text,text,text)') is not null as release_record_rpc,
  to_regprocedure('public.rpc_platform_technical_health_snapshot_refresh_v1()') is not null as health_refresh_rpc,
  false as production_approved;

select
  'platform_technical_counts_verify' as section,
  (select count(*) from platform_technical.technical_service_requests) as requests_count,
  (select count(*) from platform_technical.maintenance_windows) as maintenance_windows_count,
  (select count(*) from platform_technical.backup_registry) as backup_registry_count,
  (select count(*) from platform_technical.health_checks) as health_checks_count,
  (select count(*) from platform_technical.release_records) as release_records_count,
  (select count(*) from platform_technical.audit_events) as audit_events_count,
  false as production_approved;
