-- N2.22 READ ONLY — dependencies, RLS, triggers, and functions risk
-- No DML. No DDL.

-- Candidate tables by names usually indicating staging/backup/cache/legacy/uat/test.
with candidates as (
  select table_schema, table_name
  from information_schema.tables
  where table_schema not in ('pg_catalog','information_schema')
    and table_type = 'BASE TABLE'
    and (
      table_name ilike 'stg_%'
      or table_name ilike '%staging%'
      or table_name ilike '%temp%'
      or table_name ilike '%tmp%'
      or table_name ilike '%legacy%'
      or table_name ilike '%cache%'
      or table_name ilike '%backup%'
      or table_name ilike '%old%'
      or table_name ilike '%uat%'
      or table_name ilike '%test%'
    )
)
select * from candidates order by table_schema, table_name;

-- FK dependencies involving candidates.
with candidates as (
  select c.oid, n.nspname as schema_name, c.relname as table_name
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where c.relkind in ('r','p')
    and n.nspname not in ('pg_catalog','information_schema')
    and (
      c.relname ilike 'stg_%'
      or c.relname ilike '%staging%'
      or c.relname ilike '%temp%'
      or c.relname ilike '%tmp%'
      or c.relname ilike '%legacy%'
      or c.relname ilike '%cache%'
      or c.relname ilike '%backup%'
      or c.relname ilike '%old%'
      or c.relname ilike '%uat%'
      or c.relname ilike '%test%'
    )
)
select
  con.conname,
  src_ns.nspname as source_schema,
  src.relname as source_table,
  tgt.schema_name as target_schema,
  tgt.table_name as target_table,
  pg_get_constraintdef(con.oid) as constraint_def
from pg_constraint con
join pg_class src on src.oid = con.conrelid
join pg_namespace src_ns on src_ns.oid = src.relnamespace
join candidates tgt on tgt.oid = con.confrelid
where con.contype = 'f'
union all
select
  con.conname,
  tgt.schema_name as source_schema,
  tgt.table_name as source_table,
  ref_ns.nspname as target_schema,
  ref.relname as target_table,
  pg_get_constraintdef(con.oid) as constraint_def
from pg_constraint con
join candidates tgt on tgt.oid = con.conrelid
join pg_class ref on ref.oid = con.confrelid
join pg_namespace ref_ns on ref_ns.oid = ref.relnamespace
where con.contype = 'f'
order by target_schema, target_table, source_schema, source_table;

-- Views depending on candidate/cache tables.
select
  dependent_ns.nspname as dependent_schema,
  dependent_view.relname as dependent_object,
  source_ns.nspname as source_schema,
  source_table.relname as source_object
from pg_depend d
join pg_rewrite r on r.oid = d.objid
join pg_class dependent_view on dependent_view.oid = r.ev_class
join pg_namespace dependent_ns on dependent_ns.oid = dependent_view.relnamespace
join pg_class source_table on source_table.oid = d.refobjid
join pg_namespace source_ns on source_ns.oid = source_table.relnamespace
where source_table.relname ilike '%cache%'
   or source_table.relname ilike '%backup%'
   or source_table.relname ilike 'stg_%'
   or source_table.relname ilike '%legacy%'
   or source_table.relname ilike '%old%'
order by source_schema, source_object, dependent_schema, dependent_object;

-- Functions that mention cache/legacy/staging/public org units/RBAC transitional tables.
select
  n.nspname as schema_name,
  p.proname as function_name,
  p.prokind,
  case
    when pg_get_functiondef(p.oid) ilike '%pwf_org_units_cache%' then 'uses_org_units_cache'
    when pg_get_functiondef(p.oid) ilike '%org_units_cache%' then 'uses_org_units_cache'
    when pg_get_functiondef(p.oid) ilike '% public.org_units%' then 'uses_public_org_units'
    when pg_get_functiondef(p.oid) ilike '% public.%cache%' then 'uses_public_cache'
    when pg_get_functiondef(p.oid) ilike '% public.user_system_roles%' then 'uses_public_user_roles_transitional'
    when pg_get_functiondef(p.oid) ilike '% public.user_system_permissions%' then 'uses_public_user_permissions_transitional'
    else 'manual_review'
  end as risk_classification,
  pg_get_functiondef(p.oid) as function_definition
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where p.prokind = 'f'
  and n.nspname not in ('pg_catalog','information_schema')
  and (
    pg_get_functiondef(p.oid) ilike '%org_units%'
    or pg_get_functiondef(p.oid) ilike '%cache%'
    or pg_get_functiondef(p.oid) ilike '%stg_%'
    or pg_get_functiondef(p.oid) ilike '%legacy%'
    or pg_get_functiondef(p.oid) ilike '%user_system_roles%'
    or pg_get_functiondef(p.oid) ilike '%user_system_permissions%'
  )
order by risk_classification, schema_name, function_name;

select
  'sovereign_boundary' as section,
  'no_waq_assets_mutation_in_this_script' as check_key,
  true as passed,
  'Read-only dependencies/risk audit only.' as note;
