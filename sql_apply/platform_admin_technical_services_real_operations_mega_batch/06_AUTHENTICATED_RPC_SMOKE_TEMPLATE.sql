-- 06_AUTHENTICATED_RPC_SMOKE_TEMPLATE.sql
-- Replace the UUID below with an actual authenticated admin user's auth.users.id.
-- This script is intended for SQL editor smoke only.

begin;
set local role authenticated;

select set_config('request.jwt.claim.sub', '<AUTH_USER_UUID_HERE>', true);
select set_config('request.jwt.claims', '{"sub":"<AUTH_USER_UUID_HERE>","role":"authenticated"}', true);

select
  'platform_technical_dashboard_rpc_smoke' as section,
  jsonb_typeof(public.rpc_platform_technical_services_dashboard_v1()) as dashboard_json_type,
  public.rpc_platform_technical_services_dashboard_v1() ? 'metrics' as has_metrics,
  public.rpc_platform_technical_services_dashboard_v1() ? 'requests' as has_requests,
  false as production_approved;

rollback;
