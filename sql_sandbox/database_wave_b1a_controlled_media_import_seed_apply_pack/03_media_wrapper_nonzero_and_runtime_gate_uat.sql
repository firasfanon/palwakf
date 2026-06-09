-- Database Wave B-1A — Media Wrapper Nonzero + Runtime Reroute Gate UAT
-- Read-only. This does NOT authorize Flutter reroute by itself; it only reports readiness.

select * from (
  select 'media_wrapper_nonzero_uat' as section, 'public.v_media_content_compat_v1' as contract_name, count(*)::bigint as row_count,
    case when count(*) > 0 then 'nonzero_candidate_for_browser_uat' else 'zero_rows_flutter_reroute_blocked' end as reroute_gate
  from public.v_media_content_compat_v1
  union all
  select 'media_wrapper_nonzero_uat', 'public.v_media_news_compat_v1', count(*)::bigint,
    case when count(*) > 0 then 'nonzero_candidate_for_browser_uat' else 'zero_rows_flutter_reroute_blocked' end
  from public.v_media_news_compat_v1
  union all
  select 'media_wrapper_nonzero_uat', 'public.v_media_activities_compat_v1', count(*)::bigint,
    case when count(*) > 0 then 'nonzero_candidate_for_browser_uat' else 'zero_rows_flutter_reroute_blocked' end
  from public.v_media_activities_compat_v1
  union all
  select 'media_wrapper_nonzero_uat', 'public.v_media_announcements_compat_v1', count(*)::bigint,
    case when count(*) > 0 then 'nonzero_candidate_for_browser_uat' else 'zero_rows_flutter_reroute_blocked' end
  from public.v_media_announcements_compat_v1
  union all
  select 'media_wrapper_nonzero_uat', 'public.v_media_gallery_compat_v1', count(*)::bigint,
    case when count(*) > 0 then 'asset_mapping_still_required_for_gallery_runtime' else 'gallery_zero_or_no_asset_mapping' end
  from public.v_media_gallery_compat_v1
) q
order by contract_name;

select
  'media_runtime_gate_decision' as section,
  case
    when (select count(*) from public.v_media_content_compat_v1) > 0
      and (select count(*) from public.v_media_news_compat_v1) > 0
    then 'data_present_but_flutter_reroute_requires_browser_uat_pack'
    else 'flutter_reroute_still_blocked_due_zero_or_incomplete_wrapper_rows'
  end as decision,
  'No Flutter runtime reroute is performed by this SQL pack.' as note;
