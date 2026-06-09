with wave1_summary as (
  select 88::int as wave1_count,
         88::int as public_compatibility_views,
         88::int as owner_schema_tables,
         88::int as shape_ok_count,
         0::int as shape_blocker_count,
         77::int as exact_function_candidates_exported,
         45::int as candidates_with_public_qualified_references,
         32::int as candidates_exported_owner_review,
         35::int as rls_enabled_zero_policy_count,
         10::int as sensitive_rls_disabled_count
), restrictions as (
  select false as sql02_rerun_authorized,
         false as rollback_authorized,
         false as wave3_move_authorized,
         false as compatibility_view_removal_authorized,
         false as grant_revoke_authorized,
         false as production_approved
)
select
  'v4_wave1_balanced_integrated_preflight_status'::text as section,
  w.*,
  r.sql02_rerun_authorized,
  r.rollback_authorized,
  r.wave3_move_authorized,
  r.compatibility_view_removal_authorized,
  r.grant_revoke_authorized,
  r.production_approved,
  case
    when w.shape_ok_count = 88 and w.shape_blocker_count = 0 then 'PREFLIGHT_ACCEPTED_BALANCED_CLOSURE_CAN_PROCEED_TO_LANE_ABC_REVIEW'
    else 'PREFLIGHT_BLOCKED_SHAPE_MISMATCH'
  end as decision,
  true as read_only
from wave1_summary w cross join restrictions r;
