
-- OPTIONAL CLEANUP - DO NOT RUN UNLESS OPERATOR CHOOSES SCHEMA HYGIENE CLEANUP
-- Purpose:
-- Drop only the redundant FK created by the consolidation mega batch.
--
-- This preserves the pre-existing FK:
-- admin_users_id_fkey
-- FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE
--
-- It does not delete data.
-- It does not modify RLS.
-- It does not touch auth.users.
-- It does not change Flutter.

alter table platform_access.admin_users
  drop constraint if exists platform_access_admin_users_id_auth_users_id_fk;

select
  'rbac_duplicate_fk_cleanup_result' as section,
  exists (
    select 1
    from pg_constraint con
    join pg_class rel on rel.oid = con.conrelid
    join pg_namespace nsp on nsp.oid = rel.relnamespace
    where nsp.nspname = 'platform_access'
      and rel.relname = 'admin_users'
      and con.conname = 'admin_users_id_fkey'
  ) as original_auth_fk_still_present,
  not exists (
    select 1
    from pg_constraint con
    join pg_class rel on rel.oid = con.conrelid
    join pg_namespace nsp on nsp.oid = rel.relnamespace
    where nsp.nspname = 'platform_access'
      and rel.relname = 'admin_users'
      and con.conname = 'platform_access_admin_users_id_auth_users_id_fk'
  ) as duplicate_fk_removed,
  false as production_approved;
