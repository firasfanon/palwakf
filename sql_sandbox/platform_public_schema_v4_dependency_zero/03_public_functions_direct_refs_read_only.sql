/* Text scan of function bodies for direct references to public base tables. Read-only. */

with public_tables as (
  select c.relname as table_name
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public'
    and c.relkind in ('r','p')
), funcs as (
  select
    n.nspname as function_schema,
    p.proname as function_name,
    pg_get_function_identity_arguments(p.oid) as identity_arguments,
    p.prosrc as source_text
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname not in ('pg_catalog','information_schema')
)
select
  'public_functions_direct_refs_read_only' as section,
  f.function_schema,
  f.function_name,
  f.identity_arguments,
  pt.table_name as referenced_public_table,
  (f.source_text ilike '%public.' || pt.table_name || '%') as explicit_public_schema_ref,
  (f.source_text ilike '%' || pt.table_name || '%') as possible_unqualified_ref,
  false as ddl_dml_authorized,
  false as production_approved,
  true as read_only
from funcs f
join public_tables pt
  on f.source_text ilike '%public.' || pt.table_name || '%'
  or f.source_text ilike '%' || pt.table_name || '%'
order by f.function_schema, f.function_name, pt.table_name;
