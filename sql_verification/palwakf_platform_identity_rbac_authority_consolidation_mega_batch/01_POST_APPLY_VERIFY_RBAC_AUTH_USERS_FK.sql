
-- PALWAKF_PLATFORM_IDENTITY_RBAC_AUTHORITY_CONSOLIDATION_MEGA_BATCH
-- 01_POST_APPLY_VERIFY_RBAC_AUTH_USERS_FK.sql
-- READ ONLY verification after FK apply.

select
  'rbac_auth_users_fk_presence' as section,
  con.conname as constraint_name,
  nsp.nspname as table_schema,
  rel.relname as table_name,
  con.convalidated as validated,
  pg_get_constraintdef(con.oid) as constraint_definition
from pg_constraint con
join pg_class rel
  on rel.oid = con.conrelid
join pg_namespace nsp
  on nsp.oid = rel.relnamespace
where nsp.nspname = 'platform_access'
  and rel.relname = 'admin_users'
  and con.conname = 'platform_access_admin_users_id_auth_users_id_fk';

with
platform_admins as (
  select id, email
  from platform_access.admin_users
),
auth_users as (
  select id, email
  from auth.users
),
summary as (
  select
    (select count(*) from platform_admins) as platform_access_admin_users_count,
    (select count(*) from auth_users) as auth_users_count,
    (
      select count(*)
      from platform_admins pa
      join auth_users au on au.id = pa.id
    ) as matched_by_id_count,
    (
      select count(*)
      from platform_admins pa
      left join auth_users au on au.id = pa.id
      where au.id is null
    ) as orphan_admin_users_count,
    (
      select count(*)
      from platform_admins pa
      join auth_users au on au.id = pa.id
      where lower(coalesce(pa.email, '')) <> lower(coalesce(au.email, ''))
    ) as email_mismatch_count
)
select
  'rbac_auth_users_post_apply_summary' as section,
  *,
  case
    when orphan_admin_users_count = 0 and email_mismatch_count = 0 then
      'POST_APPLY_DATA_INTEGRITY_PASSED'
    else
      'POST_APPLY_DATA_INTEGRITY_BLOCKED'
  end as decision,
  true as read_only
from summary;
