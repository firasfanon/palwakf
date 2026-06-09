-- Public Services Runtime Source Root Cutover UAT Marker — READ ONLY

select
  'public_services_runtime_source_root_cutover_uat_marker' as section,
  'platform_navigation_owner_read_default' as runtime_default,
  'legacy_public_services_fallback_only' as legacy_status,
  false as delete_public_services_authorized,
  false as delete_public_home_services_authorized,
  false as archive_delete_authorized,
  false as production_approved,
  false as waqf_assets_mutation_authorized,
  true as read_only;
