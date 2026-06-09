-- Database Wave B-1A — Media Center Bootstrap Row/Boundary UAT
-- Read-only: verifies empty bootstrap state and unchanged legacy public media tables presence.
select * from (values
  ('media_center_bootstrap_counts','media_center.content_items', (select count(*)::text from media_center.content_items), 'expected_empty_or_seedless_after_bootstrap'),
  ('media_center_bootstrap_counts','media_center.content_assets', (select count(*)::text from media_center.content_assets), 'expected_empty_or_seedless_after_bootstrap'),
  ('media_center_bootstrap_counts','media_center.editorial_events', (select count(*)::text from media_center.editorial_events), 'expected_empty_or_seedless_after_bootstrap'),
  ('media_center_bootstrap_counts','media_center.content_publication_channels', (select count(*)::text from media_center.content_publication_channels), 'expected_empty_or_seedless_after_bootstrap'),
  ('media_center_bootstrap_counts','media_center.content_category_map', (select count(*)::text from media_center.content_category_map), 'expected_empty_or_seedless_after_bootstrap'),
  ('legacy_public_media_presence','public.activities', (select exists(select 1 from information_schema.tables where table_schema='public' and table_name='activities')::text), 'legacy_public_table_preserved'),
  ('legacy_public_media_presence','public.announcements', (select exists(select 1 from information_schema.tables where table_schema='public' and table_name='announcements')::text), 'legacy_public_table_preserved'),
  ('legacy_public_media_presence','public.news_articles', (select exists(select 1 from information_schema.tables where table_schema='public' and table_name='news_articles')::text), 'legacy_public_table_preserved')
) as t(section, object_name, observed_value, note);
