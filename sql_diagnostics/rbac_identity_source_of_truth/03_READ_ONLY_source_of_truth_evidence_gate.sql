
-- PalWakf RBAC Identity Source-of-Truth Evidence Gate
-- READ ONLY ONLY.
-- Do not run INSERT/UPDATE/DELETE/DDL/GRANT/REVOKE here.

select
  'identity_surfaces' as section,
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
  'identity_columns' as section,
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
  'identity_foreign_keys' as section,
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
    or (tc.table_schema = 'public' and tc.table_name = 'admin_users')
  )
order by tc.table_schema, tc.table_name, tc.constraint_name;

select
  'platform_access_role_permission_scope_tables' as section,
  table_schema,
  table_name,
  table_type
from information_schema.tables
where table_schema = 'platform_access'
  and (
    table_name ilike '%admin%'
    or table_name ilike '%role%'
    or table_name ilike '%permission%'
    or table_name ilike '%scope%'
    or table_name ilike '%assignment%'
  )
order by table_name;

select
  'platform_access_role_permission_scope_routines' as section,
  routine_schema,
  routine_name,
  routine_type
from information_schema.routines
where routine_schema = 'platform_access'
  and (
    routine_name ilike '%admin%'
    or routine_name ilike '%role%'
    or routine_name ilike '%permission%'
    or routine_name ilike '%scope%'
  )
order by routine_name;

select
  'rbac_source_of_truth_preliminary_decision' as section,
  'platform_access.admin_users should be treated as the preferred platform administrative identity authority if it is linked to auth.users and role/permission/scope tables are present.' as decision,
  false as ddl_dml_authorized,
  true as read_only;
