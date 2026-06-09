-- Database Wave B-1A — Controlled Media Import/Seed Contract Review
-- 03: Apply-candidate review matrix. No DML.

select * from (values
  ('news_articles', 'public.news_articles -> media_center.content_items', 'news', 'auto-map published/active to published else draft', 'eligible_in_apply_candidate'),
  ('activities', 'public.activities -> media_center.content_items', 'activity', 'auto-map published/active to published else draft', 'eligible_in_apply_candidate'),
  ('announcements', 'public.announcements -> media_center.content_items', 'announcement', 'auto-map active/published to published else draft', 'eligible_in_apply_candidate'),
  ('breaking_news', 'public.breaking_news -> media_center.content_items', 'breaking_news', 'draft-only pending semantics review', 'eligible_as_draft_only_optional'),
  ('media_gallery_items', 'public.media_gallery_items -> media_center.content_assets', 'gallery_asset', 'requires content relation and asset mapping', 'blocked'),
  ('news_legacy', 'public.news -> media_center.content_items', 'news_legacy', 'requires duplicate/legacy shape review', 'blocked'),
  ('flutter_media_reroute', 'public media runtime -> public.v_media_*_compat_v1', 'runtime', 'requires nonzero wrappers after seed', 'blocked_until_apply_uat'),
  ('wave_b1b', 'selective sovereign extraction', 'extraction', 'not authorized', 'blocked')
) as t(section, mapping_key, content_kind, strategy, review_decision);
