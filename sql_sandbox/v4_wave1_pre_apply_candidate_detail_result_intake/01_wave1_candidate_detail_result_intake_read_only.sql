-- PalWakf V4 Wave1 candidate detail result intake marker
-- READ ONLY: no DDL/DML/GRANT/DROP/REVOKE
select
  'v4_wave1_candidate_detail_result_intake' as section,
  88::int as candidate_rows_accepted,
  88::int as public_table_present_true,
  88::int as target_schema_present_true,
  0::int as target_table_collision_true,
  false as apply_authorized_by_this_script,
  false as production_approved,
  true as read_only,
  'V4_WAVE1_PRE_APPLY_CANDIDATE_DETAIL_ACCEPTED_SQL02_STILL_BLOCKED_BY_NON_SQL_GATES'::text as decision;
