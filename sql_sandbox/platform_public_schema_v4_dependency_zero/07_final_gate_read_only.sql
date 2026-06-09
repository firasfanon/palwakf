/* Final read-only gate. This does not certify automatically; it summarizes measurable blockers. */

with public_tables as (
  select c.relname as table_name
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public'
    and c.relkind in ('r','p')
), funcs as (
  select p.oid, n.nspname as schema_name, p.proname, p.prosrc
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname not in ('pg_catalog','information_schema')
), views as (
  select c.oid, n.nspname as schema_name, c.relname, pg_get_viewdef(c.oid, true) as def
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
  where c.relkind in ('v','m')
    and n.nspname not in ('pg_catalog','information_schema')
), function_refs as (
  select distinct f.schema_name, f.proname, pt.table_name
  from funcs f join public_tables pt on f.prosrc ilike '%public.' || pt.table_name || '%' or f.prosrc ilike '%' || pt.table_name || '%'
), view_refs as (
  select distinct v.schema_name, v.relname, pt.table_name
  from views v join public_tables pt on v.def ilike '%public.' || pt.table_name || '%' or v.def ilike '%' || pt.table_name || '%'
), counts as (
  select
    (select count(*) from public_tables) as public_base_table_count,
    (select count(*) from function_refs) as possible_function_ref_count,
    (select count(*) from view_refs) as possible_view_ref_count
)
select
  'platform_public_schema_v4_final_gate_read_only' as section,
  public_base_table_count,
  possible_function_ref_count,
  possible_view_ref_count,
  false as ddl_dml_authorized,
  false as grant_revoke_authorized,
  false as production_approved,
  true as read_only,
  case
    when possible_function_ref_count = 0 and possible_view_ref_count = 0 then 'POSSIBLE_DEPENDENCY_ZERO_SQL_SIDE_REQUIRES_FLUTTER_RUNTIME_EVIDENCE'
    else 'PUBLIC_SCHEMA_DEPENDENCY_ZERO_NOT_CERTIFIED_REMEDIATION_REQUIRED'
  end as decision
from counts;
