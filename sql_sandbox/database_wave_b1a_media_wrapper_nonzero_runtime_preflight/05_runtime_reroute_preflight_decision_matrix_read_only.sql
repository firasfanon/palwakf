-- Database Wave B-1A — Media Wrapper Nonzero + Runtime Reroute Preflight
-- 05: Runtime reroute preflight decision matrix (READ ONLY)
-- IMPORTANT: A ready decision here is SQL preflight readiness only. It does not apply Flutter reroute.

with counts as (
  select
    (select count(*) from public.v_media_content_compat_v1)::bigint as content_rows,
    (select count(*) from public.v_media_news_compat_v1)::bigint as news_rows,
    (select count(*) from public.v_media_announcements_compat_v1)::bigint as announcement_rows,
    (select count(*) from public.v_media_activities_compat_v1)::bigint as activity_rows,
    (select count(*) from public.v_media_gallery_compat_v1)::bigint as gallery_rows,
    (select count(*) from public.rpc_media_content_compat_v1(null,null,null,20,0))::bigint as rpc_rows,
    (
      select count(*)::bigint
      from public.v_media_content_compat_v1 v
      join media_center.content_items ci on ci.id = v.id
      where ci.status <> 'published'
         or ci.visibility_scope <> 'public'
         or (ci.published_at is not null and ci.published_at > now())
    ) as leak_rows,
    (
      select count(*)::bigint
      from public.v_media_content_compat_v1 v
      where not exists (select 1 from media_center.content_items ci where ci.id = v.id)
    ) as orphan_rows
), gates as (
  select * from (values
    ('content_wrapper_nonzero', (select content_rows > 0 from counts), 'public.v_media_content_compat_v1 must expose at least one public row.'),
    ('rpc_returns_rows', (select rpc_rows > 0 from counts), 'public.rpc_media_content_compat_v1 must return public rows.'),
    ('published_only_no_leaks', (select leak_rows = 0 from counts), 'No draft/internal/future rows may leak through public wrappers.'),
    ('no_orphan_wrapper_rows', (select orphan_rows = 0 from counts), 'Wrapper rows must map back to media_center.content_items.'),
    ('news_or_breaking_available', (select news_rows > 0 from counts), 'News wrapper should be nonzero before rerouting public news pages.'),
    ('announcements_available', (select announcement_rows > 0 from counts), 'Announcements wrapper should be nonzero before rerouting public announcements pages.'),
    ('activities_available', (select activity_rows > 0 from counts), 'Activities wrapper should be nonzero before rerouting public activities pages.'),
    ('gallery_mapping_known', (select gallery_rows > 0 from counts), 'Gallery remains separately blocked if zero because public.media_gallery_items was intentionally excluded.')
  ) as t(check_key, passed, note)
)
select
  'media_runtime_preflight_gate_matrix' as section,
  check_key,
  passed,
  case
    when passed then 'passed'
    when check_key='gallery_mapping_known' then 'known_blocker_not_blocking_news_announcements_activities'
    else 'preflight_blocker'
  end as decision,
  note
from gates
order by check_key;

with counts as (
  select
    (select count(*) from public.v_media_content_compat_v1)::bigint as content_rows,
    (select count(*) from public.v_media_news_compat_v1)::bigint as news_rows,
    (select count(*) from public.v_media_announcements_compat_v1)::bigint as announcement_rows,
    (select count(*) from public.v_media_activities_compat_v1)::bigint as activity_rows,
    (select count(*) from public.v_media_gallery_compat_v1)::bigint as gallery_rows,
    (select count(*) from public.rpc_media_content_compat_v1(null,null,null,20,0))::bigint as rpc_rows,
    (
      select count(*)::bigint
      from public.v_media_content_compat_v1 v
      join media_center.content_items ci on ci.id = v.id
      where ci.status <> 'published'
         or ci.visibility_scope <> 'public'
         or (ci.published_at is not null and ci.published_at > now())
    ) as leak_rows,
    (
      select count(*)::bigint
      from public.v_media_content_compat_v1 v
      where not exists (select 1 from media_center.content_items ci where ci.id = v.id)
    ) as orphan_rows
)
select
  'media_runtime_gate_decision' as section,
  case
    when content_rows > 0
     and rpc_rows > 0
     and leak_rows = 0
     and orphan_rows = 0
     and (news_rows > 0 or announcement_rows > 0 or activity_rows > 0)
    then 'media-runtime-reroute-ready'
    else 'media-runtime-reroute-still-blocked'
  end as decision,
  jsonb_build_object(
    'content_rows', content_rows,
    'news_rows', news_rows,
    'announcement_rows', announcement_rows,
    'activity_rows', activity_rows,
    'gallery_rows', gallery_rows,
    'rpc_rows', rpc_rows,
    'leak_rows', leak_rows,
    'orphan_rows', orphan_rows,
    'gallery_note', case when gallery_rows = 0 then 'gallery remains blocked pending asset/content mapping' else 'gallery wrapper has rows' end,
    'decision_scope', 'SQL preflight only; Flutter reroute requires explicit next pack + Browser UAT evidence'
  ) as decision_payload,
  'No Flutter runtime reroute is performed by this SQL pack.' as note
from counts;
