
-- MEDIA_CENTER_OFFICIAL_FIRST_MOBILE_PUBLISHING_APP_MVP
-- READ ONLY preflight.
--
-- Confirms media_center owner surfaces and API-edge policy.
-- No writes.

select
  'media_center_official_first_mobile_preflight' as section,
  to_regclass('media_center.content_items') is not null as content_items_present,
  to_regclass('media_center.content_assets') is not null as content_assets_present,
  to_regclass('media_center.editorial_events') is not null as editorial_events_present,
  to_regclass('public.v_media_news_compat_v1') is not null as news_api_edge_present,
  to_regclass('public.v_media_announcements_compat_v1') is not null as announcements_api_edge_present,
  to_regclass('public.v_media_activities_compat_v1') is not null as activities_api_edge_present,
  false as public_base_table_creation_authorized,
  false as production_approved;

select
  'media_center_content_items_columns' as section,
  column_name,
  data_type,
  is_nullable
from information_schema.columns
where table_schema = 'media_center'
  and table_name = 'content_items'
order by ordinal_position;

select
  'media_center_mobile_current_public_counts' as section,
  'news' as family,
  count(*)::bigint as row_count
from public.v_media_news_compat_v1
union all
select
  'media_center_mobile_current_public_counts',
  'announcements',
  count(*)::bigint
from public.v_media_announcements_compat_v1
union all
select
  'media_center_mobile_current_public_counts',
  'activities',
  count(*)::bigint
from public.v_media_activities_compat_v1;
