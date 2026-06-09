-- Mega Batch G — Public + Admin Pages Completion Read-only UAT
-- Purpose: verify homepage section rows if/when they are inserted by an approved migration.
-- This file is READ ONLY. It must not create or mutate production data.

select
  'mega_batch_g_homepage_section_presence' as section,
  section_name,
  is_active,
  display_order,
  unit_id
from public.homepage_sections
where section_name in (
  'pwf_media_center_highlights',
  'pwf_services_center_highlights',
  'pwf_social_posts_section',
  'pwf_press_releases_section',
  'pwf_official_statements_section',
  'pwf_awareness_campaigns_section',
  'pwf_sanctities_observatory_section',
  'pwf_legal_references_section',
  'pwf_events_section'
)
order by display_order nulls last, section_name;

select
  'mega_batch_g_duplicate_homepage_section_scope' as section,
  section_name,
  coalesce(unit_id::text, 'central') as scope_key,
  count(*) as duplicate_count
from public.homepage_sections
where section_name in (
  'pwf_media_center_highlights',
  'pwf_services_center_highlights',
  'pwf_social_posts_section',
  'pwf_press_releases_section',
  'pwf_official_statements_section',
  'pwf_awareness_campaigns_section',
  'pwf_sanctities_observatory_section',
  'pwf_legal_references_section',
  'pwf_events_section'
)
group by section_name, coalesce(unit_id::text, 'central')
having count(*) > 1
order by duplicate_count desc, section_name;
