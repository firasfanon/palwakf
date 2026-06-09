with counts as (
  select 'public.news_articles' as source_name, count(*)::bigint as row_count from public.news_articles
  union all select 'public.announcements', count(*) from public.announcements
  union all select 'public.activities', count(*) from public.activities
  union all select 'public.media_gallery_items', count(*) from public.media_gallery_items
  union all select 'media_center.content_items', count(*) from media_center.content_items
  union all select 'media_center.content_assets', count(*) from media_center.content_assets
  union all select 'public.v_media_news_compat_v1', count(*) from public.v_media_news_compat_v1
  union all select 'public.v_media_announcements_compat_v1', count(*) from public.v_media_announcements_compat_v1
  union all select 'public.v_media_activities_compat_v1', count(*) from public.v_media_activities_compat_v1
  union all select 'public.v_media_gallery_compat_v1', count(*) from public.v_media_gallery_compat_v1
), legacy_dupes as (
  select legacy_source, legacy_source_id::text, count(*) as duplicate_count
  from media_center.content_items
  where legacy_source is not null and legacy_source_id is not null
  group by legacy_source, legacy_source_id
  having count(*) > 1
), critical_nulls as (
  select 'media_center.content_items.title_ar_null' as check_key, count(*)::bigint as issue_count
  from media_center.content_items where nullif(trim(coalesce(title_ar,'')), '') is null
  union all
  select 'media_center.content_items.content_type_null', count(*) from media_center.content_items where nullif(trim(coalesce(content_type,'')), '') is null
  union all
  select 'media_center.content_items.status_null', count(*) from media_center.content_items where nullif(trim(coalesce(status,'')), '') is null
)
select 'counts' as section, source_name as check_key, row_count as value, null::text as note from counts
union all
select 'duplicate_legacy_links', legacy_source || ':' || legacy_source_id, duplicate_count::bigint, 'duplicate media_center legacy mapping' from legacy_dupes
union all
select 'critical_nulls', check_key, issue_count, 'must be 0 before execution' from critical_nulls
order by section, check_key;
