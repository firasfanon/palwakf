
-- READ ONLY
-- Permission/role/scope surfaces under platform_access.

select
  table_schema,
  table_name,
  table_type
from information_schema.tables
where table_schema = 'platform_access'
  and (
    table_name ilike '%role%'
    or table_name ilike '%permission%'
    or table_name ilike '%scope%'
    or table_name ilike '%assignment%'
    or table_name ilike '%admin%'
  )
order by table_name;

select
  routine_schema,
  routine_name,
  routine_type
from information_schema.routines
where routine_schema = 'platform_access'
  and (
    routine_name ilike '%role%'
    or routine_name ilike '%permission%'
    or routine_name ilike '%scope%'
    or routine_name ilike '%admin%'
  )
order by routine_name;
