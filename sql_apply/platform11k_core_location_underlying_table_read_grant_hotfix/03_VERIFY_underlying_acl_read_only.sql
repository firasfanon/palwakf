-- 03_VERIFY_underlying_acl_read_only.sql

with targets as (
  select *
  from (
    values
      ('core', 'core_locations', 'required_base_table'),
      ('core', 'core_lgus', 'required_lgu_table'),
      ('core', 'core_location_lgu_bridge_candidates', 'optional_bridge_table'),
      ('core', 'core_location_backlog_review_decisions', 'optional_decision_table'),
      ('core', 'v_core_location_backlog_review_v1', 'optional_backlog_review_view'),
      ('core', 'v_core_location_backlog_operational_queue_v1', 'required_operational_queue_view'),
      ('core', 'v_core_locations_with_lgus_v1', 'required_locations_with_lgus_view')
  ) as v(schema_name, object_name, requirement_level)
)
select
  'platform11k_underlying_acl_verify_read_only' as section,
  t.schema_name,
  t.object_name,
  t.requirement_level,
  case when c.oid is null then 'missing_or_not_applicable' else 'present' end as presence_status,
  case when c.oid is null then null else has_table_privilege('authenticated', format('%I.%I', t.schema_name, t.object_name), 'SELECT') end as authenticated_has_select,
  false as production_approved
from targets t
left join pg_namespace n on n.nspname = t.schema_name
left join pg_class c on c.relnamespace = n.oid and c.relname = t.object_name
order by
  case when t.requirement_level like 'required%' then 0 else 1 end,
  t.object_name;

select
  'platform11k_underlying_acl_verify_rpc_execute_read_only' as section,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  has_function_privilege('authenticated', p.oid, 'EXECUTE') as authenticated_has_execute,
  p.prosecdef as security_definer,
  false as production_approved
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in (
    'rpc_core_location_runtime_certification_v1',
    'rpc_core_location_backlog_summary_v1',
    'rpc_core_location_backlog_operational_queue_v1'
  )
order by p.proname, pg_get_function_identity_arguments(p.oid);

select
  'platform11k_underlying_acl_forbidden_objects_verify_read_only' as section,
  to_regclass('public.locations') is null as public_locations_still_dropped,
  to_regclass('gis.locations_boundary') is null as gis_locations_boundary_still_not_created,
  false as production_approved;
