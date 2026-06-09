-- Service Center Submit + Tracking Public Workflow Evidence Intake marker
-- Date: 2026-05-31
-- Read-only marker only; no DDL, DML, GRANT, DROP, or production mutation.

select
  'service_center_submit_tracking_public_workflow_evidence_intake' as section,
  true as read_only,
  true as no_sql_production,
  true as no_ddl_dml_grant_drop,
  true as no_direct_flutter_platform_services_table_write,
  true as no_service_role_in_flutter,
  true as no_waqf_awqaf_system_gis_mutation,
  'SERVICE_CENTER_PUBLIC_SUBMIT_AND_TRACKING_RPC_EVIDENCE_ACCEPTED_STRICT_SAME_NUMBER_TRACE_PENDING_ADMIN_TRANSITION_PENDING_PRODUCTION_NOT_APPROVED' as decision;
