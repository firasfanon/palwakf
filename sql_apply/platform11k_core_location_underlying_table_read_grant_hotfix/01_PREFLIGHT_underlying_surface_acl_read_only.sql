-- 01_PREFLIGHT_underlying_surface_acl_read_only.sql
-- Read-only preflight for underlying tables/views.

with targets as (
  select *
  from (
    values
      ('core', 'core_locations', 'table_required_by_error_hint'),
      ('core', 'core_lgus', 'table_required_by_locations_with_lgus_view'),
      ('core', 'core_location_lgu_bridge_candidates', 'optional_table_used_by_backlog_review'),
      ('core', 'core_location_backlog_review_decisions', 'optional_decision_table_used_by_operational_queue'),
      ('core', 'v_core_location_backlog_review_v1', 'optional_view_used_by_operational_queue'),
      ('core', 'v_core_location_backlog_operational_queue_v1', 'view_reported_by_awqaf_error'),
      ('core', 'v_core_locations_with_lgus_v1', 'view_used_by_location_read_surface')
  ) as v(schema_name, object_name, reason)
)
select
  'platform11k_underlying_read_surface_preflight_acl_read_only' as section,
  t.schema_name,
  t.object_name,
  t.reason,
  case when c.oid is null then 'missing_or_not_applicable' else 'present' end as presence_status,
  case when c.oid is null then null else c.relkind::text end as relkind,
  has_schema_privilege('authenticated', t.schema_name, 'USAGE') as authenticated_has_schema_usage,
  case
    when c.oid is null then null
    else has_table_privilege('authenticated', format('%I.%I', t.schema_name, t.object_name), 'SELECT')
  end as authenticated_has_select,
  false as production_approved
from targets t
left join pg_namespace n on n.nspname = t.schema_name
left join pg_class c on c.relnamespace = n.oid and c.relname = t.object_name
order by t.object_name;

select
  'platform11k_underlying_read_surface_rpc_acl_read_only' as section,
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  p.prosecdef as security_definer,
  has_function_privilege('authenticated', p.oid, 'EXECUTE') as authenticated_has_execute,
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
