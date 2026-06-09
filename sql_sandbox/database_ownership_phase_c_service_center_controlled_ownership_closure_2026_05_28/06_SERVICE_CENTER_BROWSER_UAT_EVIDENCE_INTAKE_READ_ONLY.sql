-- Database Ownership Phase C — Service Center Browser UAT Evidence Intake
-- Date: 2026-05-28
-- READ ONLY MARKER ONLY. This script performs no DDL/DML/GRANT/DROP.
select
  'phase_c_service_center_browser_uat_evidence_intake'::text as section,
  'SERVICE_CENTER_BROWSER_UAT_EVIDENCE_ACCEPTED_WITH_AUTH_CONSOLE_WARNING_PRODUCTION_DEFERRED'::text as decision,
  'SQL02 not run; public/admin routes rendered; admin auth-token 400 warning requires strict-console follow-up.'::text as note,
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
