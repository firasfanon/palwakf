-- Service Center Browser UAT Retest Result Intake Marker
-- Date: 2026-05-31
-- Type: read-only marker / no DDL / no DML

select
  'service_center_browser_uat_retest_result_intake'::text as section,
  'SERVICE_CENTER_BROWSER_UAT_RETEST_PARTIAL_ACCEPTED_RUNTIME_SOURCE_CERTIFIED_FOR_FORMS_AND_ADMIN_QUEUE_PUBLIC_REQUEST_SUBMIT_RETEST_PENDING_PRODUCTION_NOT_APPROVED'::text as decision,
  true as forms_registry_browser_evidence_accepted,
  true as admin_queue_browser_evidence_accepted,
  true as public_tracking_canonical_route_opened,
  false as public_request_submit_route_evidence_complete,
  false as admin_transition_evidence_complete,
  false as production_approved,
  true as no_waqf_assets_mutation_in_this_script,
  true as read_only;
