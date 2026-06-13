
-- READ ONLY
-- Verify FK state after optional duplicate cleanup.

select
  'platform_access_admin_users_fk_state' as section,
  con.conname as constraint_name,
  pg_get_constraintdef(con.oid) as constraint_definition,
  con.convalidated as validated
from pg_constraint con
join pg_class rel on rel.oid = con.conrelid
join pg_namespace nsp on nsp.oid = rel.relnamespace
where nsp.nspname = 'platform_access'
  and rel.relname = 'admin_users'
  and con.contype = 'f'
order by con.conname;

select
  'rbac_auth_users_post_cleanup_data_integrity' as section,
  (select count(*) from platform_access.admin_users) as platform_access_admin_users_count,
  (select count(*) from auth.users) as auth_users_count,
  (
    select count(*)
    from platform_access.admin_users pa
    join auth.users au on au.id = pa.id
  ) as matched_by_id_count,
  (
    select count(*)
    from platform_access.admin_users pa
    left join auth.users au on au.id = pa.id
    where au.id is null
  ) as orphan_admin_users_count,
  (
    select count(*)
    from platform_access.admin_users pa
    join auth.users au on au.id = pa.id
    where lower(coalesce(pa.email, '')) <> lower(coalesce(au.email, ''))
  ) as email_mismatch_count,
  true as read_only;
