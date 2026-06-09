/* Read-only dependency graph for views/materialized views/functions depending on public base tables where catalog dependencies are explicit. */

with public_tables as (
  select c.oid as table_oid, n.nspname as table_schema, c.relname as table_name
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public'
    and c.relkind in ('r','p')
), dependents as (
  select distinct
    pt.table_schema,
    pt.table_name,
    coalesce(dn.nspname, pn.nspname) as dependent_schema,
    coalesce(dc.relname, p.proname) as dependent_name,
    case
      when dc.oid is not null then dc.relkind::text
      when p.oid is not null then 'function'
      else 'unknown'
    end as dependent_kind
  from public_tables pt
  join pg_depend dep on dep.refobjid = pt.table_oid
  left join pg_rewrite rw on rw.oid = dep.objid
  left join pg_class dc on dc.oid = rw.ev_class
  left join pg_namespace dn on dn.oid = dc.relnamespace
  left join pg_proc p on p.oid = dep.objid
  left join pg_namespace pn on pn.oid = p.pronamespace
)
select
  'public_dependency_graph_read_only' as section,
  table_schema,
  table_name,
  dependent_schema,
  dependent_name,
  dependent_kind,
  false as ddl_dml_authorized,
  false as production_approved,
  true as read_only
from dependents
where dependent_name is not null
order by table_name, dependent_schema, dependent_name;
