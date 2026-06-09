-- Media/Services operational counts — read only
select 'media_services_operational_counts' as section, 'media_news_compat_rows' as check_key, count(*)::bigint as row_count from public.v_media_news_compat_v1
union all
select 'media_services_operational_counts', 'media_announcements_compat_rows', count(*)::bigint from public.v_media_announcements_compat_v1
union all
select 'media_services_operational_counts', 'services_catalog_compat_rows', count(*)::bigint from public.v_services_catalog_compat_v1
union all
select 'media_services_operational_counts', 'homepage_sections_rows', count(*)::bigint from public.homepage_sections;
