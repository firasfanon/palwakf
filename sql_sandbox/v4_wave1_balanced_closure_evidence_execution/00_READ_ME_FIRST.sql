select
  '00_read_me_first'::text as section,
  'V4_WAVE1_BALANCED_CLOSURE_RESULT_INTAKE_EVIDENCE_EXECUTION_PACK'::text as package_key,
  'READ_ONLY_RESULT_INTAKE_AND_EVIDENCE_EXECUTION_DEFAULT'::text as execution_mode,
  false as rerun_sql02_move_authorized,
  false as rollback_authorized,
  false as wave3_move_authorized,
  false as compatibility_views_removal_authorized,
  false as grant_revoke_authorized,
  false as ddl_dml_authorized_by_default,
  false as guarded_staging_apply_authorized_by_default,
  false as production_approved,
  true as read_only,
  'Run 01,02,03,04,05,06,07. Do not run 90/99 except text review. No apply is included by default.'::text as instruction;
