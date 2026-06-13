
-- READ ONLY
-- PalWakf RBAC identity source-of-truth evidence probe.
-- Do not mutate data.

select
  table_schema,
  table_name,
  table_type
from information_schema.tables
where (table_schema, table_name) in (
  ('core', 'admin_users'),
  ('platform_access', 'admin_users'),
  ('public', 'admin_users')
)
order by table_schema, table_name;

select
  table_schema,
  table_name,
  column_name,
  data_type,
  is_nullable
from information_schema.columns
where (table_schema, table_name) in (
  ('core', 'admin_users'),
  ('platform_access', 'admin_users'),
  ('public', 'admin_users')
)
order by table_schema, table_name, ordinal_position;

select
  tc.table_schema,
  tc.table_name,
  tc.constraint_name,
  kcu.column_name,
  ccu.table_schema as foreign_table_schema,
  ccu.table_name as foreign_table_name,
  ccu.column_name as foreign_column_name
from information_schema.table_constraints tc
join information_schema.key_column_usage kcu
  on tc.constraint_name = kcu.constraint_name
 and tc.table_schema = kcu.table_schema
join information_schema.constraint_column_usage ccu
  on ccu.constraint_name = tc.constraint_name
 and ccu.table_schema = tc.table_schema
where tc.constraint_type = 'FOREIGN KEY'
  and (
    (tc.table_schema = 'platform_access' and tc.table_name = 'admin_users')
    or (tc.table_schema = 'core' and tc.table_name = 'admin_users')
  )
order by tc.table_schema, tc.table_name, tc.constraint_name;
