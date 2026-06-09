with evidence(lane_key, evidence_key, actor_or_surface, expected_result, required_artifact, can_close_in_this_pack) as (
  values
    ('LANE_A_PLATFORM_ACCESS','A_NEG_001','anonymous','DENY_OR_EMPTY','No admin identity/roles/permissions exposed to anonymous users.', true),
    ('LANE_A_PLATFORM_ACCESS','A_NEG_002','authenticated_without_admin_profile','DENY_OR_EMPTY','Authenticated user without admin profile receives no platform-admin privilege.', true),
    ('LANE_A_PLATFORM_ACCESS','A_NEG_003','unit_admin_out_of_scope','DENY_OR_LIMITED_TO_SCOPE','Unit admin cannot access other-unit/global platform roles.', true),
    ('LANE_A_PLATFORM_ACCESS','A_NEG_004','system_admin_wrong_system','DENY_OR_LIMITED_TO_SYSTEM','System admin cannot obtain unrelated system permissions.', true),
    ('LANE_A_PLATFORM_ACCESS','A_NEG_005','self_lockout_attempt','DENY','Self role delete/revoke of escalation-sensitive permission denied.', true),
    ('LANE_A_PLATFORM_ACCESS','A_NEG_006','privilege_escalation_non_superuser','DENY','Non-superuser cannot grant root/superuser/platform-admin/owner role.', true),
    ('LANE_A_PLATFORM_ACCESS','A_AUDIT_001','authorized_owner_write','ALLOW_AUDITED','Owner-write audit event and deterministic rollback note required.', true),
    ('LANE_B_SERVICE_NAVIGATION','B_SMOKE_001','/home/services / /home/eservices','RENDER_CONSOLE_CLEAN','Public services render through compatibility or owner-read RPC.', true),
    ('LANE_B_SERVICE_NAVIGATION','B_SMOKE_002','/home/services/request / /home/services/track','SUBMIT_TRACK_SAFE','Submit/track smoke with sensitive fields hidden.', true),
    ('LANE_B_SERVICE_NAVIGATION','B_SMOKE_003','/admin/surfaces-services/request-queue','QUEUE_TRANSITION_SAFE','Admin queue smoke and illegal transitions denied.', true),
    ('LANE_C_MEDIA_CENTER','C_SMOKE_001','/home/news / /home/announcements / /home/activities','PUBLIC_RENDER_CONSOLE_CLEAN','Public media read smoke.', true),
    ('LANE_C_MEDIA_CENTER','C_SMOKE_002','/admin/media-center/news / announcements / activities','ADMIN_READ_SAFE','Admin read smoke; action buttons gated.', true),
    ('LANE_C_MEDIA_CENTER','C_SMOKE_003','editorial/audit RPC','WRITE_RISK_GATED_AUDITED','Audit/editorial write-risk evidence.', true),
    ('CARRY_FORWARD_D_E_H_I_J','DOMAIN_OWNER_REVIEW','domain functions','OWNER_REVIEW_REQUIRED','No apply in this pack for D/E/H/I/J.', false)
)
select
  'v4_wave1_lane_abc_integrated_evidence_matrix'::text as section,
  lane_key,
  evidence_key,
  actor_or_surface,
  expected_result,
  required_artifact,
  can_close_in_this_pack,
  false as evidence_confirmed_by_this_script,
  false as apply_authorized_by_this_script,
  false as production_approved,
  true as read_only
from evidence
order by lane_key, evidence_key;
