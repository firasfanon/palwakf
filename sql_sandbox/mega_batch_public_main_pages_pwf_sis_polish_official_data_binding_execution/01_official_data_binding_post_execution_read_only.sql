select 'official_data_binding_post_execution' as section,
       contract_name,
       present,
       row_count
from (
  select 'public.homepage_sections' contract_name, to_regclass('public.homepage_sections') is not null present, (select count(*) from public.homepage_sections)::bigint row_count
  union all select 'public.v_media_news_compat_v1', to_regclass('public.v_media_news_compat_v1') is not null, (select count(*) from public.v_media_news_compat_v1)::bigint
  union all select 'public.v_media_announcements_compat_v1', to_regclass('public.v_media_announcements_compat_v1') is not null, (select count(*) from public.v_media_announcements_compat_v1)::bigint
  union all select 'public.v_media_activities_compat_v1', to_regclass('public.v_media_activities_compat_v1') is not null, (select count(*) from public.v_media_activities_compat_v1)::bigint
  union all select 'public.v_media_gallery_compat_v1', to_regclass('public.v_media_gallery_compat_v1') is not null, (select count(*) from public.v_media_gallery_compat_v1)::bigint
  union all select 'public.v_services_catalog_compat_v1', to_regclass('public.v_services_catalog_compat_v1') is not null, (select count(*) from public.v_services_catalog_compat_v1)::bigint
  union all select 'public.v_platform_center_content', to_regclass('public.v_platform_center_content') is not null, (select count(*) from public.v_platform_center_content)::bigint
) s;
