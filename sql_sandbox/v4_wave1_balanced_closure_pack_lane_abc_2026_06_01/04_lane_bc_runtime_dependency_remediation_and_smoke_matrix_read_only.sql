with smoke(surface,lane_key,routes_or_rpc,expected_evidence,write_risk) as (
  values
    ('media_center_public','LANE_C_MEDIA_CENTER','/home/news, /home/announcements, /home/activities','Public read smoke; no regression after compatibility/owner-read decision.',false),
    ('media_center_admin','LANE_C_MEDIA_CENTER','/admin/media-center/news, /admin/media-center/announcements, /admin/media-center/activities','Admin read smoke + editorial action buttons remain gated.',true),
    ('media_center_editorial','LANE_C_MEDIA_CENTER','rpc_media_center_record_audit_event_v1 / rpc_media_center_record_editorial_event_v1','Write-risk editorial/audit RPC must remain owner-approved and audited.',true),
    ('platform_navigation_public_services','LANE_B_SERVICE_NAVIGATION','/home/services, /home/eservices','Public services render through compatibility view or owner-read RPC.',false),
    ('service_center_public_submit_track','LANE_B_SERVICE_NAVIGATION','/home/services/request, /home/services/track','Submit and track smoke; sensitive fields not exposed publicly.',true),
    ('service_center_admin_queue','LANE_B_SERVICE_NAVIGATION','/admin/surfaces-services/request-queue','Admin queue and transition smoke; illegal transitions rejected.',true)
)
select
  'v4_wave1_lane_bc_runtime_dependency_remediation_smoke_matrix'::text as section,
  surface,
  lane_key,
  routes_or_rpc,
  expected_evidence,
  write_risk,
  false as browser_uat_confirmed_by_this_script,
  false as owner_approved_by_this_script,
  false as apply_authorized_by_this_script,
  false as production_approved,
  true as read_only
from smoke
order by lane_key, surface;
