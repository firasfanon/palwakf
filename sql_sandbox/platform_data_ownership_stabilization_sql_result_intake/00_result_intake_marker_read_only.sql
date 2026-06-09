-- Platform Data Ownership Stabilization SQL Result Intake Marker
-- Date: 2026-05-21
-- Read-only marker only. No DML, no DDL, no mutation.

select
  'platform_data_ownership_sql_result_intake' as section,
  'execution-plan-approved-with-guards-not-executed' as decision,
  'content_assets legacy_source shape gap recorded; controlled execution must be guarded' as note;
