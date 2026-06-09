-- Public Services Runtime Source Root Cutover Diagnostics — READ ONLY
-- No DDL. No DML. No GRANT. No DELETE. No ARCHIVE. No production approval.

select
  'public_services_root_cutover_diagnostics' as section,
  to_regclass('public.v_platform_navigation_services_catalog_from_owner_v1') is not null as services_owner_view_present,
  to_regclass('public.v_platform_navigation_home_services_from_owner_v1') is not null as home_owner_view_present,
  to_regclass('public.v_services_catalog_compat_v1') is not null as legacy_services_compat_view_present,
  to_regclass('public.services') is not null as public_services_table_preserved,
  to_regclass('public.home_services') is not null as public_home_services_table_preserved,
  false as destructive_sql_authorized,
  false as archive_delete_authorized,
  false as production_approved,
  true as read_only;

select
  'platform_navigation_services_catalog_owner_sample' as section,
  count(*) as row_count
from public.v_platform_navigation_services_catalog_from_owner_v1;

select
  'platform_navigation_home_services_owner_sample' as section,
  count(*) as row_count
from public.v_platform_navigation_home_services_from_owner_v1;
