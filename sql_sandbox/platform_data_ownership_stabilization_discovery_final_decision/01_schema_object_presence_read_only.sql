select * from (
  values
    ('schema','media_center', to_regnamespace('media_center') is not null),
    ('schema','platform_services', to_regnamespace('platform_services') is not null),
    ('schema','gis', to_regnamespace('gis') is not null),
    ('schema','core', to_regnamespace('core') is not null),
    ('table','media_center.content_items', to_regclass('media_center.content_items') is not null),
    ('table','media_center.content_assets', to_regclass('media_center.content_assets') is not null),
    ('table','media_center.editorial_events', to_regclass('media_center.editorial_events') is not null),
    ('view','media_center.v_content_items_public_v1', to_regclass('media_center.v_content_items_public_v1') is not null),
    ('view','public.v_media_content_compat_v1', to_regclass('public.v_media_content_compat_v1') is not null),
    ('view','public.v_media_news_compat_v1', to_regclass('public.v_media_news_compat_v1') is not null),
    ('view','public.v_media_announcements_compat_v1', to_regclass('public.v_media_announcements_compat_v1') is not null),
    ('view','public.v_media_activities_compat_v1', to_regclass('public.v_media_activities_compat_v1') is not null),
    ('view','public.v_media_gallery_compat_v1', to_regclass('public.v_media_gallery_compat_v1') is not null),
    ('view','public.v_services_catalog_compat_v1', to_regclass('public.v_services_catalog_compat_v1') is not null),
    ('table','public.news_articles', to_regclass('public.news_articles') is not null),
    ('table','public.announcements', to_regclass('public.announcements') is not null),
    ('table','public.activities', to_regclass('public.activities') is not null),
    ('table','public.media_gallery_items', to_regclass('public.media_gallery_items') is not null),
    ('table','public.locations', to_regclass('public.locations') is not null),
    ('table','gis.locations', to_regclass('gis.locations') is not null),
    ('table','core.org_units', to_regclass('core.org_units') is not null),
    ('view','public.org_units', to_regclass('public.org_units') is not null)
) as t(object_type, contract_name, passed)
order by object_type, contract_name;
