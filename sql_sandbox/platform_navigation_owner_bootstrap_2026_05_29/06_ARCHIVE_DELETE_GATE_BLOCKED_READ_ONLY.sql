select
  'platform_navigation_archive_delete_gate'::text as section,
  'ARCHIVE_DELETE_BLOCKED'::text as decision,
  'This pack prepares owner bootstrap and migration plan only. public.services and public.home_services remain frozen legacy surfaces until dependency-zero, backup, rollback, and browser UAT evidence are complete.'::text as note,
  false as archive_authorized_by_this_script,
  false as delete_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as production_approved,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only;
