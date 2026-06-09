-- Database Wave B-1A — Controlled Media Import/Seed Contract Review
-- 02: Duplicate/visibility preflight. No DML.

with expected_sources as (
  select * from (values
    ('public.news_articles','news','candidate'),
    ('public.activities','activity','candidate'),
    ('public.announcements','announcement','candidate'),
    ('public.breaking_news','breaking_news','draft_only_manual_visibility'),
    ('public.news','news_legacy','blocked_duplicate_shape_review'),
    ('public.media_gallery_items','gallery_asset','blocked_asset_mapping')
  ) as t(legacy_source, content_kind, decision)
), target_state as (
  select
    es.legacy_source,
    es.content_kind,
    es.decision,
    case when to_regclass('media_center.content_items') is null then 0
         else (select count(*) from media_center.content_items ci where ci.legacy_source = es.legacy_source)
    end as existing_seeded_items,
    case when to_regclass('media_center.v_content_items_public_v1') is null then 0
         else (select count(*) from media_center.v_content_items_public_v1)
    end as current_public_view_rows
  from expected_sources es
)
select
  'controlled_media_import_preflight' as section,
  legacy_source,
  content_kind,
  decision,
  existing_seeded_items,
  current_public_view_rows,
  case
    when decision like 'blocked%' then 'do_not_apply_in_next_seed'
    when existing_seeded_items > 0 then 'idempotency_review_required_before_apply'
    else 'eligible_for_apply_candidate_if_explicitly_approved'
  end as preflight_decision
from target_state
order by legacy_source;
