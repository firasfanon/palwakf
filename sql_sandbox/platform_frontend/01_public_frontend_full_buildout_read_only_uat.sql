-- Mega Batch D — Public Frontend Full Buildout — Read-only UAT
-- Purpose: verify public frontend runtime sources without mutating PalWakf data.
-- This file is SELECT-only by design.

select
  'public_frontend_required_routes_contract' as section,
  route_key,
  route_path,
  expected_owner
from (
  values
    ('home', '/', 'dynamic public shell'),
    ('services', '/services', 'services center'),
    ('eservices', '/eservices', 'services center'),
    ('service_request', '/services/request', 'services center'),
    ('service_tracking', '/services/track', 'services center'),
    ('media_center', '/media-center', 'media center'),
    ('social_posts', '/social-posts', 'media center'),
    ('press_releases', '/press-releases', 'media center'),
    ('official_statements', '/official-statements', 'media center'),
    ('awareness_campaigns', '/awareness-campaigns', 'media center'),
    ('legal_references', '/legal-references', 'official references / services center'),
    ('sanctities_observatory', '/sanctities-observatory', 'media center observatory')
) as routes(route_key, route_path, expected_owner)
order by route_key;

select
  'homepage_sections_public_frontend_scope' as section,
  section_name,
  is_active,
  display_order,
  unit_id,
  coalesce(settings, '{}'::jsonb) as settings
from public.homepage_sections
where section_name in (
  'pwf_public_services_catalog',
  'pwf_eservices_portal',
  'pwf_quick_services',
  'pwf_important_links',
  'pwf_media_center',
  'pwf_legal_references',
  'pwf_sanctities_observatory'
)
order by unit_id nulls first, display_order, section_name;

select
  'public_services_catalog_safety' as section,
  count(*) filter (where is_active is true) as active_services,
  count(*) filter (where route_path like '/:%') as route_pattern_rows,
  count(*) filter (where lower(coalesce(service_key, title_ar, '')) like any (array['%waqf_asset%', '%asset%', '%property%', '%real_estate%'])) as possible_waqf_property_rows
from public.services;

select
  'homepage_section_scope_duplicates' as section,
  section_name,
  unit_id,
  count(*) as duplicates
from public.homepage_sections
where section_name in (
  'pwf_public_services_catalog',
  'pwf_eservices_portal',
  'pwf_quick_services',
  'pwf_important_links',
  'pwf_media_center',
  'pwf_legal_references',
  'pwf_sanctities_observatory'
)
group by section_name, unit_id
having count(*) > 1
order by section_name, unit_id nulls first;
