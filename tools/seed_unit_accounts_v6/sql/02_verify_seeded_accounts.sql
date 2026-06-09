select
  au.username,
  au.email,
  au.role,
  au.is_superuser,
  au.unit_id,
  u.slug,
  u.name_ar
from public.admin_users au
left join core.org_units u on u.id = au.unit_id
where au.username like '%usr1'
   or au.username like '%usr2'
order by au.username;
