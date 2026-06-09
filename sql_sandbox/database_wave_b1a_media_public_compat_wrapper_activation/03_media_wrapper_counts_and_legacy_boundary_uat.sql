-- Database Wave B-1A — Media Public Wrapper Counts + Legacy Boundary UAT
-- Read-only checks: public legacy tables remain preserved; wrappers point to media_center public view.

select
  'media_public_wrapper_counts' as section,
  object_name,
  observed_value,
  note
from (
  select 'public.v_media_content_compat_v1'::text as object_name, (select count(*) from public.v_media_content_compat_v1)::text as observed_value, 'rows visible through activated public media compatibility wrapper'::text as note
  union all select 'public.v_media_news_compat_v1', (select count(*) from public.v_media_news_compat_v1)::text, 'news wrapper count'
  union all select 'public.v_media_announcements_compat_v1', (select count(*) from public.v_media_announcements_compat_v1)::text, 'announcements wrapper count'
  union all select 'public.v_media_activities_compat_v1', (select count(*) from public.v_media_activities_compat_v1)::text, 'activities wrapper count'
  union all select 'public.v_media_gallery_compat_v1', (select count(*) from public.v_media_gallery_compat_v1)::text, 'gallery wrapper count'
  union all select 'media_center.content_items', (select count(*) from media_center.content_items)::text, 'media_center remains empty unless separately seeded; no legacy import in this pack'
  union all select 'media_center.content_assets', (select count(*) from media_center.content_assets)::text, 'media_center assets remain empty unless separately seeded; no legacy import in this pack'
  union all select 'public.activities', (to_regclass('public.activities') is not null)::text, 'legacy public media table preserved'
  union all select 'public.announcements', (to_regclass('public.announcements') is not null)::text, 'legacy public media table preserved'
  union all select 'public.news_articles', (to_regclass('public.news_articles') is not null)::text, 'legacy public media table preserved'
  union all select 'public.breaking_news', (to_regclass('public.breaking_news') is not null)::text, 'legacy public media table preserved if present'
  union all select 'public.media_gallery_items', (to_regclass('public.media_gallery_items') is not null)::text, 'legacy public media table preserved if present'
) s
order by object_name;

select
  'media_public_wrapper_dependency' as section,
  dependent_schema,
  dependent_object,
  source_schema,
  source_object,
  dependency_decision
from (
  select
    n1.nspname as dependent_schema,
    c1.relname as dependent_object,
    n2.nspname as source_schema,
    c2.relname as source_object,
    case
      when n2.nspname = 'media_center' then 'expected-wrapper-points-to-media-center'
      when n2.nspname = 'public' and c2.relname like 'v_media_%_compat_v1' then 'wrapper-chain-ok'
      else 'review-dependency'
    end as dependency_decision
  from pg_rewrite r
  join pg_class c1 on c1.oid = r.ev_class
  join pg_namespace n1 on n1.oid = c1.relnamespace
  join pg_depend d on d.objid = r.oid
  join pg_class c2 on c2.oid = d.refobjid
  join pg_namespace n2 on n2.oid = c2.relnamespace
  where n1.nspname = 'public'
    and c1.relname in ('v_media_content_compat_v1','v_media_news_compat_v1','v_media_announcements_compat_v1','v_media_activities_compat_v1','v_media_gallery_compat_v1')
    and n2.nspname in ('media_center','public')
) dep
order by dependent_object, source_schema, source_object;
