-- Service Center Runtime Evidence Intake Read-Only Marker
-- Date: 2026-05-31
-- Purpose: read-only documentation marker only.
select
  'service_center_runtime_evidence_intake' as section,
  'analyzer_clean_chrome_run_dependency_blocker_recorded' as decision,
  true as read_only,
  false as production_approved,
  false as ddl_dml_grant_drop_performed,
  false as waqf_awqaf_system_gis_mutation;
