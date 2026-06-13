
-- READ ONLY
-- 01_identity_table_presence_and_counts.sql

select
  'identity_table_presence' as section,
  table_schema,
  table_name,
  table_type
from information_schema.tables
where (table_schema, table_name) in (
  ('platform_access', 'admin_users'),
  ('core', 'admin_users'),
  ('public', 'admin_users')
)
order by table_schema, table_name;

select
  'identity_row_counts' as section,
  'platform_access.admin_users' as relation,
  count(*)::bigint as row_count
from platform_access.admin_users
union all
select
  'identity_row_counts',
  'core.admin_users',
  count(*)::bigint
from core.admin_users
union all
select
  'identity_row_counts',
  'public.admin_users',
  count(*)::bigint
from public.admin_users;
