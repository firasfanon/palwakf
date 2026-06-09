-- Database Wave B-1A — Controlled Media Import/Seed Apply UAT
-- Read-only verification after 01_controlled_media_import_seed_apply.sql.

with expected_sources(source_table, content_type, minimum_expected_source_rows) as (
  values
    ('public.news_articles','news',0),
    ('public.activities','activity',0),
    ('public.announcements','announcement',0),
    ('public.breaking_news','breaking_news',0)
), seeded as (
  select legacy_source, content_type, status, count(*)::bigint as rows_count
  from media_center.content_items
  where legacy_source in ('public.news_articles','public.activities','public.announcements','public.breaking_news')
  group by legacy_source, content_type, status
), totals as (
  select legacy_source, count(*)::bigint as total_seeded
  from media_center.content_items
  where legacy_source in ('public.news_articles','public.activities','public.announcements','public.breaking_news')
  group by legacy_source
)
select
  'controlled_media_seed_apply_uat' as section,
  es.source_table,
  es.content_type,
  coalesce(t.total_seeded, 0) as total_seeded_items,
  coalesce((select sum(rows_count) from seeded s where s.legacy_source = es.source_table and s.status = 'published'),0) as published_items,
  coalesce((select sum(rows_count) from seeded s where s.legacy_source = es.source_table and s.status = 'draft'),0) as draft_items,
  case
    when es.source_table='public.breaking_news' then 'draft_only_expected_for_semantics_review'
    when coalesce(t.total_seeded, 0) > 0 then 'seeded_or_previously_seeded'
    else 'no_rows_seeded_check_source_or_mapping'
  end as apply_decision
from expected_sources es
left join totals t on t.legacy_source = es.source_table
order by es.source_table;

-- Duplicate safety check.
select
  'controlled_media_seed_duplicate_uat' as section,
  legacy_source,
  legacy_source_id,
  count(*) as duplicate_count,
  case when count(*) = 1 then 'passed_unique_legacy_key' else 'duplicate_detected_review_required' end as decision
from media_center.content_items
where legacy_source in ('public.news_articles','public.activities','public.announcements','public.breaking_news')
group by legacy_source, legacy_source_id
having count(*) > 1;

-- Editorial trace check.
select
  'controlled_media_seed_editorial_trace_uat' as section,
  action_key,
  count(*) as event_count,
  case when count(*) > 0 then 'trace_present' else 'trace_missing_review_required' end as decision
from media_center.editorial_events
where action_key = 'controlled_legacy_seed'
group by action_key;
