-- Database Wave B-1A — Controlled Media Import/Seed APPLY CANDIDATE — NOT RUN BY DEFAULT
-- WARNING: This file performs INSERTs into media_center.content_items.
-- Do NOT run unless explicitly approved as a controlled seed apply.
-- It does NOT delete/move/alter legacy public media tables.
-- It does NOT activate Flutter runtime reroute.

begin;

-- 0) Guard required contracts.
do $$
begin
  if to_regclass('media_center.content_items') is null then
    raise exception 'Required target media_center.content_items does not exist.';
  end if;
end $$;

-- 1) Optional idempotency index for future seed/apply safety.
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
  coalesce(j->>'title_ar', j->>'title', j->>'headline_ar', j->>'name_ar', 'بدون عنوان') as title_ar,
  coalesce(j->>'title_en', j->>'headline_en', j->>'name_en') as title_en,
  coalesce(j->>'summary_ar', j->>'excerpt_ar', j->>'description_ar', j->>'summary', j->>'excerpt') as summary_ar,
  coalesce(j->>'summary_en', j->>'excerpt_en', j->>'description_en') as summary_en,
  coalesce(j->>'body_ar', j->>'content_ar', j->>'body', j->>'content', j->>'description') as body_ar,
  coalesce(j->>'body_en', j->>'content_en') as body_en,
  coalesce(j->>'category_key', j->>'category', j->>'type') as category_key,
  case
    when lower(coalesce(j->>'status', j->>'publish_status', '')) in ('published','active','approved')
      or lower(coalesce(j->>'is_published', j->>'published', j->>'is_active', j->>'active', '')) in ('true','t','1','yes')
    then 'published'
    else 'draft'
  end as status,
  'public' as visibility_scope,
  'public.news_articles' as source_public_table,
  nullif(coalesce(j->>'published_at', j->>'publish_date', j->>'created_at'), '')::timestamptz as published_at,
  jsonb_build_object('legacy_payload', j, 'controlled_seed_batch', 'database_wave_b1a_media_import_seed') as metadata
from (select to_jsonb(s) as j from public.news_articles s) q
where not exists (
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
  coalesce(j->>'title_ar', j->>'title', j->>'name_ar', 'بدون عنوان'),
  coalesce(j->>'title_en', j->>'name_en'),
  coalesce(j->>'summary_ar', j->>'description_ar', j->>'summary', j->>'description'),
  coalesce(j->>'summary_en', j->>'description_en'),
  coalesce(j->>'body_ar', j->>'content_ar', j->>'body', j->>'content', j->>'description'),
  coalesce(j->>'body_en', j->>'content_en'),
  coalesce(j->>'category_key', j->>'category', 'activity'),
  case
    when lower(coalesce(j->>'status', j->>'publish_status', '')) in ('published','active','approved')
      or lower(coalesce(j->>'is_published', j->>'published', j->>'is_active', j->>'active', '')) in ('true','t','1','yes')
    then 'published'
    else 'draft'
  end,
  'public',
  'public.activities',
  nullif(coalesce(j->>'published_at', j->>'event_date', j->>'created_at'), '')::timestamptz,
  jsonb_build_object('legacy_payload', j, 'controlled_seed_batch', 'database_wave_b1a_media_import_seed')
from (select to_jsonb(s) as j from public.activities s) q
where not exists (
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
  coalesce(j->>'title_ar', j->>'title', j->>'name_ar', 'بدون عنوان'),
  coalesce(j->>'title_en', j->>'name_en'),
  coalesce(j->>'summary_ar', j->>'description_ar', j->>'summary', j->>'description'),
  coalesce(j->>'summary_en', j->>'description_en'),
  coalesce(j->>'body_ar', j->>'content_ar', j->>'body', j->>'content', j->>'description'),
  coalesce(j->>'body_en', j->>'content_en'),
  coalesce(j->>'category_key', j->>'category', 'announcement'),
  case
    when lower(coalesce(j->>'status', j->>'publish_status', '')) in ('published','active','approved')
      or lower(coalesce(j->>'is_published', j->>'published', j->>'is_active', j->>'active', '')) in ('true','t','1','yes')
    then 'published'
    else 'draft'
  end,
  'public',
  'public.announcements',
  nullif(coalesce(j->>'published_at', j->>'publish_date', j->>'created_at'), '')::timestamptz,
  jsonb_build_object('legacy_payload', j, 'controlled_seed_batch', 'database_wave_b1a_media_import_seed')
from (select to_jsonb(s) as j from public.announcements s) q
where not exists (
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
  coalesce(j->>'title_ar', j->>'title', j->>'headline_ar', 'خبر عاجل'),
  coalesce(j->>'summary_ar', j->>'summary', j->>'description_ar', j->>'description'),
  coalesce(j->>'body_ar', j->>'content_ar', j->>'body', j->>'content', j->>'description'),
  'breaking_news',
  'draft',
  'public',
  'public.breaking_news',
  null,
  jsonb_build_object('legacy_payload', j, 'controlled_seed_batch', 'database_wave_b1a_media_import_seed', 'visibility_note', 'draft_only_manual_semantics_review')
from (select to_jsonb(s) as j from public.breaking_news s) q
where not exists (
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
  jsonb_build_object('legacy_source', ci.legacy_source, 'legacy_source_id', ci.legacy_source_id)
from media_center.content_items ci
where ci.legacy_source in ('public.news_articles','public.activities','public.announcements','public.breaking_news')
  and not exists (
    select 1 from media_center.editorial_events ee
    where ee.content_item_id = ci.id
      and ee.action_key = 'controlled_legacy_seed'
  );

commit;

-- Post-run UAT queries to execute manually after commit:
-- select count(*) from media_center.content_items;
-- select content_type, status, count(*) from media_center.content_items group by content_type, status order by content_type, status;
-- select count(*) from media_center.v_content_items_public_v1;
-- select count(*) from public.v_media_content_compat_v1;
