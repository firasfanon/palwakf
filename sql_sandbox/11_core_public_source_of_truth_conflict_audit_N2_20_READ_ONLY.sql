-- Mega Batch N2.20 — Core/Public Source-of-Truth Conflict Audit
-- READ ONLY evidence script. No production DML. No waqf/waqf_assets/awqaf_system mutation.

with objects as (
  select
    n.nspname as schema_name,
    c.relname as object_name,
    case c.relkind
      when 'r' then 'table'
      when 'v' then 'view'
      when 'm' then 'materialized_view'
      when 'p' then 'partitioned_table'
      else c.relkind::text
    end as object_type
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname in ('core','public','platform','platform_content','platform_services','waqf','awqaf_system','assistant','gis','gis_ref','gis_waqf')
    and c.relkind in ('r','v','m','p')
), direct_conflicts as (
  select
    object_name,
    count(distinct schema_name) as schemas_count,
    string_agg(schema_name || ':' || object_type, ', ' order by schema_name) as locations
  from objects
  group by object_name
  having count(distinct schema_name) > 1
), public_view_risk as (
  select
    table_schema,
    table_name,
    case
      when view_definition ilike '%pwf_org_units_cache%' or view_definition ilike '%org_units_cache%' then 'uses_cache_blocker'
      when view_definition ilike '% from public.%' or view_definition ilike '% join public.%' then 'uses_public_source_review'
      when view_definition ilike '%core.%' then 'uses_core_wrapper'
      when view_definition ilike '%platform.%' then 'uses_platform_wrapper'
      when view_definition ilike '%waqf.%' then 'uses_waqf_wrapper'
      when view_definition ilike '%assistant.%' then 'uses_assistant_wrapper'
      when view_definition ilike '%gis.%' then 'uses_gis_wrapper'
      else 'manual_review'
    end as wrapper_classification
  from information_schema.views
  where table_schema = 'public'
), functions_risk as (
  select
    n.nspname as schema_name,
    p.proname as function_name,
    case
      when pg_get_functiondef(p.oid) ilike '%pwf_org_units_cache%' then 'uses_org_units_cache'
      when pg_get_functiondef(p.oid) ilike '%org_units_cache%' then 'uses_org_units_cache'
      when pg_get_functiondef(p.oid) ilike '% public.org_units%' then 'uses_public_org_units'
      when pg_get_functiondef(p.oid) ilike '% public.%cache%' then 'uses_public_cache'
      when pg_get_functiondef(p.oid) ilike '% public.user_system_roles%' then 'uses_public_user_roles_transitional'
      when pg_get_functiondef(p.oid) ilike '% public.user_system_permissions%' then 'uses_public_user_permissions_transitional'
      else 'manual_review'
    end as risk_classification
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname in ('public','core','platform','assistant')
    and p.prokind = 'f'
    and (
      pg_get_functiondef(p.oid) ilike '%org_units%'
      or pg_get_functiondef(p.oid) ilike '%org_unit_profiles%'
      or pg_get_functiondef(p.oid) ilike '%user_system_roles%'
      or pg_get_functiondef(p.oid) ilike '%user_system_permissions%'
      or pg_get_functiondef(p.oid) ilike '%cache%'
    )
)
select 'direct_conflicts' as section, object_name as key, true as passed, locations as note
from direct_conflicts
union all
select 'public_view_risk', table_name, (wrapper_classification <> 'uses_cache_blocker') as passed, wrapper_classification
from public_view_risk
where table_name in ('org_units','org_unit_profiles','v_admin_home_units','v_platform_system_registry','v_platform_system_sections','v_public_waqf_assets')
union all
select 'functions_risk', function_name, (risk_classification <> 'uses_org_units_cache') as passed, risk_classification
from functions_risk
where risk_classification <> 'manual_review'
union all
select 'sovereign_boundary', 'no_waq_assets_mutation_in_this_script', true, 'Read-only audit only; no waqf/waqf_assets/awqaf_system DML.'
order by section, key;
