-- Database Wave B-1A.0
-- Runtime reroute readiness report for B-1A.1.
-- Read-only report.

select *
from (
  values
    ('b1a1_runtime_reroute_plan', 'services_catalog_provider', 'switch-read-source-to-public.v_services_catalog_compat_v1-or-rpc_services_catalog_compat_v1', 'allowed-after-b1a0-uat-pass', 'no layout or route rewrite'),
    ('b1a1_runtime_reroute_plan', 'home_services_section', 'switch-read-source-to-public.v_home_services_compat_v1-or-rpc_home_services_compat_v1', 'allowed-after-homepage-uat-plan', 'homepage_sections remains separate dependency'),
    ('b1a1_runtime_reroute_plan', 'service_types_lookup', 'switch-read-source-to-public.v_service_types_compat_v1 if used directly', 'optional-after-code-scan', 'taxonomy extraction still blocked'),
    ('b1a1_runtime_reroute_plan', 'service_points_provider', 'do-not-reroute-until-owner-decision', 'blocked', 'servicepoints may belong to facilities or gis'),
    ('b1a1_runtime_reroute_plan', 'service_providers_provider', 'do-not-reroute-until-owner-decision', 'blocked', 'providers/facilities ownership unresolved'),
    ('sovereign_boundary', 'waqf_assets', 'no action', 'forbidden', 'no mutation/no extraction/no wrapper activation in Wave B-1A.0'),
    ('sovereign_boundary', 'locations', 'no action', 'blocked', 'locations authority gate remains open'),
    ('sovereign_boundary', 'media_center', 'no action', 'deferred', 'media bootstrap required before activation')
) as t(section, runtime_area, recommended_action, readiness_status, note)
order by section, runtime_area;
