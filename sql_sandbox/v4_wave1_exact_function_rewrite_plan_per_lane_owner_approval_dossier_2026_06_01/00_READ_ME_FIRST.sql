select
  '00_read_me_first' as section,
  'V4_WAVE1_EXACT_FUNCTION_REWRITE_PLAN_PER_LANE_OWNER_APPROVAL_DOSSIER' as package_key,
  'READ_ONLY_DOSSIER_AND_REWRITE_PLAN_ONLY' as execution_mode,
  false as rerun_sql02_move_authorized,
  false as rollback_authorized,
  false as wave3_move_authorized,
  false as compatibility_views_removal_authorized,
  false as grant_revoke_authorized,
  false as ddl_dml_authorized,
  false as production_approved,
  true as read_only,
  'Run 01,02,03,04,05,06,07,08. Do not run 99 unless reviewing skeleton text only.' as instruction;
