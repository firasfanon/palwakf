
-- DRAFT ONLY - DO NOT APPLY
-- Path B: logical auth contract helper.
-- Exact function names and permissions must be reviewed before apply.

create or replace function platform_access.current_admin_user_id_v1()
returns uuid
language sql
stable
security definer
set search_path = platform_access, public, auth
as $$
  select au.id
  from platform_access.admin_users au
  where au.id = auth.uid()
    and coalesce(au.is_active, true) = true
  limit 1
$$;

-- Example usage in RLS/RPC:
-- platform_access.current_admin_user_id_v1() is not null
