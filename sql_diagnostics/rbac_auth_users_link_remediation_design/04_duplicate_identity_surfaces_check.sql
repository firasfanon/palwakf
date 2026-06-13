
-- READ ONLY
-- 04_duplicate_identity_surfaces_check.sql
-- Checks whether the same IDs/emails appear across core/public/platform_access.

select
  'admin_id_presence_across_surfaces' as section,
  id,
  count(*) filter (where source = 'platform_access') as in_platform_access,
  count(*) filter (where source = 'core') as in_core,
  count(*) filter (where source = 'public') as in_public
from (
  select 'platform_access' as source, id from platform_access.admin_users
  union all
  select 'core' as source, id from core.admin_users
  union all
  select 'public' as source, id from public.admin_users where id is not null
) x
group by id
having count(*) > 1
order by id
limit 100;

select
  'admin_email_presence_across_surfaces' as section,
  lower(email) as normalized_email,
  count(*) filter (where source = 'platform_access') as in_platform_access,
  count(*) filter (where source = 'core') as in_core,
  count(*) filter (where source = 'public') as in_public
from (
  select 'platform_access' as source, email from platform_access.admin_users
  union all
  select 'core' as source, email from core.admin_users
  union all
  select 'public' as source, email from public.admin_users where email is not null
) x
where email is not null
group by lower(email)
having count(*) > 1
order by normalized_email
limit 100;
