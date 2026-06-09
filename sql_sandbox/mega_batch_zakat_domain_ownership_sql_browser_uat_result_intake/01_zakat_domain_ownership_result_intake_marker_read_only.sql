-- Zakat Domain Ownership SQL/Browser UAT Result Intake Marker
-- Read-only marker only. Do not run as production DDL/DML.
select
  'zakat_domain_ownership_result_intake' as section,
  'ZAKAT_SCHEMA_WRAPPER_READY_BROWSER_UAT_REQUIRED' as decision,
  'production_not_approved_by_sql_alone' as production_gate,
  true as no_waq_assets_mutation;
