with approvals(lane_key, owner_group, approval_artifact_required) as (
  values
    ('LANE_A_PLATFORM_ACCESS','platform_access_owner','Exact exported bodies + RBAC/security owner sign-off + negative role/UAT evidence'),
    ('LANE_B_SERVICE_NAVIGATION','platform_navigation_owner/platform_services_owner','Exact exported bodies + service submit/track/admin queue smoke'),
    ('LANE_C_MEDIA_CENTER','media_center_owner','Exact exported bodies + media runtime/browser smoke + editorial workflow owner sign-off'),
    ('LANE_D_DOCUMENT_WAQF_CMS','cms_waqf_joint_owner','Exact exported bodies + CMS/Waqf document owner sign-off'),
    ('LANE_E_CORE_GIS_LOOKUP','core_gis_owner/gis_owner','Lookup smoke + read-only reference owner sign-off'),
    ('LANE_H_COMPLAINTS','complaints_owner','Submit/track/purge exact body review + write-risk sign-off'),
    ('LANE_I_AWQAF_SYSTEM','awqaf_system_owner','Awqaf Assist/content owner review + analyzer/runtime gate'),
    ('LANE_J_WAQF_RELIGIOUS_ZAKAT','waqf/religious/zakat owners','Domain owner UAT and exact body review')
)
select
  'v4_wave1_per_lane_owner_approval_matrix' as section,
  *,
  false as owner_approved_by_this_script,
  false as rewrite_authorized_by_this_script,
  false as apply_authorized_by_this_script,
  false as compatibility_views_removal_authorized,
  false as grant_revoke_authorized,
  false as production_approved,
  true as read_only
from approvals;
