-- PalWakf V4 Wave1 Dependency Remediation Design + UAT Result Intake
-- Read-only marker. No DDL/DML/GRANT/REVOKE.
select
  'v4_wave1_dependency_remediation_design_uat_result_intake' as section,
  'V4_WAVE1_DEPENDENCY_REMEDIATION_DESIGN_UAT_RESULT_INTAKEN_PRODUCTION_BLOCKED' as decision,
  false as ddl_authorized_by_this_script,
  false as grant_revoke_authorized_by_this_script,
  false as compatibility_views_removal_authorized,
  false as wave3_move_authorized,
  false as production_approved,
  true as read_only;
