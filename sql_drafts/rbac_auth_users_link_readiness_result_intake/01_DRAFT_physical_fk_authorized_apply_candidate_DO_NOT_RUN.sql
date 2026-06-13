
-- DRAFT ONLY - DO NOT APPLY WITHOUT EXPLICIT DDL AUTHORIZATION
-- RBAC Auth Users Link — Physical FK Apply Candidate
--
-- Evidence accepted:
-- platform_access.admin_users = 86
-- auth.users = 86
-- matched_by_id = 86
-- orphan_admin_users = 0
-- email_mismatch = 0
--
-- Recommended decision:
-- RBAC_AUTH_USERS_PHYSICAL_FK_READY_FOR_AUTHORIZED_APPLY_DESIGN
--
-- This script is intentionally a draft. It must not be run unless a separate
-- apply batch is authorized.

begin;

alter table platform_access.admin_users
  add constraint platform_access_admin_users_id_auth_users_id_fk
  foreign key (id)
  references auth.users(id)
  not valid;

-- Validation may be executed in the same transaction only if approved.
-- Preferred operational pattern is to validate in a separate controlled step:
alter table platform_access.admin_users
  validate constraint platform_access_admin_users_id_auth_users_id_fk;

commit;

-- Rollback candidate:
-- alter table platform_access.admin_users
--   drop constraint if exists platform_access_admin_users_id_auth_users_id_fk;
