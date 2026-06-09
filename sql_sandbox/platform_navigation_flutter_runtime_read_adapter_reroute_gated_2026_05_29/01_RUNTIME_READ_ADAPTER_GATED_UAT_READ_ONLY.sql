-- PalWakf Platform Navigation Flutter Runtime Read-Adapter Reroute Gated UAT
-- Read-only. This file validates the owner-read public surfaces required by
-- the Flutter gated adapter. It does not execute Flutter runtime switch,
-- archive/delete, production approval, or any mutation.

with deps as (
  select
    exists (
      select 1
      from pg_depend d
      join pg_rewrite r on r.oid = d.objid
      join pg_class v on v.oid = r.ev_class
      join pg_namespace vn on vn.oid = v.relnamespace
      join pg_class t on t.oid = d.refobjid
      join pg_namespace tn on tn.oid = t.relnamespace
      where vn.nspname = 'public'
        and v.relname = 'v_platform_navigation_services_catalog_from_owner_v1'
        and tn.nspname = 'platform_navigation'
        and t.relname = 'service_entries'
    ) as services_view_depends_on_owner,
    exists (
      select 1
      from pg_depend d
      join pg_rewrite r on r.oid = d.objid
      join pg_class v on v.oid = r.ev_class
      join pg_namespace vn on vn.oid = v.relnamespace
      join pg_class t on t.oid = d.refobjid
      join pg_namespace tn on tn.oid = t.relnamespace
      where vn.nspname = 'public'
        and v.relname = 'v_platform_navigation_home_services_from_owner_v1'
        and tn.nspname = 'platform_navigation'
        and t.relname = 'home_entries'
    ) as home_view_depends_on_owner
)
select
  'platform_navigation_flutter_runtime_read_adapter_reroute_gated_uat_read_only'::text as section,
  to_regclass('public.v_platform_navigation_services_catalog_from_owner_v1') is not null as services_owner_view_present,
  to_regclass('public.v_platform_navigation_home_services_from_owner_v1') is not null as home_services_owner_view_present,
  case when to_regclass('public.v_platform_navigation_services_catalog_from_owner_v1') is not null
    then (select count(*) from public.v_platform_navigation_services_catalog_from_owner_v1)
    else 0 end as services_owner_view_count,
  case when to_regclass('public.v_platform_navigation_home_services_from_owner_v1') is not null
    then (select count(*) from public.v_platform_navigation_home_services_from_owner_v1)
    else 0 end as home_services_owner_view_count,
  deps.services_view_depends_on_owner,
  deps.home_view_depends_on_owner,
  to_regprocedure('public.rpc_platform_navigation_services_catalog_from_owner_v1()') is not null as services_owner_rpc_present,
  to_regprocedure('public.rpc_platform_navigation_home_services_from_owner_v1()') is not null as home_services_owner_rpc_present,
  false as flutter_runtime_switch_executed_by_this_sql,
  false as public_services_table_mutated_by_this_sql,
  false as public_home_services_table_mutated_by_this_sql,
  false as legacy_archive_delete_authorized,
  false as destructive_sql_authorized,
  false as production_approved,
  true as read_only
from deps;
