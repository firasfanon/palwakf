with matrix as (
  select 'news_articles'::text as source_table,
         (select count(*) from public.news_articles)::bigint as source_rows,
         (select count(*) from media_center.content_items where legacy_source='news_articles')::bigint as seeded_rows,
         'content_items'::text as target_contract,
         'candidate_for_controlled_b1b_reconcile'::text as decision
  union all
  select 'announcements', (select count(*) from public.announcements),
         (select count(*) from media_center.content_items where legacy_source='announcements'),
         'content_items', 'candidate_for_controlled_b1b_reconcile'
  union all
  select 'activities', (select count(*) from public.activities),
         (select count(*) from media_center.content_items where legacy_source='activities'),
         'content_items', 'requires_mapping_and_nonzero_public_wrapper_before_reroute'
  union all
  select 'media_gallery_items', (select count(*) from public.media_gallery_items),
         (select count(*) from media_center.content_assets where legacy_source='media_gallery_items'),
         'content_assets/content_items', 'requires_asset_content_mapping_before_reroute'
)
select 'media_migration_candidate_matrix' as section, * from matrix
order by source_table;
