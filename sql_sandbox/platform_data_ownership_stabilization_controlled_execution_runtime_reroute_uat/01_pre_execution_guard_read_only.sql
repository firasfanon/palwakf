-- 01_pre_execution_guard_read_only.sql
-- READ ONLY. Confirms required contracts before controlled execution.

select * from (
  values
    ('schema','media_center', to_regnamespace('media_center') is not null),
    ('schema','platform_services', to_regnamespace('platform_services') is not null),
    ('schema','core', to_regnamespace('core') is not null),
    ('schema','gis', to_regnamespace('gis') is not null),
    ('table','media_center.content_items', to_regclass('media_center.content_items') is not null),
    ('table','media_center.content_assets', to_regclass('media_center.content_assets') is not null),
    ('table','media_center.editorial_events', to_regclass('media_center.editorial_events') is not null),
    ('table','public.activities', to_regclass('public.activities') is not null),
    ('table','public.news_articles', to_regclass('public.news_articles') is not null),
    ('table','public.announcements', to_regclass('public.announcements') is not null),
    ('table','public.media_gallery_items', to_regclass('public.media_gallery_items') is not null),
    ('table','gis.locations', to_regclass('gis.locations') is not null),
    ('view','public.v_services_catalog_compat_v1', to_regclass('public.v_services_catalog_compat_v1') is not null)
) as t(object_type, contract_name, passed)
order by object_type, contract_name;

select 'pre_execution_counts' as section, check_key, value
from (
  select 'media_center.content_items' check_key, (select count(*) from media_center.content_items)::bigint value
  union all select 'media_center.content_assets', (select count(*) from media_center.content_assets)::bigint
  union all select 'public.activities', (select count(*) from public.activities)::bigint
  union all select 'public.media_gallery_items', (select count(*) from public.media_gallery_items)::bigint
  union all select 'public.v_media_activities_compat_v1', (select count(*) from public.v_media_activities_compat_v1)::bigint
  union all select 'public.v_media_gallery_compat_v1', (select count(*) from public.v_media_gallery_compat_v1)::bigint
  union all select 'public.v_services_catalog_compat_v1', (select count(*) from public.v_services_catalog_compat_v1)::bigint
) s;
