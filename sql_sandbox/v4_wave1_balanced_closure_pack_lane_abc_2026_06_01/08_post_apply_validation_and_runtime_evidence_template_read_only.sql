with validation(check_key, expected_after_guarded_apply, evidence_required) as (
  values
    ('lane_a_function_signatures_present','All A001-A024 signatures remain present and callable in staging.','SQL function existence + smoke call evidence'),
    ('lane_a_negative_rbac_passed','Anonymous/authenticated unauthorized/out-of-scope role checks pass.','negative UAT table/screenshots/logs'),
    ('lane_a_owner_write_audit_present','A017-A020 writes produce audit and block self-lockout/escalation.','audit event evidence + denied cases'),
    ('lane_b_services_runtime_passed','Public services + request + track + admin queue smoke pass.','browser screenshots + console clean + marker evidence'),
    ('lane_c_media_runtime_passed','Public/admin media center read smoke and editorial workflow smoke pass.','browser screenshots + audit/editorial event evidence'),
    ('no_compatibility_view_removed','88 public compatibility views remain unless separately authorized.','catalog count'),
    ('no_wave3_mutation','Wave3 collision tables untouched.','catalog and audit evidence')
)
select
  'v4_wave1_post_apply_validation_and_runtime_evidence_template'::text as section,
  check_key,
  expected_after_guarded_apply,
  evidence_required,
  false as evidence_supplied_by_this_script,
  false as production_approved,
  true as read_only
from validation;
