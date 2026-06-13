
-- MEDIA_CENTER_OFFICIAL_FIRST_MOBILE_OPERATIONAL_WORKFLOW_AND_ANDROID_READINESS
-- READ ONLY verification.
--
-- This file does not apply SQL and does not mutate data.

select
  'media_center_mobile_operational_readiness' as section,
  to_regclass('media_center.mobile_publish_events') is not null as mobile_publish_events_present,
  to_regprocedure('public.rpc_media_center_mobile_create_draft_v1(text,text,text,text,uuid,text,text,text,text,bigint)') is not null as create_draft_rpc_present,
  to_regprocedure('public.rpc_media_center_mobile_submit_for_review_v1(uuid)') is not null as submit_review_rpc_present,
  to_regprocedure('public.rpc_media_center_mobile_publish_v1(uuid)') is not null as publish_rpc_present,
  to_regprocedure('public.rpc_media_center_public_content_detail_v1(text,text)') is not null as public_detail_rpc_present,
  false as public_base_table_creation_authorized,
  false as production_approved;

select
  'media_center_mobile_public_counts' as section,
  'news' as family,
  count(*)::bigint as row_count
from public.v_media_news_compat_v1
union all
select
  'media_center_mobile_public_counts',
  'announcements',
  count(*)::bigint
from public.v_media_announcements_compat_v1
union all
select
  'media_center_mobile_public_counts',
  'activities',
  count(*)::bigint
from public.v_media_activities_compat_v1;
