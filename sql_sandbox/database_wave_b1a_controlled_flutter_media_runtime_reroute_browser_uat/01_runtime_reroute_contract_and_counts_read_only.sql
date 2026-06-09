-- Database Wave B-1A — Controlled Flutter Media Runtime Reroute Browser UAT
-- 01: runtime contract and counts read-only.
-- No DDL, no DML, no waqf mutation.

with counts as (
  select 'public.v_media_news_compat_v1' as contract_name, count(*)::bigint as row_count
  from public.v_media_news_compat_v1
  union all
  select 'public.v_media_announcements_compat_v1', count(*)::bigint
  from public.v_media_announcements_compat_v1
  union all
  select 'public.v_media_activities_compat_v1', count(*)::bigint
  from public.v_media_activities_compat_v1
  union all
  select 'public.v_media_gallery_compat_v1', count(*)::bigint
  from public.v_media_gallery_compat_v1
), rpc_sample as (
  select count(*)::bigint as rpc_rows
  from public.rpc_media_content_compat_v1(null, null, null, 20, 0)
), decision as (
  select
    (select row_count from counts where contract_name='public.v_media_news_compat_v1') as news_rows,
    (select row_count from counts where contract_name='public.v_media_announcements_compat_v1') as announcement_rows,
    (select row_count from counts where contract_name='public.v_media_activities_compat_v1') as activity_rows,
    (select row_count from counts where contract_name='public.v_media_gallery_compat_v1') as gallery_rows,
    (select rpc_rows from rpc_sample) as rpc_rows
)
select
  'flutter_media_runtime_reroute_contract_counts' as section,
  c.contract_name,
  c.row_count,
  case
    when c.contract_name in ('public.v_media_news_compat_v1','public.v_media_announcements_compat_v1') and c.row_count > 0
      then 'runtime_candidate_nonzero'
    when c.contract_name = 'public.v_media_activities_compat_v1'
      then 'not_rerouted_in_this_pack'
    when c.contract_name = 'public.v_media_gallery_compat_v1'
      then 'blocked_pending_asset_content_mapping'
    else 'blocked_or_zero'
  end as decision
from counts c
union all
select
  'flutter_media_runtime_reroute_decision',
  'news_and_announcements_only',
  (news_rows + announcement_rows),
  case
    when news_rows > 0 and announcement_rows > 0 and rpc_rows > 0
      then 'controlled_flutter_reroute_browser_uat_candidate'
    else 'controlled_flutter_reroute_blocked'
  end
from decision
order by section, contract_name;
