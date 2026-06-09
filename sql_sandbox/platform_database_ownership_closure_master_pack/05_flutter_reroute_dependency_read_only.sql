-- Platform Database Ownership Closure Master Pack — 05
-- FLUTTER/RUNTIME DEPENDENCY GATE READ-ONLY.
-- This SQL cannot scan Flutter files; it records the DB-side dependency view.
with public_deps as (
  select
    n1.nspname as dependent_schema,
    c1.relname as dependent_object,
    n2.nspname as referenced_schema,
    c2.relname as referenced_object
  from pg_depend d
  join pg_rewrite r on r.oid = d.objid
  join pg_class c1 on c1.oid = r.ev_class
  join pg_namespace n1 on n1.oid = c1.relnamespace
  join pg_class c2 on c2.oid = d.refobjid
  join pg_namespace n2 on n2.oid = c2.relnamespace
  where n2.nspname = 'public'
)
select 'flutter_reroute_dependency_gate' as section,
       count(*) as db_public_dependency_count,
       false as dependency_zero_certified,
       false as exact_public_table_replacement_authorized,
       true as read_only
from public_deps;
