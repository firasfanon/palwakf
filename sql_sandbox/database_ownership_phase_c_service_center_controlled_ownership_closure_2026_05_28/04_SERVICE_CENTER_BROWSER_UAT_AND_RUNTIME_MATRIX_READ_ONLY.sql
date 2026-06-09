-- PalWakf Platform
-- Database Ownership Phase C — Service Center Controlled Ownership Closure
-- 04_SERVICE_CENTER_BROWSER_UAT_AND_RUNTIME_MATRIX_READ_ONLY.sql
-- Purpose: required browser/network evidence matrix. SELECT-only.

with matrix(section, route_family, route_path, expected_runtime_source, expected_evidence) as (
  values
    ('phase_c_service_center_browser_runtime_uat_matrix','public_services','/home/services','public.v_services_catalog_compat_v1','services catalog loads with public cards and no red console/network errors'),
    ('phase_c_service_center_browser_runtime_uat_matrix','public_services','/home/eservices','public.v_services_catalog_compat_v1','e-services portal loads and remains responsive'),
    ('phase_c_service_center_browser_runtime_uat_matrix','public_services','/home/services/request','public.rpc_services_forms_public_v1 + public.rpc_services_submit_request_v1','request entry opens; submit test requires explicit UAT data and no sensitive leak'),
    ('phase_c_service_center_browser_runtime_uat_matrix','public_services','/home/services/track','public.rpc_services_track_request_public_v1','tracking page opens; public result exposes status/public note only'),
    ('phase_c_service_center_browser_runtime_uat_matrix','admin_services','/admin/surfaces-services','platform_services admin hub','admin hub opens without RenderFlex/PostgREST red errors'),
    ('phase_c_service_center_browser_runtime_uat_matrix','admin_services','/admin/surfaces-services/request-queue','public.rpc_services_admin_request_queue_v1','admin request queue loads for authorized admin'),
    ('phase_c_service_center_browser_runtime_uat_matrix','admin_services','/admin/surfaces-services/forms-registry','public.rpc_services_forms_public_v1 + platform_services.service_forms_registry','forms registry surface loads approved forms'),
    ('phase_c_service_center_browser_runtime_uat_matrix','admin_services','/admin/surfaces-services/requests','platform_services request workflow','request workflow surface opens; workflow transitions require controlled UAT'),
    ('phase_c_service_center_browser_runtime_uat_matrix','legacy_alias','/services','route canonicalization to /home/services','legacy alias redirects or renders without errors'),
    ('phase_c_service_center_browser_runtime_uat_matrix','legacy_alias','/services/request','route canonicalization to /home/services/request','legacy request alias redirects or renders without errors'),
    ('phase_c_service_center_browser_runtime_uat_matrix','legacy_alias','/services/track','route canonicalization to /home/services/track','legacy tracking alias redirects or renders without errors')
)
select
  section,
  route_family,
  route_path,
  expected_runtime_source,
  expected_evidence,
  false as evidence_accepted_by_this_script,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as archive_delete_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only
from matrix
order by route_family, route_path;
