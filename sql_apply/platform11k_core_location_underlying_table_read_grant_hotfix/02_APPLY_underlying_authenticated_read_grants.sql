-- 02_APPLY_underlying_authenticated_read_grants.sql
-- APPLY: underlying read grants only.
-- No data mutation. No object recreation.

begin;

grant usage on schema core to authenticated;

-- Required by the error hint.
grant select on core.core_locations to authenticated;

-- Required by core location + LGU read surfaces.
grant select on core.core_lgus to authenticated;

-- Keep view grants from the previous package.
grant select on core.v_core_location_backlog_operational_queue_v1 to authenticated;
grant select on core.v_core_locations_with_lgus_v1 to authenticated;

-- Optional underlying surfaces if present in this database version.
do $$
begin
  if to_regclass('core.core_location_lgu_bridge_candidates') is not null then
    execute 'grant select on core.core_location_lgu_bridge_candidates to authenticated';
  end if;

  if to_regclass('core.core_location_backlog_review_decisions') is not null then
    execute 'grant select on core.core_location_backlog_review_decisions to authenticated';
  end if;

  if to_regclass('core.v_core_location_backlog_review_v1') is not null then
    execute 'grant select on core.v_core_location_backlog_review_v1 to authenticated';
  end if;
end $$;

-- Reconfirm execute on the exact public RPC surfaces.
grant execute on function public.rpc_core_location_runtime_certification_v1() to authenticated;
grant execute on function public.rpc_core_location_backlog_summary_v1() to authenticated;
grant execute on function public.rpc_core_location_backlog_operational_queue_v1(text,text,text,integer,integer) to authenticated;

commit;

select
  'platform11k_underlying_authenticated_read_grants_applied' as section,
  true as core_schema_usage_granted,
  true as core_locations_select_granted,
  true as core_lgus_select_granted,
  true as exact_view_select_grants_reconfirmed,
  true as exact_public_rpc_execute_reconfirmed,
  false as dml_executed,
  false as public_locations_recreated,
  false as gis_locations_boundary_created,
  false as waq_assets_mutated,
  false as production_approved;
