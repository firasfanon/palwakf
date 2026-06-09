-- V4_WAVE1_BALANCED_CLOSURE_PACK_LANE_ABC_RUNTIME_DEPENDENCY_REMEDIATION_RBAC_RLS_UAT_OWNER_APPROVAL_GUARDED_STAGING
-- READ THIS FIRST
-- Scope: balanced integrated closure pack for Lane A/B/C only.
-- Mode: read-only by default. Guarded staging apply option is present but not authorized by default.
-- Sovereign restrictions preserved: no waqf/waqf_assets/awqaf_system/GIS mutation.
select
  '00_read_me_first'::text as section,
  'V4_WAVE1_BALANCED_CLOSURE_PACK_LANE_ABC_RUNTIME_DEPENDENCY_REMEDIATION_RBAC_RLS_UAT_OWNER_APPROVAL_GUARDED_STAGING'::text as package_key,
  'BALANCED_READ_ONLY_DEFAULT_WITH_GUARDED_STAGING_APPLY_OPTION'::text as execution_mode,
  false as rerun_sql02_move_authorized,
  false as rollback_authorized,
  false as wave3_move_authorized,
  false as compatibility_views_removal_authorized,
  false as grant_revoke_authorized,
  false as ddl_dml_authorized_by_default,
  false as guarded_staging_apply_authorized_by_default,
  false as production_approved,
  true as read_only_default,
  'Run 01,02,03,04,05,06,08,09 first. 07 is a guarded staging apply option and must not run unless owner approval and execution token are explicitly supplied. Do not run 99 except text review.'::text as instruction;
