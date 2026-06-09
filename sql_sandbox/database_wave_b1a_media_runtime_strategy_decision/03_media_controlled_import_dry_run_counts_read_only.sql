-- Database Wave B-1A Media Runtime Strategy Decision
-- 03_media_controlled_import_dry_run_counts_read_only.sql
-- Read-only dry-run source count matrix. Does not insert/import/delete.

select * from (
  select 'controlled_media_import_dry_run_counts' as section,
         'public.news_articles' as source_object,
         'media_center.content_items' as proposed_target,
         (select count(*) from public.news_articles)::bigint as source_row_count,
         'candidate_after_column_mapping_and_publication_state_review' as decision
  union all
  select 'controlled_media_import_dry_run_counts',
         'public.activities',
         'media_center.content_items',
         (select count(*) from public.activities)::bigint,
         'candidate_after_content_type_mapping'
  union all
  select 'controlled_media_import_dry_run_counts',
         'public.announcements',
         'media_center.content_items',
         (select count(*) from public.announcements)::bigint,
         'candidate_after_publication_visibility_mapping'
  union all
  select 'controlled_media_import_dry_run_counts',
         'public.news',
         'media_center.content_items',
         (select count(*) from public.news)::bigint,
         'review_for_duplicate_or_legacy_shape'
  union all
  select 'controlled_media_import_dry_run_counts',
         'public.breaking_news',
         'media_center.content_items',
         (select count(*) from public.breaking_news)::bigint,
         'high_risk_visibility_semantics_review_required'
  union all
  select 'controlled_media_import_dry_run_counts',
         'public.media_gallery_items',
         'media_center.content_assets',
         (select count(*) from public.media_gallery_items)::bigint,
         'asset_mapping_required_before_import'
) s
order by source_object;
