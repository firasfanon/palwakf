-- OPTIONAL: reduce recursion risk by removing direct EXISTS(user_system_permissions)
-- from user_system_roles policies and using has_permission() instead.
--
-- Run ONLY if you are experiencing recursion/stack depth issues.

drop policy if exists platform_admin_select_user_system_roles on public.user_system_roles;
drop policy if exists platform_admin_write_user_system_roles  on public.user_system_roles;

create policy platform_admin_select_user_system_roles
on public.user_system_roles
for select
using (
  is_superuser()
  or has_permission('platformAdmin'::system_key, 'manageUsers'::text)
);

create policy platform_admin_write_user_system_roles
on public.user_system_roles
for all
using (
  is_superuser()
  or has_permission('platformAdmin'::system_key, 'manageUsers'::text)
)
with check (
  is_superuser()
  or has_permission('platformAdmin'::system_key, 'manageUsers'::text)
);
