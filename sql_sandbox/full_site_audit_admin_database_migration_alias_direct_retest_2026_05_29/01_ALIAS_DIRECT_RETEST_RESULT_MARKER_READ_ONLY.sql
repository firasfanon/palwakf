/*
Full Site Audit — Admin Database Migration Alias Direct Retest Result Marker
Date: 2026-05-29
READ ONLY MARKER ONLY.
No DDL/DML/GRANT/DROP.
*/
select
  'full_site_audit_admin_database_migration_alias_direct_retest'::text as section,
  'canonical_route_rendered_alias_retest_conditionally_accepted'::text as decision,
  'If operator entered /admin/database-migration and landed on /admin/platform/database-migration, alias redirect is accepted. Production still deferred unless this is explicitly confirmed.'::text as note,
  false as execution_authorized_by_this_script,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as archive_delete_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only;
