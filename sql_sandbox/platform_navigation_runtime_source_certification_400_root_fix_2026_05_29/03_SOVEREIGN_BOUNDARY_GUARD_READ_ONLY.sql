-- Platform Navigation Runtime Source Certification Sovereign Boundary Guard — READ ONLY
-- Purpose: document that this certification/root-fix pack is non-destructive.

select
  'platform_navigation_runtime_source_certification_sovereign_boundary_guard' as section,
  true as no_waqf_assets_mutation,
  true as no_waqf_schema_mutation,
  true as no_awqaf_system_mutation,
  true as no_gis_mutation,
  true as no_public_services_delete_or_archive,
  true as no_public_home_services_delete_or_archive,
  false as production_approved,
  true as read_only;
