-- N2.23 — Locations Conflict Audit Read-only
-- Audits public.locations vs gis.locations. No changes.

select 'objects' as section,
  n.nspname as schema_name,
  c.relname as object_name,
  case c.relkind when 'r' then 'table' when 'v' then 'view' when 'm' then 'materialized_view' else c.relkind::text end as object_type,
  pg_total_relation_size(c.oid) as total_bytes
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where (n.nspname, c.relname) in (('public','locations'), ('gis','locations'))
order by schema_name;

select 'columns' as section,
  table_schema,
  table_name,
  ordinal_position,
  column_name,
  data_type,
  udt_name
from information_schema.columns
where (table_schema, table_name) in (('public','locations'), ('gis','locations'))
order by table_schema, table_name, ordinal_position;

select 'dependencies' as section,
  dependent_ns.nspname as dependent_schema,
  dependent_view.relname as dependent_object,
  case dependent_view.relkind when 'v' then 'view' when 'm' then 'materialized_view' when 'r' then 'table' else dependent_view.relkind::text end as dependent_type,
  source_ns.nspname as source_schema,
  source_table.relname as source_object
from pg_depend d
join pg_rewrite r on r.oid = d.objid
join pg_class dependent_view on dependent_view.oid = r.ev_class
join pg_namespace dependent_ns on dependent_ns.oid = dependent_view.relnamespace
join pg_class source_table on source_table.oid = d.refobjid
join pg_namespace source_ns on source_ns.oid = source_table.relnamespace
where source_table.relname = 'locations'
  and source_ns.nspname in ('public','gis')
order by source_schema, dependent_schema, dependent_object;

select 'sovereign_boundary' as section,
  'no_waq_assets_mutation_in_this_script' as check_key,
  true as passed,
  'Read-only locations audit only; no waqf/waqf_assets/awqaf_system DML.' as note;
