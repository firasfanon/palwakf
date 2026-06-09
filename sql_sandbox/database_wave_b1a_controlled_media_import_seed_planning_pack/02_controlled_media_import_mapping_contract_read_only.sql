-- 02_controlled_media_import_mapping_contract_read_only.sql
-- Draft mapping contract only. No DML.
with mapping(source_table, content_kind, target_table, status_strategy, source_trace_strategy, decision) as (
  values
    ('public.news_articles','news','media_center.content_items','map published/active to published else draft','legacy_source=public.news_articles + source id','candidate_after_column_shape_review'),
    ('public.activities','activity','media_center.content_items','map published/active to published else draft','legacy_source=public.activities + source id','candidate_after_content_type_mapping'),
    ('public.announcements','announcement','media_center.content_items','map active/published to published else draft','legacy_source=public.announcements + source id','candidate_after_visibility_mapping'),
    ('public.breaking_news','breaking_news','media_center.content_items','manual review; avoid auto published if semantic unclear','legacy_source=public.breaking_news + source id','manual_semantics_review_required'),
    ('public.news','news_legacy','media_center.content_items','manual duplicate review','legacy_source=public.news + source id','review_for_duplicate_or_legacy_shape'),
    ('public.media_gallery_items','gallery_asset','media_center.content_assets','inherit linked content state if relation exists','legacy_source=public.media_gallery_items + source id','asset_mapping_required')
)
select 'controlled_media_import_mapping_contract' section, *, 'draft_only_not_applied' apply_state from mapping;
