-- Database Wave B-1A.0
-- Contract matrix for service compatibility activation.
-- Read-only report.

select *
from (
  values
    ('service_catalog', 'public.services', 'public.v_services_catalog_compat_v1', 'public.rpc_services_catalog_compat_v1', 'platform_services', 'activated-read-only-facade', 'runtime-reroute-required-in-b1a1', 'no extraction'),
    ('home_services', 'public.home_services', 'public.v_home_services_compat_v1', 'public.rpc_home_services_compat_v1', 'platform_services_or_platform_content', 'activated-read-only-facade', 'homepage-coupling-validation-required', 'no extraction'),
    ('service_types', 'public.servicetypes', 'public.v_service_types_compat_v1', null, 'platform_services', 'activated-read-only-facade', 'taxonomy-mapping-required-before-extraction', 'no extraction'),
    ('service_providers', 'public.serviceproviders', 'public.v_service_providers_compat_v1', null, 'platform_services_or_facilities', 'activated-read-only-facade', 'manual-owner-decision-required', 'no extraction'),
    ('service_points', 'public.servicepoints', 'public.v_service_points_compat_v1', null, 'platform_services_or_facilities_or_gis', 'activated-read-only-facade', 'manual-owner-decision-required', 'no extraction')
) as t(contract_key, legacy_source, compatibility_view, compatibility_rpc, target_owner_schema, activation_state, blocker_or_next_validation, extraction_state)
order by contract_key;
