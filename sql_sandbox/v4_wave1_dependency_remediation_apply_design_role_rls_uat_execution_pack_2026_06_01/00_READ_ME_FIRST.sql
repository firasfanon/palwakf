-- PalWakf V4 Wave1 Dependency Remediation Apply Design + Role/RLS UAT Execution Pack
-- Date: 2026-06-01
-- Safety: READ ONLY unless file name explicitly says FUTURE/SKELETON; no DDL/DML/GRANT/REVOKE/DROP/DELETE/ARCHIVE/RENAME.
-- Context: SQL02 move already applied. Do not rerun Wave1 SQL02 move.
-- Production: NOT APPROVED.

select
  '00_read_me_first' as section,
  'V4_WAVE1_DEPENDENCY_REMEDIATION_APPLY_DESIGN_ROLE_RLS_UAT_EXECUTION_PACK' as package_key,
  'READ_ONLY_DESIGN_AND_UAT_GATE_ONLY' as execution_mode,
  false as rerun_sql02_move_authorized,
  false as rollback_authorized,
  false as wave3_move_authorized,
  false as compatibility_views_removal_authorized,
  false as grant_revoke_authorized,
  false as production_approved,
  true as read_only,
  'Run 01,02,03,04,05,06,07. Do not run 99 unless reviewing the skeleton text only.' as instruction;
