-- 1) admin_users rows created by this seed
select *
from admin_users
where email like '%.admin@palwakf.local'
   or email like '%.usr1@palwakf.local'
   or email like '%.usr2@palwakf.local'
order by 1;

-- 2) auth users created by this seed
select
  id,
  email,
  raw_user_meta_data
from auth.users
where email like '%.admin@palwakf.local'
   or email like '%.usr1@palwakf.local'
   or email like '%.usr2@palwakf.local'
order by email;

-- 3) expected account count by unit
select
  u.login_key,
  u.slug,
  count(a.id) as auth_accounts_count
from core.org_units u
left join auth.users a
  on (a.raw_user_meta_data ->> 'unit_id')::uuid = u.id
 and (
    a.email like '%.admin@palwakf.local'
    or a.email like '%.usr1@palwakf.local'
    or a.email like '%.usr2@palwakf.local'
 )
where coalesce(u.is_active, true) = true
  and nullif(trim(u.login_key), '') is not null
group by u.login_key, u.slug
order by u.login_key;
