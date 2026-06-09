-- Platform Navigation Runtime Source Certification Retest Marker — READ ONLY
-- Purpose: verify owner wrapper presence and nonzero read counts after Flutter 400 root-fix.
-- No DDL/DML/GRANT/DROP. No archive/delete. No production approval.

select
  'platform_navigation_runtime_source_certification_retest_marker_read_only' as section,
  to_regclass('public.v_platform_navigation_services_catalog_from_owner_v1') is not null as services_owner_view_present,
  to_regclass('public.v_platform_navigation_home_services_from_owner_v1') is not null as home_services_owner_view_present,
  case when to_regclass('public.v_platform_navigation_services_catalog_from_owner_v1') is not null
    then (select count(*) from public.v_platform_navigation_services_catalog_from_owner_v1)
    else 0 end as services_owner_view_count,
  case when to_regclass('public.v_platform_navigation_home_services_from_owner_v1') is not null
    then (select count(*) from public.v_platform_navigation_home_services_from_owner_v1)
    else 0 end as home_services_owner_view_count,
  false as runtime_switch_certified_by_this_sql,
  false as archive_delete_authorized,
  false as destructive_sql_authorized,
  false as public_legacy_mutation_authorized,
  false as production_approved,
  true as read_only;
