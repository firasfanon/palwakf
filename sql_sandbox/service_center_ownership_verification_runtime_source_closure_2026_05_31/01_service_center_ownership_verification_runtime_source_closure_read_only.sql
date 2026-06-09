-- Service Center Ownership Verification + Runtime Source Closure
-- File: 01_service_center_ownership_verification_runtime_source_closure_read_only.sql
-- Date: 2026-05-31
-- Mode: READ ONLY / DIAGNOSTIC ONLY
-- Scope: platform_services ownership, public RPC wrapper presence, public-service legacy preservation.
-- No DDL, no DML, no GRANT, no DROP, no production approval, no waqf/awqaf_system/GIS mutation.

with required_tables as (
  select * from (values
    ('platform_services','service_forms_registry'),
    ('platform_services','service_requests'),
    ('platform_services','service_request_status_events'),
    ('platform_services','service_request_attachments')
  ) as t(schema_name, relation_name)
), required_rpcs as (
  select * from (values
    ('public','rpc_services_forms_public_v1'),
    ('public','rpc_services_submit_request_v1'),
    ('public','rpc_services_track_request_public_v1'),
    ('public','rpc_services_admin_request_queue_v1'),
    ('public','rpc_services_admin_transition_request_v1')
  ) as r(schema_name, routine_name)
), table_status as (
  select
    'required_platform_services_tables' as section,
    rt.schema_name || '.' || rt.relation_name as object_name,
    exists (
      select 1
      from pg_namespace n
      join pg_class c on c.relnamespace = n.oid
      where n.nspname = rt.schema_name
        and c.relname = rt.relation_name
        and c.relkind in ('r','p')
    ) as present
  from required_tables rt
), rpc_status as (
  select
    'required_public_rpc_wrappers' as section,
    rr.schema_name || '.' || rr.routine_name as object_name,
    exists (
      select 1
      from pg_namespace n
      join pg_proc p on p.pronamespace = n.oid
      where n.nspname = rr.schema_name
        and p.proname = rr.routine_name
    ) as present
  from required_rpcs rr
), rls_status as (
  select
    'platform_services_rls' as section,
    n.nspname || '.' || c.relname as object_name,
    c.relrowsecurity as present
  from pg_namespace n
  join pg_class c on c.relnamespace = n.oid
  where n.nspname = 'platform_services'
    and c.relname in (
      'service_forms_registry',
      'service_requests',
      'service_request_status_events',
      'service_request_attachments'
    )
), legacy_public_status as (
  select
    'legacy_public_service_catalog_preserved' as section,
    'public.' || c.relname as object_name,
    true as present
  from pg_namespace n
  join pg_class c on c.relnamespace = n.oid
  where n.nspname = 'public'
    and c.relname in ('services','home_services')
), sovereign_boundary as (
  select 'sovereign_boundary' as section, 'no_waqf_awqaf_system_gis_mutation' as object_name, true as present
  union all select 'runtime_decision', 'platform_services_rpc_default_runtime_source', true
  union all select 'runtime_decision', 'legacy_public_services_catalog_preserved_not_deleted', true
  union all select 'runtime_decision', 'production_not_approved', true
  union all select 'runtime_decision', 'read_only_script', true
)
select * from table_status
union all select * from rpc_status
union all select * from rls_status
union all select * from legacy_public_status
union all select * from sovereign_boundary
order by section, object_name;
