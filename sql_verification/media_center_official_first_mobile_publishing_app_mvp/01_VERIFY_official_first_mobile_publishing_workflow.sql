
-- MEDIA_CENTER_OFFICIAL_FIRST_MOBILE_PUBLISHING_APP_MVP
-- READ ONLY verification.

select
  'media_center_official_first_mobile_rpc_presence' as section,
  to_regclass('media_center.mobile_publish_events') as mobile_publish_events,
  to_regprocedure('public.rpc_media_center_mobile_actor_can_publish_v1()') as actor_can_publish_rpc,
  to_regprocedure('public.rpc_media_center_mobile_create_draft_v1(text,text,text,text,uuid,text,text,text,text,bigint)') as create_draft_rpc,
  to_regprocedure('public.rpc_media_center_mobile_submit_for_review_v1(uuid)') as submit_review_rpc,
  to_regprocedure('public.rpc_media_center_mobile_publish_v1(uuid)') as publish_rpc,
  to_regprocedure('public.rpc_media_center_public_content_detail_v1(text,text)') as public_detail_rpc;

select
  'media_center_official_first_mobile_grants' as section,
  has_function_privilege('authenticated', 'public.rpc_media_center_mobile_create_draft_v1(text,text,text,text,uuid,text,text,text,text,bigint)', 'execute') as authenticated_can_create_draft,
  has_function_privilege('authenticated', 'public.rpc_media_center_mobile_submit_for_review_v1(uuid)', 'execute') as authenticated_can_submit_review,
  has_function_privilege('authenticated', 'public.rpc_media_center_mobile_publish_v1(uuid)', 'execute') as authenticated_can_publish_rpc,
  has_function_privilege('anon', 'public.rpc_media_center_public_content_detail_v1(text,text)', 'execute') as anon_can_read_public_detail;

select
  'media_center_official_first_mobile_owner_counts' as section,
  content_type,
  status,
  count(*)::bigint as row_count
from media_center.content_items
where metadata->>'source_channel' = 'mobile_app'
group by content_type, status
order by content_type, status;

select
  'media_center_official_first_public_api_edge_counts' as section,
  'news' as family,
  count(*)::bigint as row_count
from public.v_media_news_compat_v1
union all
select
  'media_center_official_first_public_api_edge_counts',
  'announcements',
  count(*)::bigint
from public.v_media_announcements_compat_v1
union all
select
  'media_center_official_first_public_api_edge_counts',
  'activities',
  count(*)::bigint
from public.v_media_activities_compat_v1;
