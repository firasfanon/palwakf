-- Read-only evidence checklist for V4 Wave1 balanced gate.
select * from (values
('A_NEG_001','LANE_A_PLATFORM_ACCESS','anonymous','DENY_OR_EMPTY','pending'),
('A_NEG_002','LANE_A_PLATFORM_ACCESS','authenticated_without_admin_profile','DENY_OR_EMPTY','pending'),
('A_NEG_003','LANE_A_PLATFORM_ACCESS','unit_admin_out_of_scope','DENY_OR_LIMITED_TO_SCOPE','pending'),
('A_NEG_004','LANE_A_PLATFORM_ACCESS','system_admin_wrong_system','DENY_OR_LIMITED_TO_SYSTEM','pending'),
('A_NEG_005','LANE_A_PLATFORM_ACCESS','self_lockout_attempt','DENY','pending'),
('A_NEG_006','LANE_A_PLATFORM_ACCESS','privilege_escalation_non_superuser','DENY','pending'),
('A_AUDIT_001','LANE_A_PLATFORM_ACCESS','authorized_owner_write','ALLOW_AUDITED','pending'),
('B_SMOKE_001','LANE_B_SERVICE_NAVIGATION','/home/services / /home/eservices','RENDER_CONSOLE_CLEAN','pending'),
('B_SMOKE_002','LANE_B_SERVICE_NAVIGATION','/home/services/request / track','SUBMIT_TRACK_SAFE','pending'),
('B_SMOKE_003','LANE_B_SERVICE_NAVIGATION','/admin/surfaces-services/request-queue','QUEUE_TRANSITION_SAFE','pending'),
('C_SMOKE_001','LANE_C_MEDIA_CENTER','public media pages','PUBLIC_RENDER_CONSOLE_CLEAN','pending'),
('C_SMOKE_002','LANE_C_MEDIA_CENTER','admin media center','ADMIN_READ_SAFE','pending'),
('C_SMOKE_003','LANE_C_MEDIA_CENTER','editorial/audit RPC','WRITE_RISK_GATED_AUDITED','pending')
) as t(evidence_key,lane_key,actor_or_surface,expected_result,status);
