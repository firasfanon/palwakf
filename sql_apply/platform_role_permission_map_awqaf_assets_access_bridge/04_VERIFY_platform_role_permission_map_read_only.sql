select
  'platform_role_permission_map_verify_counts_read_only' as section,
  system_key,
  permission_group,
  platform_role,
  count(*) as permission_count,
  false as production_approved
from platform_access.platform_role_permission_map
where is_active = true
group by system_key, permission_group, platform_role
order by system_key, permission_group, platform_role;

select
  'platform_role_permission_map_verify_awqaf_join_read_only' as section,
  m.platform_role,
  m.system_key,
  m.permission_code,
  m.scope_policy,
  p.permission_name_ar,
  p.permission_name_en,
  p.is_active as waqf_permission_active,
  m.is_active as map_active,
  false as production_approved
from platform_access.platform_role_permission_map m
left join waqf.waqf_asset_rbac_permissions p
  on p.permission_code = m.permission_code
where m.system_key = 'awqaf_system'
  and m.permission_group = 'waqf_assets'
order by m.platform_role, m.permission_code;
