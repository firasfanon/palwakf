
-- READ ONLY
-- 03_auth_users_email_consistency_check.sql
-- Checks email consistency for rows where IDs match.

select
  'platform_access_auth_email_mismatch_count' as section,
  count(*)::bigint as mismatch_count
from platform_access.admin_users au
join auth.users u
  on u.id = au.id
where lower(coalesce(au.email, '')) <> lower(coalesce(u.email, ''));

select
  'platform_access_auth_email_mismatch_sample' as section,
  au.id,
  au.email as platform_access_email,
  u.email as auth_email,
  au.name,
  au.role
from platform_access.admin_users au
join auth.users u
  on u.id = au.id
where lower(coalesce(au.email, '')) <> lower(coalesce(u.email, ''))
order by au.email
limit 25;
