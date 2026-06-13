select
  'platform_role_permission_map_preflight_schemas_read_only' as section,
  to_regnamespace('platform_access') is not null as platform_access_schema_present,
  to_regnamespace('waqf') is not null as waqf_schema_present,
  false as production_approved;

select
  'platform_role_permission_map_preflight_platform_roles_read_only' as section,
  role,
  count(*) as users_count,
  false as production_approved
from public.admin_users
group by role
order by role;

select
  'platform_role_permission_map_preflight_waqf_permissions_read_only' as section,
  permission_code,
  permission_group,
  permission_name_ar,
  permission_name_en,
  is_active,
  false as production_approved
from waqf.waqf_asset_rbac_permissions
where permission_code in (
  'waqf.assets.read',
  'waqf.assets.review',
  'waqf.assets.manage',
  'waqf.assets.approve',
  'waqf.assets.super_admin'
)
order by permission_code;
