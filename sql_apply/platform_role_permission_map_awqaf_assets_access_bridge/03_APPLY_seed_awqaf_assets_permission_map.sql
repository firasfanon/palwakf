begin;

insert into platform_access.platform_role_permission_map (
  platform_role,
  system_key,
  permission_code,
  permission_group,
  scope_policy,
  is_active,
  notes
)
values
  ('super_admin', 'awqaf_system', 'waqf.assets.super_admin', 'waqf_assets', 'global', true, 'Platform super_admin maps to waqf asset sovereign super admin.'),
  ('admin', 'awqaf_system', 'waqf.assets.manage', 'waqf_assets', 'inherit_assignment_scope', true, 'Platform admin maps to waqf asset management.'),
  ('admin', 'awqaf_system', 'waqf.assets.review', 'waqf_assets', 'inherit_assignment_scope', true, 'Platform admin maps to waqf asset review.'),
  ('admin', 'awqaf_system', 'waqf.assets.read', 'waqf_assets', 'inherit_assignment_scope', true, 'Platform admin maps to waqf asset read.'),
  ('manager', 'awqaf_system', 'waqf.assets.review', 'waqf_assets', 'inherit_assignment_scope', true, 'Platform manager maps to waqf asset review.'),
  ('manager', 'awqaf_system', 'waqf.assets.read', 'waqf_assets', 'inherit_assignment_scope', true, 'Platform manager maps to waqf asset read.'),
  ('employee', 'awqaf_system', 'waqf.assets.read', 'waqf_assets', 'inherit_assignment_scope', true, 'Platform employee maps to waqf asset read.'),
  ('viewer', 'awqaf_system', 'waqf.assets.read', 'waqf_assets', 'inherit_assignment_scope', true, 'Platform viewer maps to waqf asset read.')
on conflict (platform_role, system_key, permission_code, scope_policy)
do update set
  permission_group = excluded.permission_group,
  is_active = excluded.is_active,
  notes = excluded.notes,
  updated_at = now();

commit;

select
  'platform_role_permission_map_awqaf_assets_seed_applied' as section,
  platform_role,
  system_key,
  permission_code,
  permission_group,
  scope_policy,
  is_active,
  false as production_approved
from platform_access.platform_role_permission_map
where system_key = 'awqaf_system'
  and permission_group = 'waqf_assets'
order by platform_role, permission_code;
