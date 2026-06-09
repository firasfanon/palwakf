
-- Script 01: Public object inventory read-only
-- Purpose: inventory all public tables/views/materialized views/sequences/functions without mutation.

with relations as (
  select
    n.nspname as source_schema,
    c.relname as object_name,
    case c.relkind
      when 'r' then 'table'
      when 'p' then 'partitioned_table'
      when 'v' then 'view'
      when 'm' then 'materialized_view'
      when 'S' then 'sequence'
      when 'f' then 'foreign_table'
      else c.relkind::text
    end as object_type,
    c.relkind,
    c.reltuples::bigint as estimated_rows,
    obj_description(c.oid, 'pg_class') as object_comment
  from pg_catalog.pg_class c
  join pg_catalog.pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public'
    and c.relkind in ('r','p','v','m','S','f')
), functions as (
  select
    n.nspname as source_schema,
    p.proname || '(' || pg_catalog.pg_get_function_identity_arguments(p.oid) || ')' as object_name,
    'function' as object_type,
    'function'::text as relkind,
    null::bigint as estimated_rows,
    obj_description(p.oid, 'pg_proc') as object_comment
  from pg_catalog.pg_proc p
  join pg_catalog.pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
)
select
  'public_object_inventory' as section,
  source_schema,
  object_type,
  object_name,
  estimated_rows,
  object_comment
from relations
union all
select
  'public_object_inventory' as section,
  source_schema,
  object_type,
  object_name,
  estimated_rows,
  object_comment
from functions
order by object_type, object_name;
