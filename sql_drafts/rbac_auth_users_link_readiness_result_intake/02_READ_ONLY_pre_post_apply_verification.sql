
-- READ ONLY
-- RBAC Auth Users Link post/pre-apply verification query.

select
  'rbac_auth_users_link_summary' as section,
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
  false as ddl_dml_authorized,
  true as read_only;
