-- Public Services Route Alias Canonicalization Repair marker.
-- READ ONLY. No DDL/DML/GRANT/DROP.
select
  'public_services_route_alias_canonicalization_repair' as section,
  'PUBLIC_SERVICES_ROUTE_ALIAS_CANONICALIZATION_REPAIR_APPLIED_RETEST_REQUIRED' as decision,
  false as sql_production_change,
  false as public_services_deleted_or_archived,
  false as public_home_services_deleted_or_archived,
  false as default_runtime_switch_enabled,
  false as production_approved,
  true as no_waqf_awqaf_system_gis_mutation;
