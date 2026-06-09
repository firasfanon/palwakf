-- Public Services Runtime Source Root Cutover Browser UAT Result Intake
-- READ-ONLY marker. No DDL/DML/GRANT/DROP.
select
  'public_services_runtime_source_root_cutover_browser_uat_result_intake' as section,
  'PUBLIC_SERVICES_RUNTIME_SOURCE_ROOT_CUTOVER_BROWSER_UAT_ACCEPTED_PRODUCTION_DEFERRED' as decision,
  true as platform_navigation_owner_read_default_evidenced,
  true as public_legacy_preserved,
  false as production_approved,
  false as destructive_sql_authorized,
  true as read_only;
