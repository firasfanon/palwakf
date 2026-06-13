
-- PALWAKF_PLATFORM_IDENTITY_RBAC_AUTHORITY_CONSOLIDATION_MEGA_BATCH
-- 01_AUTHORIZED_APPLY_platform_access_admin_users_auth_users_fk.sql
--
-- AUTHORIZED DDL APPLY CANDIDATE.
-- User authorization was supplied in chat:
-- - FK between platform_access.admin_users.id and auth.users.id
-- - verification read-only after execution
-- - rollback SQL
-- - smoke/tests/docs
-- - no service_role in Flutter
-- - no automatic production approval
--
-- This script:
-- 1. Re-checks orphan and email mismatch counts.
-- 2. Adds FK as NOT VALID if absent.
-- 3. Validates FK.
-- 4. Emits result rows.
--
-- Constraint name:
-- platform_access_admin_users_id_auth_users_id_fk

do $$
declare
  orphan_count bigint;
  email_mismatch_count bigint;
  matched_count bigint;
  platform_count bigint;
  auth_count bigint;
  constraint_exists boolean;
begin
  select count(*) into platform_count
  from platform_access.admin_users;

  select count(*) into auth_count
  from auth.users;

  select count(*) into matched_count
  from platform_access.admin_users pa
  join auth.users au
    on au.id = pa.id;

  select count(*) into orphan_count
  from platform_access.admin_users pa
  left join auth.users au
    on au.id = pa.id
  where au.id is null;

  select count(*) into email_mismatch_count
  from platform_access.admin_users pa
  join auth.users au
    on au.id = pa.id
  where lower(coalesce(pa.email, '')) <> lower(coalesce(au.email, ''));

  if orphan_count <> 0 then
    raise exception
      'RBAC FK apply blocked: orphan_count=%; platform_access.admin_users rows without auth.users match exist',
      orphan_count;
  end if;

  if email_mismatch_count <> 0 then
    raise exception
      'RBAC FK apply blocked: email_mismatch_count=%; platform_access/admin auth email mismatch exists',
      email_mismatch_count;
  end if;

  if platform_count <> matched_count then
    raise exception
      'RBAC FK apply blocked: platform_count=% matched_count=%',
      platform_count,
      matched_count;
  end if;

  select exists (
    select 1
    from pg_constraint con
    join pg_class rel
      on rel.oid = con.conrelid
    join pg_namespace nsp
      on nsp.oid = rel.relnamespace
    where nsp.nspname = 'platform_access'
      and rel.relname = 'admin_users'
      and con.conname = 'platform_access_admin_users_id_auth_users_id_fk'
  ) into constraint_exists;

  if not constraint_exists then
    alter table platform_access.admin_users
      add constraint platform_access_admin_users_id_auth_users_id_fk
      foreign key (id)
      references auth.users(id)
      not valid;
  end if;

  alter table platform_access.admin_users
    validate constraint platform_access_admin_users_id_auth_users_id_fk;

  comment on constraint platform_access_admin_users_id_auth_users_id_fk
    on platform_access.admin_users
    is 'PalWakf RBAC authority link: platform_access.admin_users.id references auth.users.id. Added by PALWAKF_PLATFORM_IDENTITY_RBAC_AUTHORITY_CONSOLIDATION_MEGA_BATCH.';
end $$;

select
  'rbac_auth_users_fk_apply_result' as section,
  con.conname as constraint_name,
  nsp.nspname as table_schema,
  rel.relname as table_name,
  con.convalidated as validated,
  pg_get_constraintdef(con.oid) as constraint_definition,
  true as ddl_authorized_by_user,
  false as production_approved
from pg_constraint con
join pg_class rel
  on rel.oid = con.conrelid
join pg_namespace nsp
  on nsp.oid = rel.relnamespace
where nsp.nspname = 'platform_access'
  and rel.relname = 'admin_users'
  and con.conname = 'platform_access_admin_users_id_auth_users_id_fk';
