-- Platform Database Ownership Closure — Dependency Reduction Retest Gate
-- 2026-05-26
-- READ ONLY. Re-run after applying the 10/ownership dependency-reduction Flutter baseline.

select
  'dependency_reduction_retest_gate' as section,
  'RETEST_REQUIRED' as decision,
  'Run SQL 05/06/07/08/09/10 after Flutter retest and browser-console evidence' as next_required_evidence,
  false::boolean as dependency_zero_certified_by_this_marker,
  false::boolean as rls_negative_uat_accepted_by_this_marker,
  false::boolean as browser_console_clean_accepted_by_this_marker,
  false::boolean as production_approved,
  false::boolean as archive_delete_authorized,
  false::boolean as exact_public_table_replacement_authorized;
