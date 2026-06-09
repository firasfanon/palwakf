/* Text scan of view definitions for direct references to public base tables. Read-only. */

with public_tables as (
  select c.relname as table_name
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public'
    and c.relkind in ('r','p')
), views as (
  select
    n.nspname as view_schema,
    c.relname as view_name,
    pg_get_viewdef(c.oid, true) as view_definition,
    c.relkind
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where c.relkind in ('v','m')
    and n.nspname not in ('pg_catalog','information_schema')
)
select
  'public_views_direct_refs_read_only' as section,
  v.view_schema,
  v.view_name,
  case v.relkind when 'v' then 'view' when 'm' then 'materialized_view' else v.relkind::text end as view_kind,
  pt.table_name as referenced_public_table,
  (v.view_definition ilike '%public.' || pt.table_name || '%') as explicit_public_schema_ref,
  (v.view_definition ilike '%' || pt.table_name || '%') as possible_unqualified_ref,
  false as ddl_dml_authorized,
  false as production_approved,
  true as read_only
from views v
join public_tables pt
  on v.view_definition ilike '%public.' || pt.table_name || '%'
  or v.view_definition ilike '%' || pt.table_name || '%'
order by v.view_schema, v.view_name, pt.table_name;
