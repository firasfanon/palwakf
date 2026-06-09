-- Database Wave B-1A — Media Wrapper Nonzero + Runtime Reroute Preflight
-- 01: Controlled seed row counts by source/type (read-only).
select 'media_seed_counts_by_source' as section,
       legacy_source,
       content_type,
       status,
       count(*)::bigint as row_count
from media_center.content_items
where legacy_source in ('public.news_articles','public.activities','public.announcements','public.breaking_news')
group by legacy_source, content_type, status
order by legacy_source, content_type, status;
