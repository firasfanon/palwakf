-- 07_post_execution_uat_read_only.sql
-- READ ONLY. Run after apply scripts 02-06.

select 'post_execution_media_counts' as section, check_key, row_count, decision
from (
  select 'news_wrapper_rows' check_key, (select count(*) from public.v_media_news_compat_v1)::bigint row_count, 'must_remain_nonzero' decision
  union all select 'announcements_wrapper_rows', (select count(*) from public.v_media_announcements_compat_v1)::bigint, 'must_remain_nonzero'
  union all select 'activities_wrapper_rows', (select count(*) from public.v_media_activities_compat_v1)::bigint, 'must_be_nonzero_after_controlled_execution_if_public.activities_has_rows'
  union all select 'gallery_wrapper_rows', (select count(*) from public.v_media_gallery_compat_v1)::bigint, 'may_be_zero_if_public.media_gallery_items_is_zero'
  union all select 'locations_wrapper_rows', (select count(*) from public.v_locations_compat_v1)::bigint, 'must_match_gis_locations_visibility_contract'
  union all select 'services_wrapper_rows', (select count(*) from public.v_services_catalog_compat_v1)::bigint, 'must_remain_nonzero'
) s;

select
  'post_execution_leak_check' as section,
  'drafts_exposed_in_public_media_content' as check_key,
  count(*)::bigint as leak_rows,
  case when count(*)=0 then 'passed' else 'failed_review_required' end as decision
from public.v_media_content_compat_v1 v
join media_center.content_items ci on ci.id = v.id
where ci.status <> 'published'
   or ci.visibility_scope <> 'public';

select
  'post_execution_execution_gate' as section,
  case
    when (select count(*) from public.v_media_news_compat_v1) > 0
     and (select count(*) from public.v_media_announcements_compat_v1) > 0
     and (select count(*) from public.v_media_activities_compat_v1) > 0
     and to_regclass('public.v_locations_compat_v1') is not null
     and to_regprocedure('public.rpc_locations_compat_v1(text,text,integer,integer)') is not null
    then 'CONTROLLED_EXECUTION_SQL_PASSED_BROWSER_UAT_REQUIRED'
    else 'CONTROLLED_EXECUTION_SQL_INCOMPLETE_REVIEW_REQUIRED'
  end as decision;
