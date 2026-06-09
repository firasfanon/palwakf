-- Platform Database Ownership Closure — 15
-- DB Public Dependency Classifier — READ ONLY.
-- Hotfixed in 15A to avoid pg_get_functiondef() on aggregate routines.
--
-- Why: pg_proc includes aggregate/window/internal routines. Calling
-- pg_get_functiondef() on an aggregate such as array_agg raises:
--   ERROR 42809: "array_agg" is an aggregate function
--
-- This script first materializes only normal functions/procedures outside
-- system schemas, then inspects source text. No DDL, no DML, no grants,
-- no destructive action.

with public_relation_deps as (
  select distinct
    n1.nspname as dependent_schema,
    c1.relname as dependent_object,
    c1.relkind::text as dependent_relkind,
    n2.nspname as referenced_schema,
    c2.relname as referenced_object,
    c2.relkind::text as referenced_relkind,
    'view_or_rule_dependency'::text as dependency_family
  from pg_depend d
  join pg_rewrite r on r.oid = d.objid
  join pg_class c1 on c1.oid = r.ev_class
  join pg_namespace n1 on n1.oid = c1.relnamespace
  join pg_class c2 on c2.oid = d.refobjid
  join pg_namespace n2 on n2.oid = c2.relnamespace
  where n2.nspname = 'public'
), routine_candidates as materialized (
  select
    p.oid,
    n.nspname,
    p.proname,
    p.prokind
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname not in ('pg_catalog', 'information_schema')
    and p.prokind in ('f', 'p') -- normal function or procedure only; exclude aggregates/window functions.
), routine_source_refs as (
  select
    rc.nspname as dependent_schema,
    rc.proname as dependent_object,
    case rc.prokind
      when 'p' then 'procedure'
      else 'function'
    end as dependent_relkind,
    'public'::text as referenced_schema,
    null::text as referenced_object,
    null::text as referenced_relkind,
    'routine_source_mentions_public'::text as dependency_family
  from routine_candidates rc
  cross join lateral (
    select pg_get_functiondef(rc.oid) as function_definition
  ) fd
  where fd.function_definition ilike '%public.%'
), all_deps as (
  select * from public_relation_deps
  union all
  select * from routine_source_refs
), classified as (
  select
    dependency_family,
    dependent_schema,
    dependent_object,
    referenced_schema,
    coalesce(referenced_object, '<source-text-public-reference>') as referenced_object,
    count(*) as dependency_count,
    case
      when dependent_schema in ('public') then 'public_surface_self_reference_or_legacy_wrapper'
      when dependent_schema in ('platform_content','platform_services','media_center','assistant','platform_access','core','tasks','cases') then 'owner_schema_dependency_needs_wrapper_review'
      when dependent_schema in ('gis','waqf','awqaf_system','auth') then 'protected_sovereign_reference_review_only'
      else 'unclassified_dependency_review_required'
    end as remediation_bucket
  from all_deps
  group by dependency_family, dependent_schema, dependent_object, referenced_schema, referenced_object
)
select 'db_public_dependency_classifier' as section,
       dependency_family,
       remediation_bucket,
       dependent_schema,
       dependent_object,
       referenced_schema,
       referenced_object,
       dependency_count,
       false as dependency_zero_certified,
       true as read_only
from classified
order by dependency_count desc, dependency_family, dependent_schema, dependent_object, referenced_object;
