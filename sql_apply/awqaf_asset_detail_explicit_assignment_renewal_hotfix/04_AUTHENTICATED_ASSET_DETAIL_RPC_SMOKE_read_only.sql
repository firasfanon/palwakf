-- 04_AUTHENTICATED_ASSET_DETAIL_RPC_SMOKE_read_only.sql
-- Read-only smoke. Returns JSON if access is now effective.

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
  'awqaf_asset_detail_rpc_smoke_after_assignment_renewal' as section,
  public.rpc_waqf_asset_detail_v1('721abf33-b243-4bd2-9ece-577128c2fdf4'::uuid) as result,
  false as production_approved;

rollback;
