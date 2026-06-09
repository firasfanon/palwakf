-- Platform Database Dependency Wave A
-- 32: SQL 29 core-relation parser hotfix marker (read-only)
-- Purpose: record that SQL 29 was rewritten without VALUES recordset syntax after
-- ERROR 42P01: relation "core" does not exist.
-- No DDL/DML/GRANT/DROP/archive/delete/exact replacement is performed.

select
  'wave_a_sql29_core_relation_hotfix'::text as section,
  'SQL29A_REWRITTEN_UNION_ALL_MATRIX_NO_RELATION_CORE_REFERENCE'::text as decision,
  'Retry SQL 29, then run SQL 30 and SQL 31. Execution remains blocked.'::text as next_required_action,
  true as sql28_result_intake_received,
  true as sql25_exact_body_export_supplied,
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
