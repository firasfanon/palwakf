-- Platform Public Runtime Consolidation — 2026-05-30
-- READ ONLY MARKER.
-- This script intentionally performs no DDL, no DML, no GRANT, no DROP, no archive/delete.

select
  'platform_public_runtime_consolidation_read_only_marker' as section,
  true as read_only,
  false as production_approved,
  false as default_runtime_switch_authorized,
  false as archive_delete_authorized,
  false as public_services_delete_authorized,
  false as public_home_services_delete_authorized,
  true as no_waqf_assets_mutation;
