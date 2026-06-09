-- Platform Database Dependency Wave A
-- 29: superseded marker after repeated SQL-runner relation parser failure (read-only)
-- Purpose: prevent further retries of the unstable review-matrix script name.
-- Use SQL 33/34/35 instead. No DDL/DML/GRANT/DROP/archive/delete/exact replacement.

select
  'wave_a_sql29_superseded_safe_marker'::text as section,
  'SQL29_SUPERSEDED_BY_SQL33_NO_SCHEMA_TOKEN_MATRIX'::text as decision,
  'Do not retry SQL 29 for the review matrix. Run SQL 33, then SQL 34, then SQL 35. Execution remains blocked.'::text as next_required_action,
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
