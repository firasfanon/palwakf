select
  au.id,
  au.username,
  au.email,
  au.role,
  au.is_superuser,
  au.unit_id
from public.admin_users au
where coalesce(au.is_active, true) = true
  and coalesce(au.is_superuser, false) = false
  and lower(coalesce(au.role, '')) not in ('super_admin', 'superuser', 'platformadmin', 'platform_admin')
  and au.unit_id is null
order by au.username;
