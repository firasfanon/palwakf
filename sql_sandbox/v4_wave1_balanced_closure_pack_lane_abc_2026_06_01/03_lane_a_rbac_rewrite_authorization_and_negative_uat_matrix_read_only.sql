with matrix(test_key, candidate_range, actor_profile, expected_result, evidence_required, applies_to) as (
  values
    ('A_NEG_001','A001-A016','anonymous','DENY_OR_EMPTY','No platform_access helper should expose admin identity/roles/permissions to anonymous users.','read/RBAC helpers'),
    ('A_NEG_002','A001-A016','authenticated_without_admin_profile','DENY_OR_EMPTY','Authenticated user without admin_users/profile must not receive platform_admin privileges.','read/RBAC helpers'),
    ('A_NEG_003','A001-A016','unit_admin_out_of_scope','DENY_OR_LIMITED_TO_SCOPE','Unit admin must not read/manage other unit or global platform roles.','read/RBAC helpers'),
    ('A_NEG_004','A001-A016','system_admin_wrong_system','DENY_OR_LIMITED_TO_SYSTEM','System admin must not obtain permissions for unrelated systems.','read/RBAC helpers'),
    ('A_NEG_005','A017-A020','self_lockout_attempt','DENY','Self role delete/revoke escalation-sensitive permissions must be denied.','write-risk role/permission RPCs'),
    ('A_NEG_006','A017-A020','privilege_escalation_non_superuser','DENY','Non-superuser must not grant superuser/platform_admin/root/owner roles.','write-risk role/permission RPCs'),
    ('A_POS_001','A001-A024','platform_superuser','ALLOW_AUDITED','Positive control: platform superuser can read/manage within audited owner-write path.','all lane A'),
    ('A_AUDIT_001','A017-A020','authorized_owner_write','AUDIT_REQUIRED','Every grant/revoke/upsert/delete must produce owner-write audit event and deterministic rollback note.','write-risk role/permission RPCs')
)
select
  'v4_wave1_lane_a_negative_rbac_uat_matrix'::text as section,
  test_key,
  candidate_range,
  actor_profile,
  expected_result,
  evidence_required,
  applies_to,
  false as evidence_confirmed_by_this_script,
  false as rewrite_authorized_by_this_script,
  false as apply_authorized_by_this_script,
  false as production_approved,
  true as read_only
from matrix
order by test_key;
