-- APPLY: least-privilege authenticated read grants.
-- Grants are restricted to the exact listed surfaces only.

begin;

grant usage on schema core to authenticated;

grant select on core.v_core_location_backlog_operational_queue_v1 to authenticated;
grant select on core.v_core_locations_with_lgus_v1 to authenticated;

grant execute on function public.rpc_core_location_runtime_certification_v1() to authenticated;
grant execute on function public.rpc_core_location_backlog_summary_v1() to authenticated;
grant execute on function public.rpc_core_location_backlog_operational_queue_v1(text,text,text,integer,integer) to authenticated;

commit;

select
  'platform11k_core_location_authenticated_read_surface_grants_applied' as section,
  true as core_schema_usage_granted,
  true as exact_core_view_select_granted,
  true as exact_public_rpc_execute_granted,
  false as dml_executed,
  false as public_locations_recreated,
  false as gis_locations_boundary_created,
  false as waqf_assets_mutated,
  false as production_approved;
