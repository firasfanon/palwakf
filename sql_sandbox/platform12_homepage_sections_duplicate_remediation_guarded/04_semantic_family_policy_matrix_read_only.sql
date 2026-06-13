-- Platform 12 — Semantic Family Policy Matrix
-- READ ONLY. This does not decide policy; it exposes active overlaps that require content decision.

with family_map(section_name, semantic_family, default_recommendation) as (
  values
    ('pwf_news_tabs', 'news_family', 'usually_keep_if_tabs_are_home_primary'),
    ('pwf_news', 'news_family', 'deactivate_if_pwf_news_tabs_is_home_primary'),
    ('pwf_media_gallery', 'media_gallery_family', 'keep_only_if_unified_gallery_is_selected'),
    ('pwf_media_gallery_images', 'media_gallery_family', 'keep_if_split_gallery_policy_selected'),
    ('pwf_media_gallery_videos', 'media_gallery_family', 'keep_if_split_gallery_policy_selected'),
    ('pwf_quick_services', 'services_family', 'keep_if_compact_home_services_selected'),
    ('pwf_public_services_catalog', 'services_family', 'keep_if_catalog_home_strategy_selected'),
    ('pwf_eservices_portal', 'services_family', 'keep_if_portal_home_strategy_selected'),
    ('pwf_quick_links_grid', 'links_family', 'keep_if_grid_links_selected'),
    ('pwf_important_links', 'links_family', 'keep_if_important_links_selected')
)
select
  'semantic_family_policy_matrix' as diagnostic,
  coalesce(h.unit_id::text, 'GLOBAL_NULL') as unit_scope,
  f.semantic_family,
  h.section_name,
  coalesce(h.is_active, false) as is_active,
  h.display_order,
  f.default_recommendation,
  h.updated_at
from public.v_platform_homepage_sections_compat_v1 h
join family_map f on f.section_name = h.section_name
where coalesce(h.is_active, false)
order by unit_scope, f.semantic_family, h.display_order nulls last, h.section_name;
