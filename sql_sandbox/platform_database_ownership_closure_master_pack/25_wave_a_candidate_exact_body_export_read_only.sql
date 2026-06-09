-- Platform Database Dependency Remediation Wave A
-- SQL 25: exact body export for Wave A candidates (READ ONLY)
-- Purpose: export current function/procedure/view bodies for review before any guarded execution candidate.
-- Safety: SELECT only; excludes aggregate/window routines; no DDL/DML/GRANT/DROP.

with routine_candidates as materialized (
  select
    n.nspname as dependent_schema,
    p.proname as dependent_object,
    p.oid,
    p.oid::regprocedure::text as object_signature,
    p.prokind
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname in ('core', 'assistant', 'tasks')
    and p.prokind in ('f', 'p')
), routine_export as (
  select
    'wave_a_candidate_exact_body_export'::text as section,
    'routine_source_mentions_public'::text as dependency_family,
    'owner_schema_dependency_needs_wrapper_review'::text as remediation_bucket,
    dependent_schema,
    dependent_object,
    object_signature,
    case prokind when 'f' then 'function' when 'p' then 'procedure' else prokind::text end as object_kind,
    left(pg_get_functiondef(oid), 8000) as current_body_excerpt,
    case
      when pg_get_functiondef(oid) ilike '%public.%'
        or pg_get_functiondef(oid) ~* '(^|[^a-zA-Z0-9_])public([^a-zA-Z0-9_]|$)'
      then true else false
    end as mentions_public,
    false as execution_authorized,
    true as exact_body_review_required,
    true as read_only
  from routine_candidates
), view_candidates as materialized (
  select
    v.table_schema as dependent_schema,
    v.table_name as dependent_object,
    (quote_ident(v.table_schema) || '.' || quote_ident(v.table_name))::regclass as view_oid
  from information_schema.views v
  where v.table_schema in (
    'core',
    'platform_access',
    'platform_content',
    'media_center',
    'platform_services',
    'document_intelligence'
  )
), view_export as (
  select
    'wave_a_candidate_exact_body_export'::text as section,
    'view_or_rule_dependency'::text as dependency_family,
    'real_dependency_review_by_referenced_object'::text as remediation_bucket,
    dependent_schema,
    dependent_object,
    view_oid::text as object_signature,
    'view'::text as object_kind,
    left(pg_get_viewdef(view_oid, true), 8000) as current_body_excerpt,
    case
      when pg_get_viewdef(view_oid, true) ilike '%public.%'
        or pg_get_viewdef(view_oid, true) ~* '(^|[^a-zA-Z0-9_])public([^a-zA-Z0-9_]|$)'
      then true else false
    end as mentions_public,
    false as execution_authorized,
    true as exact_body_review_required,
    true as read_only
  from view_candidates
)
select * from routine_export
where mentions_public = true
union all
select * from view_export
where mentions_public = true
order by remediation_bucket, dependent_schema, dependent_object;
