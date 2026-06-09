-- PWF-SIS-02 read-only inventory.
-- No DML. No waqf_assets mutation.

select
  'visual_identity_runtime_inventory' as section,
  table_schema,
  table_name,
  table_type
from information_schema.tables
where table_schema in ('public', 'platform', 'core')
  and (
    table_name ilike '%visual%'
    or table_name ilike '%theme%'
    or table_name ilike '%identity%'
    or table_name ilike '%branding%'
  )
order by table_schema, table_name;

select
  'visual_identity_runtime_routines' as section,
  routine_schema,
  routine_name,
  routine_type
from information_schema.routines
where routine_schema in ('public', 'platform', 'core')
  and (
    routine_name ilike '%visual%'
    or routine_name ilike '%theme%'
    or routine_name ilike '%identity%'
    or routine_name ilike '%branding%'
  )
order by routine_schema, routine_name;
