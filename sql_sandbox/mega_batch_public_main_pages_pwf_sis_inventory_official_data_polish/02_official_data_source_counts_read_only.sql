-- Read-only official data source counts for public main pages.
with checks as (
  select 'public.homepage_sections' as contract_name,
         to_regclass('public.homepage_sections') is not null as present,
         case when to_regclass('public.homepage_sections') is not null then (select count(*)::bigint from public.homepage_sections) end as row_count
  union all
  select 'public.v_media_news_compat_v1', to_regclass('public.v_media_news_compat_v1') is not null,
         case when to_regclass('public.v_media_news_compat_v1') is not null then (select count(*)::bigint from public.v_media_news_compat_v1) end
  union all
  select 'public.v_media_announcements_compat_v1', to_regclass('public.v_media_announcements_compat_v1') is not null,
         case when to_regclass('public.v_media_announcements_compat_v1') is not null then (select count(*)::bigint from public.v_media_announcements_compat_v1) end
  union all
  select 'public.v_media_activities_compat_v1', to_regclass('public.v_media_activities_compat_v1') is not null,
         case when to_regclass('public.v_media_activities_compat_v1') is not null then (select count(*)::bigint from public.v_media_activities_compat_v1) end
  union all
  select 'public.v_media_gallery_compat_v1', to_regclass('public.v_media_gallery_compat_v1') is not null,
         case when to_regclass('public.v_media_gallery_compat_v1') is not null then (select count(*)::bigint from public.v_media_gallery_compat_v1) end
  union all
  select 'public.v_services_catalog_compat_v1', to_regclass('public.v_services_catalog_compat_v1') is not null,
         case when to_regclass('public.v_services_catalog_compat_v1') is not null then (select count(*)::bigint from public.v_services_catalog_compat_v1) end
  union all
  select 'public.v_platform_center_content', to_regclass('public.v_platform_center_content') is not null,
         case when to_regclass('public.v_platform_center_content') is not null then (select count(*)::bigint from public.v_platform_center_content) end
)
select 'official_data_source_counts' as section, * from checks order by contract_name;
