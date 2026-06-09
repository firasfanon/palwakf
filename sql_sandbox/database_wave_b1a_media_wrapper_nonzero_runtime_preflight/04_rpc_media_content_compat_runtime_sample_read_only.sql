-- Database Wave B-1A — Media Wrapper Nonzero + Runtime Reroute Preflight
-- 04: RPC compatibility runtime sample (READ ONLY)
-- Tests the read-only public RPC using all-content and specific content_type filters.

select *
from (
  select 'media_rpc_sample' as section, 'all' as sample_filter, count(*)::bigint as row_count,
         case when count(*) > 0 then 'rpc_returns_rows' else 'rpc_zero_preflight_blocker' end as decision
  from public.rpc_media_content_compat_v1(null,null,null,20,0)
  union all
  select 'media_rpc_sample', 'news', count(*)::bigint,
         case when count(*) > 0 then 'rpc_news_returns_rows' else 'rpc_news_zero_or_no_published_news' end
  from public.rpc_media_content_compat_v1('news',null,null,20,0)
  union all
  select 'media_rpc_sample', 'breaking_news', count(*)::bigint,
         case when count(*) > 0 then 'rpc_breaking_news_returns_rows' else 'rpc_breaking_news_zero_or_draft_only' end
  from public.rpc_media_content_compat_v1('breaking_news',null,null,20,0)
  union all
  select 'media_rpc_sample', 'announcement', count(*)::bigint,
         case when count(*) > 0 then 'rpc_announcements_returns_rows' else 'rpc_announcements_zero_or_no_published_announcements' end
  from public.rpc_media_content_compat_v1('announcement',null,null,20,0)
  union all
  select 'media_rpc_sample', 'activity', count(*)::bigint,
         case when count(*) > 0 then 'rpc_activities_returns_rows' else 'rpc_activities_zero_or_no_published_activities' end
  from public.rpc_media_content_compat_v1('activity',null,null,20,0)
  union all
  select 'media_rpc_sample', 'gallery', count(*)::bigint,
         case when count(*) > 0 then 'rpc_gallery_returns_rows' else 'rpc_gallery_expected_blocked_pending_asset_mapping' end
  from public.rpc_media_content_compat_v1('gallery',null,null,20,0)
) s
order by sample_filter;

select
  'media_rpc_sample_payload' as section,
  id,
  content_type,
  title_ar,
  category_key,
  unit_slug,
  published_at,
  source_schema_name,
  compatibility_contract
from public.rpc_media_content_compat_v1(null,null,null,5,0);
