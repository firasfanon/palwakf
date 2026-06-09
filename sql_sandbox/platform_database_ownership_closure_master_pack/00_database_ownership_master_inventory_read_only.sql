-- Platform Database Ownership Closure Master Pack — 00
-- MASTER INVENTORY READ-ONLY. No DDL/DML.
with schemas as (
  select nspname as schema_name
  from pg_namespace
  where nspname in ('public','core','platform','platform_access','platform_content','platform_services','media_center','assistant','tasks','cases','gis','waqf','awqaf_system')
), objects as (
  select n.nspname as schema_name, c.relname as object_name, c.relkind
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
  where n.nspname in (select schema_name from schemas)
    and c.relkind in ('r','v','m','p','f')
), routines as (
  select n.nspname as schema_name, p.proname as routine_name, pg_get_function_identity_arguments(p.oid) as args
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname in (select schema_name from schemas)
)
select 'database_ownership_inventory' as section,
       (select count(*) from objects) as object_count,
       (select count(*) from routines) as routine_count,
       true as read_only,
       false as production_approved;
