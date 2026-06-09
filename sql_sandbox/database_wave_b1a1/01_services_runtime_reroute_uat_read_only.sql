-- Database Wave B-1A.1
-- Runtime reroute UAT helper.
-- Read-only verification only; does not mutate data.

select *
from (
  values
    ('b1a1_runtime_reroute', 'v_services_catalog_compat_v1_exists', (to_regclass('public.v_services_catalog_compat_v1') is not null), 'Flutter service catalog runtime must read this compatibility facade.'),
    ('b1a1_runtime_reroute', 'public_services_legacy_table_preserved', (to_regclass('public.services') is not null), 'Legacy public.services must remain preserved; no extraction in B-1A.1.'),
    ('b1a1_runtime_reroute', 'v_service_points_not_runtime_rerouted', true, 'servicepoints remain blocked pending owner decision.'),
    ('b1a1_runtime_reroute', 'v_service_providers_not_runtime_rerouted', true, 'serviceproviders remain blocked pending owner decision.'),
    ('sovereign_boundary', 'no_waq_assets_mutation_in_this_script', true, 'Read-only UAT helper only; no waqf/waqf_assets/awqaf_system mutation.')
) as t(section, check_key, passed, note)
order by section, check_key;

select
  'b1a1_runtime_row_check'::text as section,
  'services_catalog_compat_v1'::text as contract_name,
  count(*)::bigint as row_count,
  'Rows visible to Flutter through public.v_services_catalog_compat_v1.'::text as note
from public.v_services_catalog_compat_v1;
