-- N2.28 READ ONLY
-- Inspect the actual platform.schema_inventory_decisions contract before writing any DML.
select
  column_name,
  data_type,
  ordinal_position,
  is_nullable,
  column_default
from information_schema.columns
where table_schema = 'platform'
  and table_name = 'schema_inventory_decisions'
order by ordinal_position;
