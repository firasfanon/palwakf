-- 09_execution_sql_apply_result_intake_marker_read_only.sql
-- Purpose: marker-only read-only script for the SQL apply result intake baseline.
-- This file performs no DDL/DML and does not touch sovereign schemas.
select
  'controlled_execution_sql_apply_result_intake' as section,
  'CONTROLLED_EXECUTION_SQL_PASSED_BROWSER_UAT_REQUIRED' as decision,
  true as no_waq_assets_mutation_in_this_script,
  true as browser_uat_required,
  false as production_approved_by_sql_alone;
