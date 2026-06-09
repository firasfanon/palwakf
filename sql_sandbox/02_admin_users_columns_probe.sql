select
  table_schema,
  table_name,
  ordinal_position,
  column_name,
  data_type,
  is_nullable
from information_schema.columns
where table_name = 'admin_users'
order by table_schema, ordinal_position;
