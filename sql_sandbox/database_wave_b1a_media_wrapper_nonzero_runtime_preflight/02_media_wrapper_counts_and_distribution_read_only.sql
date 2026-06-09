-- Database Wave B-1A — Media Wrapper Nonzero + Runtime Reroute Preflight
-- 02: Wrapper row counts and content-type distribution (READ ONLY)
-- This script assumes the B-1A public media wrappers were already activated.

select *
from (
  select 'media_wrapper_row_counts' as section, 'media_center.v_content_items_public_v1' as contract_name, count(*)::bigint as row_count,
         case when count(*) > 0 then 'nonzero' else 'zero_preflight_blocker' end as decision
  from media_center.v_content_items_public_v1
  union all
  select 'media_wrapper_row_counts', 'public.v_media_content_compat_v1', count(*)::bigint,
         case when count(*) > 0 then 'nonzero' else 'zero_preflight_blocker' end
  from public.v_media_content_compat_v1
  union all
  select 'media_wrapper_row_counts', 'public.v_media_news_compat_v1', count(*)::bigint,
         case when count(*) > 0 then 'nonzero_news_candidate' else 'zero_news_runtime_blocker' end
  from public.v_media_news_compat_v1
  union all
  select 'media_wrapper_row_counts', 'public.v_media_announcements_compat_v1', count(*)::bigint,
         case when count(*) > 0 then 'nonzero_announcements_candidate' else 'zero_announcements_runtime_blocker' end
  from public.v_media_announcements_compat_v1
  union all
  select 'media_wrapper_row_counts', 'public.v_media_activities_compat_v1', count(*)::bigint,
         case when count(*) > 0 then 'nonzero_activities_candidate' else 'zero_activities_runtime_blocker' end
  from public.v_media_activities_compat_v1
  union all
  select 'media_wrapper_row_counts', 'public.v_media_gallery_compat_v1', count(*)::bigint,
         case when count(*) > 0 then 'nonzero_gallery_candidate' else 'gallery_expected_blocked_pending_asset_mapping' end
  from public.v_media_gallery_compat_v1
) s
order by contract_name;

select
  'media_wrapper_content_type_distribution' as section,
  content_type,
  count(*)::bigint as row_count,
  min(published_at) as min_published_at,
  max(published_at) as max_published_at
from public.v_media_content_compat_v1
group by content_type
order by row_count desc, content_type;

select
  'media_wrapper_legacy_source_distribution' as section,
  coalesce(metadata->>'controlled_seed_batch','unknown') as seed_batch,
  coalesce(metadata->>'seed_scope','unknown') as seed_scope,
  count(*)::bigint as row_count
from public.v_media_content_compat_v1
group by coalesce(metadata->>'controlled_seed_batch','unknown'), coalesce(metadata->>'seed_scope','unknown')
order by row_count desc, seed_scope;
