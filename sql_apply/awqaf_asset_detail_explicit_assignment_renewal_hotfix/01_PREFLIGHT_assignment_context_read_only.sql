-- 01_PREFLIGHT_assignment_context_read_only.sql
-- Read-only.

select
  'target_user_probe' as section,
  id,
  email,
  created_at,
  false as production_approved
from auth.users
where id = '96f6cdc2-67f9-4352-b9f8-775ef509fed8'::uuid;

select
  'target_permission_probe' as section,
  permission_code,
  permission_group,
  permission_name_ar,
  permission_name_en,
  is_active,
  false as production_approved
from waqf.waqf_asset_rbac_permissions
where permission_code = 'waqf.assets.super_admin';

select
  'target_asset_scope_probe' as section,
  id,
  national_asset_code,
  asset_name_ar,
  governorate_no,
  governorate_name,
  lgu_code,
  lgu_name,
  asset_status,
  is_deleted,
  false as production_approved
from waqf.waqf_assets
where id = '721abf33-b243-4bd2-9ece-577128c2fdf4'::uuid;

select
  'target_existing_assignment_probe' as section,
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
order by created_at desc;
