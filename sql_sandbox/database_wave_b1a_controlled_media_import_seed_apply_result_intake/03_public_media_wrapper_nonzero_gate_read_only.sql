-- 03: Public media compatibility wrapper row-count gate (read-only).
select 'media_public_wrapper_nonzero_gate' as section, 'public.v_media_content_compat_v1' as contract_name, count(*)::bigint as row_count from public.v_media_content_compat_v1
union all
select 'media_public_wrapper_nonzero_gate', 'public.v_media_news_compat_v1', count(*)::bigint from public.v_media_news_compat_v1
union all
select 'media_public_wrapper_nonzero_gate', 'public.v_media_activities_compat_v1', count(*)::bigint from public.v_media_activities_compat_v1
union all
select 'media_public_wrapper_nonzero_gate', 'public.v_media_announcements_compat_v1', count(*)::bigint from public.v_media_announcements_compat_v1
union all
select 'media_public_wrapper_nonzero_gate', 'public.v_media_gallery_compat_v1', count(*)::bigint from public.v_media_gallery_compat_v1;
