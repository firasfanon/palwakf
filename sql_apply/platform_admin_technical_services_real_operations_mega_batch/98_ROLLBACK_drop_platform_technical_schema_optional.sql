-- 98_ROLLBACK_drop_platform_technical_schema_optional.sql
-- OPTIONAL. Destructive for platform_technical only.
-- Do not run unless rollback is explicitly required.

begin;
drop schema if exists platform_technical cascade;
drop function if exists public.rpc_platform_technical_services_dashboard_v1();
drop function if exists public.rpc_platform_technical_service_request_create_v1(text,text,text,text,text,timestamptz,jsonb);
drop function if exists public.rpc_platform_maintenance_window_create_v1(text,text,timestamptz,timestamptz,text[]);
drop function if exists public.rpc_platform_technical_release_record_create_v1(text,text,text,text);
drop function if exists public.rpc_platform_technical_health_snapshot_refresh_v1();
commit;

select
  'platform_technical_optional_rollback_completed' as section,
  false as production_approved;
