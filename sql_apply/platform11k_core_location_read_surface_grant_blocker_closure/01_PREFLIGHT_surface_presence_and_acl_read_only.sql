-- Read-only. Confirms object presence and current authenticated ACLs.

select
  'platform11k_core_location_grant_preflight_presence_read_only' as section,
  surface,
  case
    when kind = 'relation' and to_regclass(surface) is not null then 'present'
    when kind = 'function' and to_regprocedure(surface) is not null then 'present'
    else 'missing'
  end as presence_status,
  false as production_approved
from (
  values
    ('core.v_core_location_backlog_operational_queue_v1', 'relation'),
    ('core.v_core_locations_with_lgus_v1', 'relation'),
    ('public.rpc_core_location_runtime_certification_v1()', 'function'),
    ('public.rpc_core_location_backlog_summary_v1()', 'function'),
    ('public.rpc_core_location_backlog_operational_queue_v1(text,text,text,integer,integer)', 'function')
) as v(surface, kind);

select
  'platform11k_core_location_grant_preflight_view_acl_read_only' as section,
  n.nspname as schema_name,
  c.relname as object_name,
  has_schema_privilege('authenticated', n.nspname, 'USAGE') as authenticated_has_schema_usage,
  has_table_privilege('authenticated', format('%I.%I', n.nspname, c.relname), 'SELECT') as authenticated_has_select,
  false as production_approved
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where (n.nspname, c.relname) in (
  ('core', 'v_core_location_backlog_operational_queue_v1'),
  ('core', 'v_core_locations_with_lgus_v1')
)
order by n.nspname, c.relname;

select
  'platform11k_core_location_grant_preflight_function_acl_read_only' as section,
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
