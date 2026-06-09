-- Database Wave B-1A — Controlled Media Import/Seed Apply Pack
-- APPLY SCRIPT: explicitly approved controlled seed into media_center.content_items.
-- Scope: INSERT-only into media_center.content_items/editorial_events from reviewed public media legacy sources.
-- Does NOT delete/move/alter public media tables.
-- Does NOT activate Flutter runtime reroute.
-- Does NOT activate Wave B-1B extraction.
-- Does NOT mutate waqf/waqf_assets/awqaf_system.

begin;

-- 0) Guard required contracts.
do $$
begin
  if to_regnamespace('media_center') is null then
    raise exception 'Required schema media_center does not exist.';
  end if;
  if to_regclass('media_center.content_items') is null then
    raise exception 'Required target media_center.content_items does not exist.';
  end if;
  if to_regclass('media_center.editorial_events') is null then
    raise exception 'Required target media_center.editorial_events does not exist.';
  end if;
  if to_regclass('media_center.v_content_items_public_v1') is null then
    raise exception 'Required media_center public view does not exist.';
  end if;
end $$;

-- 1) Idempotency index for controlled seed safety.
create unique index if not exists ux_media_content_items_legacy_source_id
  on media_center.content_items (legacy_source, legacy_source_id)
  where legacy_source is not null and legacy_source_id is not null;

-- 2) Seed reviewed public.news_articles as news.
insert into media_center.content_items (
  legacy_source, legacy_source_id, content_key, content_type,
  title_ar, title_en, summary_ar, summary_en, body_ar, body_en,
  category_key, status, visibility_scope, source_public_table, published_at, metadata
)
select
  'public.news_articles' as legacy_source,
  coalesce(j->>'id', j->>'uuid', md5(j::text)) as legacy_source_id,
  'legacy_news_articles_' || coalesce(j->>'id', j->>'uuid', md5(j::text)) as content_key,
  'news' as content_type,
  coalesce(nullif(j->>'title_ar',''), nullif(j->>'title',''), nullif(j->>'headline_ar',''), nullif(j->>'name_ar',''), 'بدون عنوان') as title_ar,
  nullif(coalesce(j->>'title_en', j->>'headline_en', j->>'name_en'), '') as title_en,
  nullif(coalesce(j->>'summary_ar', j->>'excerpt_ar', j->>'description_ar', j->>'summary', j->>'excerpt'), '') as summary_ar,
  nullif(coalesce(j->>'summary_en', j->>'excerpt_en', j->>'description_en'), '') as summary_en,
  nullif(coalesce(j->>'body_ar', j->>'content_ar', j->>'body', j->>'content', j->>'description'), '') as body_ar,
  nullif(coalesce(j->>'body_en', j->>'content_en'), '') as body_en,
  nullif(coalesce(j->>'category_key', j->>'category', j->>'type'), '') as category_key,
  case
    when lower(coalesce(j->>'status', j->>'publish_status', '')) in ('published','active','approved')
      or lower(coalesce(j->>'is_published', j->>'published', j->>'is_active', j->>'active', '')) in ('true','t','1','yes')
    then 'published'
    else 'draft'
  end as status,
  'public' as visibility_scope,
  'public.news_articles' as source_public_table,
  case
    when nullif(coalesce(j->>'published_at', j->>'publish_date', j->>'created_at'), '') ~ '^\d{4}-\d{2}-\d{2}'
    then nullif(coalesce(j->>'published_at', j->>'publish_date', j->>'created_at'), '')::timestamptz
    else null
  end as published_at,
  jsonb_build_object(
    'legacy_payload', j,
    'controlled_seed_batch', 'database_wave_b1a_controlled_media_import_seed_apply',
    'seed_scope', 'news_articles'
  ) as metadata
from (select to_jsonb(s) as j from public.news_articles s) q
where to_regclass('public.news_articles') is not null
  and not exists (
    select 1 from media_center.content_items ci
    where ci.legacy_source='public.news_articles'
      and ci.legacy_source_id=coalesce(j->>'id', j->>'uuid', md5(j::text))
  );

-- 3) Seed reviewed public.activities as activity.
insert into media_center.content_items (
  legacy_source, legacy_source_id, content_key, content_type,
  title_ar, title_en, summary_ar, summary_en, body_ar, body_en,
  category_key, status, visibility_scope, source_public_table, published_at, metadata
)
select
  'public.activities',
  coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'legacy_activities_' || coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'activity',
  coalesce(nullif(j->>'title_ar',''), nullif(j->>'title',''), nullif(j->>'name_ar',''), 'بدون عنوان'),
  nullif(coalesce(j->>'title_en', j->>'name_en'), ''),
  nullif(coalesce(j->>'summary_ar', j->>'description_ar', j->>'summary', j->>'description'), ''),
  nullif(coalesce(j->>'summary_en', j->>'description_en'), ''),
  nullif(coalesce(j->>'body_ar', j->>'content_ar', j->>'body', j->>'content', j->>'description'), ''),
  nullif(coalesce(j->>'body_en', j->>'content_en'), ''),
  coalesce(nullif(j->>'category_key',''), nullif(j->>'category',''), 'activity'),
  case
    when lower(coalesce(j->>'status', j->>'publish_status', '')) in ('published','active','approved')
      or lower(coalesce(j->>'is_published', j->>'published', j->>'is_active', j->>'active', '')) in ('true','t','1','yes')
    then 'published'
    else 'draft'
  end,
  'public',
  'public.activities',
  case
    when nullif(coalesce(j->>'published_at', j->>'event_date', j->>'created_at'), '') ~ '^\d{4}-\d{2}-\d{2}'
    then nullif(coalesce(j->>'published_at', j->>'event_date', j->>'created_at'), '')::timestamptz
    else null
  end,
  jsonb_build_object(
    'legacy_payload', j,
    'controlled_seed_batch', 'database_wave_b1a_controlled_media_import_seed_apply',
    'seed_scope', 'activities'
  )
from (select to_jsonb(s) as j from public.activities s) q
where to_regclass('public.activities') is not null
  and not exists (
    select 1 from media_center.content_items ci
    where ci.legacy_source='public.activities'
      and ci.legacy_source_id=coalesce(j->>'id', j->>'uuid', md5(j::text))
  );

-- 4) Seed reviewed public.announcements as announcement.
insert into media_center.content_items (
  legacy_source, legacy_source_id, content_key, content_type,
  title_ar, title_en, summary_ar, summary_en, body_ar, body_en,
  category_key, status, visibility_scope, source_public_table, published_at, metadata
)
select
  'public.announcements',
  coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'legacy_announcements_' || coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'announcement',
  coalesce(nullif(j->>'title_ar',''), nullif(j->>'title',''), nullif(j->>'name_ar',''), 'بدون عنوان'),
  nullif(coalesce(j->>'title_en', j->>'name_en'), ''),
  nullif(coalesce(j->>'summary_ar', j->>'description_ar', j->>'summary', j->>'description'), ''),
  nullif(coalesce(j->>'summary_en', j->>'description_en'), ''),
  nullif(coalesce(j->>'body_ar', j->>'content_ar', j->>'body', j->>'content', j->>'description'), ''),
  nullif(coalesce(j->>'body_en', j->>'content_en'), ''),
  coalesce(nullif(j->>'category_key',''), nullif(j->>'category',''), 'announcement'),
  case
    when lower(coalesce(j->>'status', j->>'publish_status', '')) in ('published','active','approved')
      or lower(coalesce(j->>'is_published', j->>'published', j->>'is_active', j->>'active', '')) in ('true','t','1','yes')
    then 'published'
    else 'draft'
  end,
  'public',
  'public.announcements',
  case
    when nullif(coalesce(j->>'published_at', j->>'publish_date', j->>'created_at'), '') ~ '^\d{4}-\d{2}-\d{2}'
    then nullif(coalesce(j->>'published_at', j->>'publish_date', j->>'created_at'), '')::timestamptz
    else null
  end,
  jsonb_build_object(
    'legacy_payload', j,
    'controlled_seed_batch', 'database_wave_b1a_controlled_media_import_seed_apply',
    'seed_scope', 'announcements'
  )
from (select to_jsonb(s) as j from public.announcements s) q
where to_regclass('public.announcements') is not null
  and not exists (
    select 1 from media_center.content_items ci
    where ci.legacy_source='public.announcements'
      and ci.legacy_source_id=coalesce(j->>'id', j->>'uuid', md5(j::text))
  );

-- 5) Seed public.breaking_news as draft only because visibility semantics are high risk.
insert into media_center.content_items (
  legacy_source, legacy_source_id, content_key, content_type,
  title_ar, summary_ar, body_ar, category_key, status, visibility_scope, source_public_table, published_at, metadata
)
select
  'public.breaking_news',
  coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'legacy_breaking_news_' || coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'breaking_news',
  coalesce(nullif(j->>'title_ar',''), nullif(j->>'title',''), nullif(j->>'headline_ar',''), 'خبر عاجل'),
  nullif(coalesce(j->>'summary_ar', j->>'summary', j->>'description_ar', j->>'description'), ''),
  nullif(coalesce(j->>'body_ar', j->>'content_ar', j->>'body', j->>'content', j->>'description'), ''),
  'breaking_news',
  'draft',
  'public',
  'public.breaking_news',
  null,
  jsonb_build_object(
    'legacy_payload', j,
    'controlled_seed_batch', 'database_wave_b1a_controlled_media_import_seed_apply',
    'visibility_note', 'draft_only_manual_semantics_review'
  )
from (select to_jsonb(s) as j from public.breaking_news s) q
where to_regclass('public.breaking_news') is not null
  and not exists (
    select 1 from media_center.content_items ci
    where ci.legacy_source='public.breaking_news'
      and ci.legacy_source_id=coalesce(j->>'id', j->>'uuid', md5(j::text))
  );

-- 6) Trace imported rows with editorial events, idempotently.
insert into media_center.editorial_events (content_item_id, from_state, to_state, action_key, actor_scope, note_ar, metadata)
select
  ci.id,
  null,
  ci.status,
  'controlled_legacy_seed',
  'system_seed',
  'استيراد/تهيئة محكومة من جداول الإعلام العامة القديمة بدون حذف المصدر.',
  jsonb_build_object(
    'legacy_source', ci.legacy_source,
    'legacy_source_id', ci.legacy_source_id,
    'controlled_seed_batch', 'database_wave_b1a_controlled_media_import_seed_apply'
  )
from media_center.content_items ci
where ci.legacy_source in ('public.news_articles','public.activities','public.announcements','public.breaking_news')
  and not exists (
    select 1 from media_center.editorial_events ee
    where ee.content_item_id = ci.id
      and ee.action_key = 'controlled_legacy_seed'
  );

commit;
