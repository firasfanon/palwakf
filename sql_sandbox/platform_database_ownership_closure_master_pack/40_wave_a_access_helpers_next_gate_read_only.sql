-- Platform Database Dependency Wave A — Access Helpers Actual Remediation Pack
-- SQL 40: next gate, read-only.

select
  'wave_a_access_helpers_next_gate' as section,
  'ACTUAL_REMEDIATION_PACK_PREPARED_EXECUTION_FAIL_CLOSED' as decision,
  'SQL 37 contains actual guarded replacement bodies for assistant/core/tasks access helpers. Run 36 first. Do not run 37 unless exact body approval, backup, token, RLS negative UAT, and browser/network evidence are supplied. After authorized run, execute 38/39 and attach results.' as next_required_action,
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
