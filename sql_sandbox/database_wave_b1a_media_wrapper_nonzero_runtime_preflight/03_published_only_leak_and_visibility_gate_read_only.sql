-- Database Wave B-1A — Media Wrapper Nonzero + Runtime Reroute Preflight
-- 03: Published-only leak and visibility gate (READ ONLY)
-- Confirms public wrappers are not exposing draft/internal/future rows.

with base as (
  select
    (select count(*) from media_center.content_items)::bigint as total_media_center_rows,
    (select count(*) from media_center.content_items where status = 'published' and visibility_scope = 'public' and (published_at is null or published_at <= now()))::bigint as eligible_public_rows,
    (select count(*) from media_center.content_items where status <> 'published')::bigint as non_published_base_rows,
    (select count(*) from media_center.v_content_items_public_v1)::bigint as media_center_public_view_rows,
    (select count(*) from public.v_media_content_compat_v1)::bigint as public_wrapper_rows,
    (
      select count(*)::bigint
      from public.v_media_content_compat_v1 v
      join media_center.content_items ci on ci.id = v.id
      where ci.status <> 'published'
         or ci.visibility_scope <> 'public'
         or (ci.published_at is not null and ci.published_at > now())
    ) as leaked_non_public_rows,
    (
      select count(*)::bigint
      from public.v_media_content_compat_v1 v
      where not exists (
        select 1 from media_center.content_items ci where ci.id = v.id
      )
    ) as orphan_wrapper_rows
)
select
  'published_only_public_visibility_gate' as section,
  total_media_center_rows,
  eligible_public_rows,
  non_published_base_rows,
  media_center_public_view_rows,
  public_wrapper_rows,
  leaked_non_public_rows,
  orphan_wrapper_rows,
  case
    when leaked_non_public_rows = 0
     and orphan_wrapper_rows = 0
     and media_center_public_view_rows = public_wrapper_rows
     and public_wrapper_rows = eligible_public_rows
    then 'published_only_contract_ok'
    else 'published_only_contract_failed_preflight_blocker'
  end as decision,
  'non_published_base_rows may be > 0; they must not leak into public wrappers.' as note
from base;

select
  'blocked_status_visibility_distribution' as section,
  status,
  visibility_scope,
  count(*)::bigint as base_rows_not_exposed_by_public_contract
from media_center.content_items
where not (status = 'published' and visibility_scope = 'public' and (published_at is null or published_at <= now()))
group by status, visibility_scope
order by count(*) desc, status, visibility_scope;
