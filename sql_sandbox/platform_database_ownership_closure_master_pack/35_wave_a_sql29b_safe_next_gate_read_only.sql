-- Platform Database Dependency Wave A
-- 35: SQL29B safe next gate (read-only)
-- Purpose: define the next package without authorizing execution.
-- No DDL/DML/GRANT/DROP/archive/delete/exact public replacement/auth migration/waqf mutation.

select
  'wave_a_sql29b_safe_next_gate'::text as section,
  'SQL29_RETIRED_SQL33_34_35_ACCEPTED_PATH_GUARDED_DRAFT_STILL_BLOCKED'::text as decision,
  'Next package may draft fail-closed guarded replacement bodies only after operator approval; execution remains blocked without exact body approval, backup, token, RLS evidence, and browser evidence.'::text as next_package_scope,
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
