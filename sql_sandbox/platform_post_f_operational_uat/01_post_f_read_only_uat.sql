-- Post-F Operational UAT read-only checks.
-- No DDL/DML. Do not modify waqf_assets from platform side.

select
  'post_f_public_services_active_rows' as section,
  count(*) as value
from public.services
where coalesce(is_active, true) = true;

select
  'post_f_homepage_public_services_section' as section,
  section_name,
  is_active,
  display_order,
  unit_id
from public.homepage_sections
where section_name = 'pwf_public_services_catalog'
order by unit_id nulls first, display_order;

select
  'post_f_cross_system_contract_readiness' as section,
  'read_only_contract_layer_only' as value,
  'Platform must not mutate waqf_assets; awqaf_system remains owner' as notes;

select
  'post_f_waqf_assets_platform_no_mutation_policy' as section,
  'no platform-side create/update/delete/approve/link workflow' as policy;
