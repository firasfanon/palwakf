-- 06A_AUTHENTICATED_RPC_SMOKE_KNOWN_USER.sql
-- Concrete SQL Editor smoke for the known browser user.
--
-- Known user:
--   96f6cdc2-67f9-4352-b9f8-775ef509fed8
--
-- If this user is not present in public.admin_users or does not hold an admin/superuser role,
-- this script will correctly fail with PLATFORM_TECHNICAL_FORBIDDEN.
-- In that case, run the admin user probe below and use the proper auth.users UUID.

select
  'platform_technical_known_user_admin_probe' as section,
  au.*,
  false as production_approved
from public.admin_users au
where au.id = '96f6cdc2-67f9-4352-b9f8-775ef509fed8'::uuid;

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
  'platform_technical_auth_context_smoke' as section,
  auth.uid() as auth_uid,
  current_user,
  session_user,
  false as production_approved;

select
  'platform_technical_dashboard_rpc_smoke' as section,
  jsonb_typeof(public.rpc_platform_technical_services_dashboard_v1()) as dashboard_json_type,
  public.rpc_platform_technical_services_dashboard_v1() ? 'metrics' as has_metrics,
  public.rpc_platform_technical_services_dashboard_v1() ? 'requests' as has_requests,
  public.rpc_platform_technical_services_dashboard_v1() ? 'health_checks' as has_health_checks,
  false as production_approved;

select
  'platform_technical_health_refresh_rpc_smoke' as section,
  jsonb_typeof(public.rpc_platform_technical_health_snapshot_refresh_v1()) as dashboard_json_type_after_refresh,
  false as production_approved;

rollback;
