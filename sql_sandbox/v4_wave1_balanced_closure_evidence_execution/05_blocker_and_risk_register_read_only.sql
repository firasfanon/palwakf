with blockers(blocker_group, object_key, blocker_status, required_evidence, can_be_closed_in_balanced_pack) as (
  values
    ('role_rls_uat','35 RLS-enabled zero-policy targets','NEGATIVE_UAT_REQUIRED','anon/authenticated/unauthorized/out-of-scope evidence', true),
    ('sensitive_rls_disabled','10 sensitive RLS-disabled targets','OWNER_APPROVAL_REQUIRED','owner decision before production; no automatic RLS enablement', false),
    ('grant_delta','platform_access grant deltas','OWNER_REVIEW_REQUIRED','no GRANT/REVOKE unless explicit owner approval and protected script', true),
    ('browser_runtime','6 runtime smoke surfaces','BROWSER_UAT_REQUIRED','platform_access/media_center/service_center/navigation/core_gis/awqaf_system smoke', true),
    ('cross_lane_sovereign','D/E/H/I/J domain functions','OWNER_REVIEW_CARRIED_FORWARD','domain owner UAT before future apply', false)
)
select
  'v4_wave1_balanced_closure_evidence_execution_blocker_register'::text as section,
  blocker_group,
  object_key,
  blocker_status,
  required_evidence,
  can_be_closed_in_balanced_pack,
  false as blocker_resolved_by_this_script,
  false as grant_revoke_authorized_by_this_script,
  false as policy_change_authorized_by_this_script,
  false as production_approved,
  true as read_only
from blockers;
