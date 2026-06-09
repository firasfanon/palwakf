-- Database Wave B-1A
-- Media Runtime Console Review + Production Candidate Decision Pack
-- 01_news_announcements_runtime_candidate_read_only.sql
-- Read-only. No DDL. No DML.

with counts as (
  select 'public.v_media_news_compat_v1' as object_name, count(*)::bigint as row_count from public.v_media_news_compat_v1
  union all
  select 'public.v_media_announcements_compat_v1', count(*)::bigint from public.v_media_announcements_compat_v1
  union all
  select 'public.v_media_content_compat_v1', count(*)::bigint from public.v_media_content_compat_v1
), leak_check as (
  select count(*)::bigint as leak_rows
  from media_center.content_items
  where coalesce(status, '') not in ('published', 'active')
    and id in (select id from public.v_media_content_compat_v1)
), candidate_decision as (
  select
    (select row_count from counts where object_name = 'public.v_media_news_compat_v1') as news_rows,
    (select row_count from counts where object_name = 'public.v_media_announcements_compat_v1') as announcement_rows,
    (select leak_rows from leak_check) as leak_rows
)
select
  'media_runtime_candidate_readiness' as section,
  case
    when news_rows > 0 and announcement_rows > 0 and leak_rows = 0
      then 'sql-candidate-ok-console-evidence-still-required'
    else 'sql-candidate-blocked'
  end as decision,
  jsonb_build_object(
    'news_rows', news_rows,
    'announcement_rows', announcement_rows,
    'leak_rows', leak_rows,
    'scope', 'read-only sql support only; console/browser evidence remains required'
  ) as decision_payload
from candidate_decision;
