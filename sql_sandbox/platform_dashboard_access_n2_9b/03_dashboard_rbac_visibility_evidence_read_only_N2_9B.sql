-- Mega Batch N2.9B — Dashboard RBAC Visibility Evidence
-- Read-only evidence only. No waqf/waqf_assets DML.

with target_user as (
  select
    au.id,
    au.email,
    au.username,
    au.name,
    au.role as admin_role,
    au.is_active,
    au.is_superuser,
    au.unit_id
  from public.admin_users au
  where lower(au.username) = lower('bthusr1')
     or lower(au.email) = lower('bthusr1@palwakf.local')
), role_rows as (
  select
    usr.user_id,
    count(*) as role_rows,
    string_agg(distinct usr.system_key::text, ', ' order by usr.system_key::text) as systems,
    string_agg(distinct usr.role::text, ', ' order by usr.role::text) as roles
  from public.user_system_roles usr
  join target_user tu on tu.id = usr.user_id
  group by usr.user_id
), permission_rows as (
  select
    usp.user_id,
    count(*) filter (where usp.allow is true) as allowed_permission_rows,
    string_agg(distinct usp.permission_key, ', ' order by usp.permission_key) filter (where usp.allow is true) as permissions
  from public.user_system_permissions usp
  join target_user tu on tu.id = usp.user_id
  group by usp.user_id
)
select
  'dashboard_rbac_visibility' as section,
  tu.email,
  tu.username,
  tu.admin_role,
  tu.is_active,
  tu.is_superuser,
  coalesce(rr.role_rows, 0) as role_rows,
  coalesce(pr.allowed_permission_rows, 0) as allowed_permission_rows,
  coalesce(rr.systems, '') as systems,
  coalesce(rr.roles, '') as roles,
  coalesce(pr.permissions, '') as permissions,
  case
    when tu.is_superuser is true then 'superuser_dashboard_expected'
    when coalesce(rr.role_rows, 0) = 0 and coalesce(pr.allowed_permission_rows, 0) = 0 then 'restricted_dashboard_expected'
    else 'rbac_filtered_dashboard_expected'
  end as expected_dashboard_mode,
  true as no_waq_assets_mutation_in_this_script
from target_user tu
left join role_rows rr on rr.user_id = tu.id
left join permission_rows pr on pr.user_id = tu.id;
