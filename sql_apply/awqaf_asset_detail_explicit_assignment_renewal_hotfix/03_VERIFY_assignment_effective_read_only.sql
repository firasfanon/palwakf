-- 03_VERIFY_assignment_effective_read_only.sql

select
  'awqaf_asset_detail_assignment_effective_verify' as section,
  id,
  user_id,
  permission_code,
  scope_governorate_no,
  scope_lgu_code,
  is_active,
  valid_from,
  valid_until,
  revoked_at,
  now() as checked_at,
  (
    is_active = true
    and revoked_at is null
    and valid_from <= now()
    and (valid_until is null or valid_until > now())
  ) as currently_effective,
  false as production_approved
from waqf.waqf_asset_rbac_assignments
where user_id = '96f6cdc2-67f9-4352-b9f8-775ef509fed8'::uuid
  and permission_code = 'waqf.assets.super_admin'
  and scope_governorate_no is null
  and scope_lgu_code is null
order by created_at desc;

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
  'awqaf_asset_detail_simulated_auth_context_after_assignment_renewal' as section,
  auth.uid() as auth_uid,
  current_user,
  session_user,
  false as production_approved;

select
  'awqaf_asset_detail_read_access_function_smoke_after_assignment_renewal' as section,
  waqf.has_waqf_asset_read_access_v1('721abf33-b243-4bd2-9ece-577128c2fdf4'::uuid) as has_read_access,
  false as production_approved;

rollback;
