-- Platform Navigation Compatibility Wrappers Validation Read-Only
-- Scope: validate new public compatibility views/RPCs that read from platform_navigation.
-- This file is SELECT-only and must not mutate public legacy tables.

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
  'platform_navigation_compatibility_wrappers_validation_read_only' as section,
  (select count(*) from public.services) as public_services_legacy_count,
  (select count(*) from platform_navigation.service_entries where source_public_table = 'public.services') as service_entries_owner_count,
  (select count(*) from public.v_platform_navigation_services_catalog_from_owner_v1) as services_owner_view_count,
  (select count(*) from public.home_services) as public_home_services_legacy_count,
  (select count(*) from platform_navigation.home_entries where source_public_table = 'public.home_services') as home_entries_owner_count,
  (select count(*) from public.v_platform_navigation_home_services_from_owner_v1) as home_owner_view_count,
  deps.services_view_depends_on_owner,
  deps.home_view_depends_on_owner,
  to_regprocedure('public.rpc_platform_navigation_services_catalog_from_owner_v1()') is not null as services_rpc_present,
  to_regprocedure('public.rpc_platform_navigation_home_services_from_owner_v1()') is not null as home_services_rpc_present,
  false as public_services_table_mutated_by_this_script,
  false as public_home_services_table_mutated_by_this_script,
  false as legacy_views_dropped_by_this_script,
  false as runtime_switch_executed_by_this_script,
  false as destructive_sql_authorized,
  false as delete_authorized_by_this_script,
  false as production_approved,
  true as read_only
from deps;
