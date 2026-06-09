-- Platform Database Dependency Wave A
-- 28: exact body export result intake (read-only)
-- Purpose: record that SQL 24/25/26/27 evidence has been supplied and that execution remains blocked.
-- No DDL, DML, GRANT, DROP, archive/delete, exact public table replacement, auth.users migration,
-- Flutter elevated secret, or waqf/awqaf mutation is performed by this script.

select
  'wave_a_exact_body_export_result_intake' as section,
  'EXACT_BODY_EXPORT_ACCEPTED_FOR_REVIEW_EXECUTION_STILL_BLOCKED' as decision,
  true as sql24_result_intake_received,
  true as sql25_exact_body_export_supplied,
  true as sql26_execution_gate_received,
  true as sql27_rls_browser_matrix_received,
  false as exact_body_review_complete,
  false as execution_authorized,
  false as dependency_zero_certified,
  false as rls_negative_uat_accepted,
  false as browser_console_clean_accepted,
  false as token_backup_governance_accepted,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as archive_delete_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as read_only;
