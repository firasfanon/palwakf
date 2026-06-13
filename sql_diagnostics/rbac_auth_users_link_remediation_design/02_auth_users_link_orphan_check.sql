
-- READ ONLY
-- 02_auth_users_link_orphan_check.sql
-- Checks whether platform_access.admin_users.id values exist in auth.users.id.

select
  'platform_access_admin_to_auth_orphans' as section,
  count(*)::bigint as orphan_count
from platform_access.admin_users au
left join auth.users u
  on u.id = au.id
where u.id is null;

select
  'platform_access_admin_to_auth_sample_orphans' as section,
  au.id,
  au.email,
  au.name,
  au.role,
  au.is_active
from platform_access.admin_users au
left join auth.users u
  on u.id = au.id
where u.id is null
order by au.created_at nulls last, au.email
limit 25;

select
  'platform_access_admin_to_auth_matches' as section,
  count(*)::bigint as matched_count
from platform_access.admin_users au
join auth.users u
  on u.id = au.id;
