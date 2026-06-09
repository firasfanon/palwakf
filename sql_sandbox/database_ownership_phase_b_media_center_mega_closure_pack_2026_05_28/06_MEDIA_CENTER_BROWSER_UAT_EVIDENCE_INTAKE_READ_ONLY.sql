-- Database Ownership Phase B — Media Center Browser UAT Evidence Intake Marker
-- READ ONLY / documentation marker only.
-- This script does not perform DDL, DML, GRANT, REVOKE, archive, delete, or exact public replacement.

select
  'phase_b_media_browser_uat_evidence_intake'::text as section,
  'BROWSER_UAT_EVIDENCE_ACCEPTED_SQL02_NOT_RUN'::text as decision,
  'Media Center DB ownership and compatibility are accepted; browser evidence accepted for public list/admin routes; detail clickthrough remains optional/pending for strict production gate.'::text as note,
  false::boolean as execution_authorized_by_this_script,
  false::boolean as production_approved,
  false::boolean as destructive_sql_authorized,
  false::boolean as exact_public_table_replacement_authorized,
  false::boolean as archive_delete_authorized,
  true::boolean as no_auth_users_migration,
  true::boolean as no_flutter_elevated_secret,
  true::boolean as no_waqf_assets_mutation,
  true::boolean as no_gis_mutation,
  true::boolean as read_only;
