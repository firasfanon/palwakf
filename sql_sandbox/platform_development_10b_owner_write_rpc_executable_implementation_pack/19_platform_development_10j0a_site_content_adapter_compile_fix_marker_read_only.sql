-- Platform Development 10J-0A marker only.
-- Read-only evidence row; no DDL/DML.
select
  'platform_development_10j0a' as section,
  'site_content_adapter_compile_fix_prepared' as check_key,
  true as passed,
  'Flutter compile blocker fix prepared; full SQL17 and admin/write console evidence remain required.' as note
union all
select
  'sovereign_boundary' as section,
  'no_auth_users_mutation_no_service_role_no_waqf_assets_mutation' as check_key,
  true as passed,
  'Marker query only; no auth.users DML, no service_role, no waqf/waqf_assets mutation.' as note;
