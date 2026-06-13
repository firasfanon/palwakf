
-- PALWAKF_PLATFORM_IDENTITY_RBAC_AUTHORITY_CONSOLIDATION_MEGA_BATCH
-- 00_PRE_APPLY_GUARD_READ_ONLY.sql
-- READ ONLY.
-- Expected:
-- platform_access_admin_users_count = 86
-- auth_users_count = 86
-- matched_by_id_count = 86
-- orphan_admin_users_count = 0
-- email_mismatch_count = 0

with
platform_admins as (
  select id, email, name, role, is_active
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
  'pre_apply_rbac_auth_users_link_summary' as section,
  *,
  case
    when orphan_admin_users_count = 0 and email_mismatch_count = 0 then
      'PRE_APPLY_GUARD_PASSED'
    else
      'PRE_APPLY_GUARD_BLOCKED'
  end as guard_decision,
  false as ddl_dml_authorized_by_this_statement,
  true as read_only
from summary;

select
  'existing_fk_constraint_check' as section,
  con.conname as constraint_name,
  nsp.nspname as table_schema,
  rel.relname as table_name,
  pg_get_constraintdef(con.oid) as constraint_definition
from pg_constraint con
join pg_class rel
  on rel.oid = con.conrelid
join pg_namespace nsp
  on nsp.oid = rel.relnamespace
where nsp.nspname = 'platform_access'
  and rel.relname = 'admin_users'
  and con.contype = 'f'
order by con.conname;
