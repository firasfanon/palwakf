-- 06B_ADMIN_USER_RESOLUTION_HELPER_read_only.sql
-- Use this if the known smoke UUID fails with PLATFORM_TECHNICAL_FORBIDDEN.
-- It helps find which column links admin_users to auth.users in your actual DB.

select
  'admin_users_columns_probe' as section,
  column_name,
  data_type,
  udt_name,
  is_nullable
from information_schema.columns
where table_schema = 'public'
  and table_name = 'admin_users'
order by ordinal_position;

select
  'admin_users_sample_shape_probe' as section,
  to_jsonb(au) as admin_user_json,
  false as production_approved
from public.admin_users au
limit 5;
