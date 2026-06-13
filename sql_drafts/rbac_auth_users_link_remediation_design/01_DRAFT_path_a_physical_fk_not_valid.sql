
-- DRAFT ONLY - DO NOT APPLY
-- Path A: physical FK from platform_access.admin_users.id to auth.users.id.
-- Preconditions:
-- 1. orphan_count = 0 from 02_auth_users_link_orphan_check.sql
-- 2. email mismatches reviewed
-- 3. dependency impact reviewed
-- 4. explicit DDL authorization granted
-- 5. rollback plan approved

alter table platform_access.admin_users
  add constraint platform_access_admin_users_id_auth_users_id_fk
  foreign key (id)
  references auth.users(id)
  not valid;

-- Validate separately after monitoring:
alter table platform_access.admin_users
  validate constraint platform_access_admin_users_id_auth_users_id_fk;

-- Rollback draft:
-- alter table platform_access.admin_users
--   drop constraint if exists platform_access_admin_users_id_auth_users_id_fk;
