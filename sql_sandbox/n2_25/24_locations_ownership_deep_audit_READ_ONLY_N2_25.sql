-- N2.25 - Locations Ownership Deep Audit
-- READ ONLY. No DML.

with objects as (
  select
    n.nspname as schema_name,
    c.relname as table_name,
    c.relkind,
    pg_total_relation_size(c.oid) as total_bytes
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where (n.nspname, c.relname) in (('public','locations'),('gis','locations'))
),
columns as (
  select
    table_schema,
    table_name,
    count(*) as columns_count,
    string_agg(column_name || ':' || data_type, ', ' order by ordinal_position) as columns_signature
  from information_schema.columns
  where (table_schema, table_name) in (('public','locations'),('gis','locations'))
  group by table_schema, table_name
),
deps as (
  select
    source_ns.nspname as schema_name,
    source_table.relname as table_name,
    count(distinct dependent_view.oid) as dependent_view_count
  from pg_depend d
  join pg_rewrite r on r.oid = d.objid
  join pg_class dependent_view on dependent_view.oid = r.ev_class
  join pg_class source_table on source_table.oid = d.refobjid
  join pg_namespace source_ns on source_ns.oid = source_table.relnamespace
  where (source_ns.nspname, source_table.relname) in (('public','locations'),('gis','locations'))
  group by source_ns.nspname, source_table.relname
),
fks as (
  select
    ns.nspname as schema_name,
    cl.relname as table_name,
    count(*) as referenced_by_fk_count
  from pg_constraint con
  join pg_class cl on cl.oid = con.confrelid
  join pg_namespace ns on ns.oid = cl.relnamespace
  where con.contype = 'f'
    and (ns.nspname, cl.relname) in (('public','locations'),('gis','locations'))
  group by ns.nspname, cl.relname
)
select
  'locations_audit' as section,
  o.schema_name,
  o.table_name,
  case o.relkind when 'r' then 'table' else o.relkind::text end as object_type,
  o.total_bytes,
  c.columns_count,
  c.columns_signature,
  coalesce(d.dependent_view_count,0) as dependent_view_count,
  coalesce(f.referenced_by_fk_count,0) as referenced_by_fk_count,
  'manual_review' as decision
from objects o
left join columns c on c.table_schema=o.schema_name and c.table_name=o.table_name
left join deps d on d.schema_name=o.schema_name and d.table_name=o.table_name
left join fks f on f.schema_name=o.schema_name and f.table_name=o.table_name
order by o.schema_name;
