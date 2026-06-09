with lane_summary(lane_key, domain_key, candidate_count, priority_order, owner_group, current_status) as (
  values
    ('LANE_A_PLATFORM_ACCESS','platform_access',24,1,'platform_access_owner','OWNER_APPROVAL_PENDING'),
    ('LANE_C_MEDIA_CENTER','media_center',14,2,'media_center_owner','OWNER_APPROVAL_PENDING'),
    ('LANE_B_SERVICE_NAVIGATION','platform_navigation_services',11,3,'platform_navigation_owner/platform_services_owner','OWNER_APPROVAL_PENDING')
), targets(candidate_range,lane_key,area,recommended_decision,required_evidence) as (
  values
    ('A001-A016','LANE_A_PLATFORM_ACCESS','platform_access read/RBAC helpers','OWNER_SCHEMA_REROUTE_OR_KEEP_COMPAT_REVIEW','RBAC owner sign-off + anon/authenticated/unauthorized/out-of-scope negative role UAT'),
    ('A017-A020','LANE_A_PLATFORM_ACCESS','platform_access write-risk role/permission RPCs','WRITE_RISK_MANUAL_REVIEW','owner approval + self-lockout + privilege escalation UAT + rollback plan'),
    ('A021-A024','LANE_A_PLATFORM_ACCESS','platform owner write helper functions','OWNER_REVIEW_REQUIRED','platform_access owner sign-off + function-level staging smoke'),
    ('C001-C014','LANE_C_MEDIA_CENTER','readiness/family/editorial/audit/CMS feed functions','READ_PATH_REVIEW_THEN_OPTIONAL_OWNER_SCHEMA_REROUTE','media runtime smoke + editorial owner sign-off'),
    ('B001-B011','LANE_B_SERVICE_NAVIGATION','service queue/transition/catalog/home services functions','KEEP_COMPAT_VIEW_UNTIL_RPC_BODY_REVIEW','service submit/track/admin queue smoke + write-risk review')
)
select
  'v4_wave1_lane_abc_candidate_inventory_and_rewrite_targets'::text as section,
  t.candidate_range,
  t.lane_key,
  s.domain_key,
  s.candidate_count as lane_candidate_count,
  s.priority_order,
  s.owner_group,
  t.area,
  t.recommended_decision,
  t.required_evidence,
  false as owner_approved_by_this_script,
  false as rewrite_authorized_by_this_script,
  false as apply_authorized_by_this_script,
  false as production_approved,
  true as read_only
from targets t join lane_summary s using (lane_key)
order by s.priority_order, t.candidate_range;
