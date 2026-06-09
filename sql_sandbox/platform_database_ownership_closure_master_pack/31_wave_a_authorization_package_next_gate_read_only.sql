-- Platform Database Dependency Wave A
-- 31: authorization package next gate (read-only)
-- Purpose: define the single next package without authorizing execution.

select
  'wave_a_authorization_package_next_gate' as section,
  'PREPARE_GUARDED_BODY_DRAFT_ONLY_AFTER_OPERATOR_APPROVAL' as decision,
  'Next package may draft guarded replacement bodies for approved assistant/core/tasks access helpers only; it must remain fail-closed without token/backup.' as next_package_scope,
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
