-- Public Services Root Cutover Analyzer/Runtime Closure Marker
-- Date: 2026-05-30
-- Type: READ ONLY marker / evidence statement
-- This file performs no DDL, no DML, no GRANT, no DROP, no archive/delete.

select
  'public_services_root_cutover_analyzer_runtime_closure'::text as section,
  true as dart_format_passed,
  true as flutter_analyze_clean,
  true as chrome_startup_passed,
  true as owner_read_default_runtime_evidenced,
  true as legacy_public_services_fallback_only,
  false as production_approved,
  true as public_legacy_preserved,
  true as no_waqf_assets_mutation,
  true as read_only;
