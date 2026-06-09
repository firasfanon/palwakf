-- Database Wave B-1A Media Compatibility Closure Planning Pack
-- 01_media_public_wrapper_state_read_only.sql
-- READ ONLY: verifies public media wrapper contracts and row exposure.

select 'media_wrapper_state' as section,
       'public.v_media_content_compat_v1' as contract_name,
       to_regclass('public.v_media_content_compat_v1') is not null as object_exists,
       (select count(*) from public.v_media_content_compat_v1) as row_count,
       'direct_flutter_reroute_blocked_if_zero_rows' as decision
union all
select 'media_wrapper_state', 'public.v_media_news_compat_v1', to_regclass('public.v_media_news_compat_v1') is not null,
       (select count(*) from public.v_media_news_compat_v1), 'direct_flutter_reroute_blocked_if_zero_rows'
union all
select 'media_wrapper_state', 'public.v_media_announcements_compat_v1', to_regclass('public.v_media_announcements_compat_v1') is not null,
       (select count(*) from public.v_media_announcements_compat_v1), 'direct_flutter_reroute_blocked_if_zero_rows'
union all
select 'media_wrapper_state', 'public.v_media_activities_compat_v1', to_regclass('public.v_media_activities_compat_v1') is not null,
       (select count(*) from public.v_media_activities_compat_v1), 'direct_flutter_reroute_blocked_if_zero_rows'
union all
select 'media_wrapper_state', 'public.v_media_gallery_compat_v1', to_regclass('public.v_media_gallery_compat_v1') is not null,
       (select count(*) from public.v_media_gallery_compat_v1), 'direct_flutter_reroute_blocked_if_zero_rows';
