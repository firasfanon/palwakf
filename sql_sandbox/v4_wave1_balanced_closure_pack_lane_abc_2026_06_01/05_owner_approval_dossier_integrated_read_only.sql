with approvals(lane_key, owner_group, approval_artifact_required, minimum_evidence, may_enter_guarded_staging_apply) as (
  values
    ('LANE_A_PLATFORM_ACCESS','platform_access_owner','Exact bodies + RBAC/security owner sign-off + negative role/UAT evidence','A001-A016 negative RBAC + A017-A020 self-lockout/escalation + A021-A024 staging smoke',true),
    ('LANE_C_MEDIA_CENTER','media_center_owner','Exact bodies + media runtime/browser smoke + editorial workflow owner sign-off','public/admin smoke + editorial workflow smoke + no unauthorized write evidence',true),
    ('LANE_B_SERVICE_NAVIGATION','platform_navigation_owner/platform_services_owner','Exact bodies + service submit/track/admin queue smoke','submit/track/admin queue smoke + transition write-risk review',true),
    ('CARRY_FORWARD_D_E_H_I_J','domain owners','Owner review remains carried forward inside this balanced pack','No apply in this pack for D/E/H/I/J; owner blocks remain explicit',false)
)
select
  'v4_wave1_integrated_owner_approval_dossier'::text as section,
  lane_key,
  owner_group,
  approval_artifact_required,
  minimum_evidence,
  may_enter_guarded_staging_apply,
  false as owner_approved_by_this_script,
  false as rewrite_authorized_by_this_script,
  false as apply_authorized_by_this_script,
  false as production_approved,
  true as read_only
from approvals
order by case lane_key when 'LANE_A_PLATFORM_ACCESS' then 1 when 'LANE_C_MEDIA_CENTER' then 2 when 'LANE_B_SERVICE_NAVIGATION' then 3 else 4 end;
