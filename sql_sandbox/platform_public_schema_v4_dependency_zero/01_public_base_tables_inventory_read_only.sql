/* Read-only inventory of public base tables. */

with public_tables as (
  select
    n.nspname as schema_name,
    c.relname as table_name,
    c.relkind,
    obj_description(c.oid, 'pg_class') as comment
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public'
    and c.relkind in ('r','p')
)
select
  'public_base_tables_inventory_read_only' as section,
  schema_name,
  table_name,
  case relkind when 'r' then 'ordinary_table' when 'p' then 'partitioned_table' else relkind::text end as table_kind,
  comment,
  false as create_public_base_table_authorized,
  false as production_approved,
  true as read_only
from public_tables
order by table_name;

select
  'public_base_tables_inventory_summary' as section,
  count(*) as public_base_table_count,
  false as create_public_base_table_authorized,
  false as production_approved,
  true as read_only
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public'
  and c.relkind in ('r','p');
