-- 06C_DASHBOARD_RPC_POST_FIX_SMOKE.sql
-- Run after 03A and after a valid authenticated SQL context is set.
-- This script uses the known admin/browser user.

begin;
set local role authenticated;

select set_config(
  'request.jwt.claim.sub',
  '96f6cdc2-67f9-4352-b9f8-775ef509fed8',
  true
);

select set_config(
  'request.jwt.claims',
  '{"sub":"96f6cdc2-67f9-4352-b9f8-775ef509fed8","role":"authenticated","email":"firasfanon@gmail.com"}',
  true
);

select
  'platform_technical_dashboard_rpc_post_fix_smoke' as section,
  jsonb_typeof(public.rpc_platform_technical_services_dashboard_v1()) as dashboard_json_type,
  public.rpc_platform_technical_services_dashboard_v1() ? 'metrics' as has_metrics,
  public.rpc_platform_technical_services_dashboard_v1() ? 'backups' as has_backups,
  public.rpc_platform_technical_services_dashboard_v1() ? 'health_checks' as has_health_checks,
  public.rpc_platform_technical_services_dashboard_v1() ? 'audit_events' as has_audit_events,
  false as production_approved;

rollback;
