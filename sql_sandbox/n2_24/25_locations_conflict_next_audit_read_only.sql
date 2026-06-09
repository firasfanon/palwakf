-- N2.25 starter audit for public.locations vs gis.locations
-- Read-only only.

with objects as (
  select n.nspname as schema_name, c.relname as object_name, c.relkind
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where (n.nspname, c.relname) in (('public','locations'), ('gis','locations'))
)
select *
from objects
order by schema_name, object_name;
