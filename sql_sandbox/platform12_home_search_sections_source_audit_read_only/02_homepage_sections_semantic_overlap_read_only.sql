-- Platform 12 — Homepage Sections Semantic Overlap Diagnostics
-- READ ONLY. Identifies active section families that may look duplicated to users.

with family_map(section_name, semantic_family) as (
  values
    ('pwf_news_tabs', 'news_family'),
    ('pwf_news', 'news_family'),
    ('news', 'news_family'),
    ('pwf_media_gallery', 'media_gallery_family'),
    ('pwf_media_gallery_images', 'media_gallery_family'),
    ('pwf_media_gallery_videos', 'media_gallery_family'),
    ('pwf_quick_services', 'services_family'),
    ('services', 'services_family'),
    ('pwf_public_services_catalog', 'services_family'),
    ('pwf_eservices_portal', 'services_family'),
    ('pwf_quick_links_grid', 'links_family'),
    ('pwf_important_links', 'links_family')
), source_rows as (
  select
    coalesce(unit_id::text, 'GLOBAL_NULL') as unit_scope,
    section_name,
    coalesce(is_active, false) as is_active,
    display_order,
    updated_at
  from public.v_platform_homepage_sections_compat_v1
)
select
  'semantic_overlap_active_sections' as diagnostic,
  r.unit_scope,
  f.semantic_family,
  count(*) filter (where r.is_active) as active_count,
  array_agg(r.section_name order by r.display_order nulls last, r.section_name) filter (where r.is_active) as active_sections,
  max(r.updated_at) filter (where r.is_active) as latest_active_update
from source_rows r
join family_map f on f.section_name = r.section_name
group by r.unit_scope, f.semantic_family
having count(*) filter (where r.is_active) > 1
order by active_count desc, r.unit_scope, f.semantic_family;

-- Expected interpretation:
-- - news_family: usually choose either pwf_news_tabs or pwf_news.
-- - media_gallery_family: usually choose unified gallery OR split images/videos, not all.
-- - services_family: choose the intended public services strategy for the homepage.
