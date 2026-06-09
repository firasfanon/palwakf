-- Mega Batch N2.9D — Usage Guide RBAC Scope Evidence Read-only
-- Purpose: verify the sample restricted user has no system roles/permissions,
-- so the usage guide should show only common active-admin documents.
-- Read-only evidence only. No DML. No waqf/waqf_assets mutation.

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
), grants as (
  select
    tu.id,
    count(distinct usr.system_key::text) filter (where usr.system_key is not null) as system_roles_count,
    count(distinct usp.permission_key) filter (where usp.permission_key is not null and coalesce(usp.allow, true) is true) as allowed_permissions_count,
    string_agg(distinct usr.system_key::text, ', ' order by usr.system_key::text) filter (where usr.system_key is not null) as systems,
    string_agg(distinct usr.role::text, ', ' order by usr.role::text) filter (where usr.role is not null) as roles,
    string_agg(distinct usp.permission_key, ', ' order by usp.permission_key) filter (where usp.permission_key is not null and coalesce(usp.allow, true) is true) as permissions
  from target_user tu
  left join public.user_system_roles usr on usr.user_id = tu.id
  left join public.user_system_permissions usp on usp.user_id = tu.id
  group by tu.id
)
select 'usage_guide_scope' as section,
       'bthusr1_has_no_operational_grants' as check_key,
       (coalesce(g.system_roles_count, 0) = 0 and coalesce(g.allowed_permissions_count, 0) = 0) as passed,
       concat('system_roles=', coalesce(g.system_roles_count, 0), '; allowed_permissions=', coalesce(g.allowed_permissions_count, 0), '; expected visible docs: platform_general + assistant_binding only') as note
from target_user tu
left join grants g on g.id = tu.id
union all
select 'sovereign_boundary',
       'no_waq_assets_mutation_in_this_script',
       true,
       'Read-only evidence only; no waqf/waqf_assets DML.';
