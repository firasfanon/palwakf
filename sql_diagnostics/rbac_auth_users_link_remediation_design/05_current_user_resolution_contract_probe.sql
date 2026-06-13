
-- READ ONLY
-- 05_current_user_resolution_contract_probe.sql
-- This probes whether the current session has an auth.uid() and whether it resolves to platform_access.admin_users.
-- Run as an authenticated user if possible.

select
  'current_auth_context' as section,
  auth.uid() as current_auth_uid,
  auth.role() as current_auth_role;

select
  'current_platform_access_admin_resolution' as section,
  au.id,
  au.email,
  au.name,
  au.role,
  au.is_superuser,
  au.is_active,
  au.unit_id
from platform_access.admin_users au
where au.id = auth.uid();
