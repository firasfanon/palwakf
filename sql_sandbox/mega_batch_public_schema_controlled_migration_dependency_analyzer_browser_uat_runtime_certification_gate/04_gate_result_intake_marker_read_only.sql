-- 04_gate_result_intake_marker_read_only.sql
-- Public Schema Controlled Migration Gate Result Intake Marker
-- SELECT-only. No DDL, no DML, no destructive operation, no waqf mutation.

select
  'public_schema_gate_result_intake'::text as section,
  'sql_safety_gate_passed_analyzer_clean_chrome_startup_passed'::text as decision,
  false as production_approved,
  false as exact_public_table_name_replacement_authorized,
  false as destructive_sql_authorized,
  false as dependency_zero_certified,
  false as browser_console_clean_evidence_accepted,
  true as analyzer_clean_accepted,
  true as chrome_startup_accepted,
  true as no_waqf_assets_mutation;
