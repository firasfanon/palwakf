-- Platform Navigation Owner Census Result Intake — READ ONLY
-- Date: 2026-05-29
-- Purpose: record the accepted operator result in a query output only. No DDL/DML.

select
  'platform_navigation_owner_census_result_intake'::text as section,
  'public.home_services'::text as source_name,
  true as source_present,
  3::integer as row_count,
  'legacy_homepage_navigation_surface'::text as classification,
  false as migration_authorized_by_this_script,
  false as delete_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as production_approved,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only
union all
select
  'platform_navigation_owner_census_result_intake',
  'public.services',
  true,
  9,
  'legacy_public_service_entry_navigation_catalog',
  false,
  false,
  false,
  false,
  true,
  true,
  true,
  true,
  true;
