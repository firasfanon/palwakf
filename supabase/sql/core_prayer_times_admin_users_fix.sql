-- =========================================================
-- PalWakf (Sovereign) - Fix admin_users linkage for Prayer Times
--
-- Issue:
--   ERROR: 42703: column au.user_id does not exist
--
-- Assumption (platform default): public.admin_users.id is the same UUID as auth.users.id
-- If your platform uses a different column (e.g. auth_user_id), adjust the WHERE accordingly.
-- =========================================================

create schema if not exists core;

create or replace function core.pwf_is_admin_user()
returns boolean
language sql
stable
security definer
set search_path = public, core
as $$
  select exists (
    select 1
    from public.admin_users au
    where au.id = auth.uid()
  );
$$;

revoke all on function core.pwf_is_admin_user() from public;
grant execute on function core.pwf_is_admin_user() to anon, authenticated;
