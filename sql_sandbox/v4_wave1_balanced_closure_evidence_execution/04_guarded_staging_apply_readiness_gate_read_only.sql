select
  'v4_wave1_guarded_staging_apply_readiness_gate'::text as section,
  'LANE_ABC'::text as scope,
  false as exact_rewritten_body_diff_supplied,
  false as owner_approval_recorded,
  false as negative_rbac_uat_confirmed,
  false as browser_runtime_smoke_confirmed,
  false as rollback_or_no_rollback_decision_recorded,
  false as execution_token_supplied,
  false as guarded_staging_apply_ready,
  'BLOCKED_PENDING_EVIDENCE_AND_EXPLICIT_TOKEN'::text as decision,
  true as read_only;
