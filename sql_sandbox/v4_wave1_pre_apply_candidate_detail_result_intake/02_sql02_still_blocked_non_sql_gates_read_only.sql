-- PalWakf V4 Wave1 SQL02 gate marker
-- READ ONLY: no DDL/DML/GRANT/DROP/REVOKE
select
  'v4_wave1_sql02_gate_after_candidate_detail' as section,
  false as owner_approvals_confirmed_by_this_script,
  false as flutter_dependency_zero_certified_by_this_script,
  false as backup_and_reversal_confirmed_by_this_script,
  false as role_rls_uat_confirmed_by_this_script,
  false as apply_pack_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as archive_authorized,
  false as production_approved,
  true as read_only,
  'SQL02_STILL_BLOCKED_PENDING_NON_SQL_GATES_OR_EXPLICIT_RISK_ACCEPTANCE' as decision;
