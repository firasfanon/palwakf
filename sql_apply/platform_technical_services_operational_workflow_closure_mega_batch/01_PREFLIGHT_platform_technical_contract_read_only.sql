select
  'platform_technical_workflow_preflight' as section,
  to_regnamespace('platform_technical') is not null as platform_technical_schema_exists,
  to_regclass('platform_technical.technical_service_requests') is not null as requests_table_exists,
  to_regclass('platform_technical.maintenance_windows') is not null as maintenance_windows_table_exists,
  to_regclass('platform_technical.backup_registry') is not null as backup_registry_table_exists,
  to_regclass('platform_technical.audit_events') is not null as audit_events_table_exists,
  to_regprocedure('public.rpc_platform_technical_services_dashboard_v1()') is not null as dashboard_rpc_exists,
  false as production_approved;
