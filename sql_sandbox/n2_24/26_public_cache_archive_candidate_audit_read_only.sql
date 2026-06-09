-- Audit deprecated public org-unit caches before archive movement.
-- Read-only only.

select table_schema, table_name
from information_schema.tables
where table_schema = 'public'
  and table_name in ('org_units_cache', 'pwf_org_units_cache')
order by table_name;
