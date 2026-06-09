-- Database Ownership Wave A — Safe Stop + Architectural Re-decision
-- SQL 41: read-only final decision marker.
-- No DDL, no DML, no grants, no destructive action.

select
  'database_ownership_wave_a_safe_stop'::text as section,
  'DO_NOT_EXECUTE_WAVE_A_ACCESS_HELPER_REPLACEMENT'::text as decision,
  'Close Wave A as analysis/classification/preflight only; preserve compatibility layer; defer access-helper rewrite to future Auth/RBAC migration.'::text as note,
  true as sql36_preflight_passed,
  false as sql37_execution_authorized,
  true as sql37_guard_blocked_expected,
  false as dependency_zero_certified,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as archive_delete_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as read_only;
