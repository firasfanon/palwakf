-- Platform Navigation Strict Console External Error Triage Marker
-- Date: 2026-05-30
-- READ ONLY: this file is a governance/evidence marker only.

select
  'platform_navigation_strict_console_external_error_triage_read_only' as section,
  true as supabase_direct_browser_no_apikey_classified_as_direct_open_artifact,
  true as aladhan_direct_api_200_ok_evidence_received,
  true as platform_navigation_owner_read_source_already_certified_by_console_marker,
  false as runtime_switch_executed_by_this_script,
  false as production_approved,
  false as destructive_sql_authorized,
  true as public_services_preserved,
  true as public_home_services_preserved,
  true as no_waq_assets_mutation_in_this_script,
  true as read_only;
