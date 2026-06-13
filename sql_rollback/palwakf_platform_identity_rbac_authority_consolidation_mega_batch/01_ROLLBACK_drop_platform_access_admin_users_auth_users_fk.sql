
-- PALWAKF_PLATFORM_IDENTITY_RBAC_AUTHORITY_CONSOLIDATION_MEGA_BATCH
-- 01_ROLLBACK_drop_platform_access_admin_users_auth_users_fk.sql
--
-- ROLLBACK ONLY.
-- Drops only the FK created by this Mega Batch.
-- Does not delete data.
-- Does not modify RLS.
-- Does not touch auth.users.

alter table platform_access.admin_users
  drop constraint if exists platform_access_admin_users_id_auth_users_id_fk;

select
  'rollback_rbac_auth_users_fk_drop_result' as section,
  not exists (
    select 1
    from pg_constraint con
    join pg_class rel
      on rel.oid = con.conrelid
    join pg_namespace nsp
      on nsp.oid = rel.relnamespace
    where nsp.nspname = 'platform_access'
      and rel.relname = 'admin_users'
      and con.conname = 'platform_access_admin_users_id_auth_users_id_fk'
  ) as constraint_absent_after_rollback,
  true as rollback_executed,
  false as production_approved;
