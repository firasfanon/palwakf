-- Mega Batch: Media/Services Data Ownership Final Closure
-- Script 01: Legacy inventory read-only
-- Purpose: inventory current media/services legacy tables and compatibility wrappers.

with objects as (
  select * from (values
    ('schema','media_center', null),
    ('schema','platform_services', null),
    ('table','media_center.content_items', 'select count(*) as count from media_center.content_items'),
    ('table','media_center.content_assets', 'select count(*) as count from media_center.content_assets'),
    ('table','public.news_articles', 'select count(*) as count from public.news_articles'),
    ('table','public.announcements', 'select count(*) as count from public.announcements'),
    ('table','public.activities', 'select count(*) as count from public.activities'),
    ('table','public.media_gallery_items', 'select count(*) as count from public.media_gallery_items'),
    ('table','public.services', 'select count(*) as count from public.services'),
    ('table','public.servicepoints', 'select count(*) as count from public.servicepoints'),
    ('table','public.serviceproviders', 'select count(*) as count from public.serviceproviders'),
    ('table','public.servicetypes', 'select count(*) as count from public.servicetypes'),
    ('view','public.v_media_news_compat_v1', 'select count(*) as count from public.v_media_news_compat_v1'),
    ('view','public.v_media_announcements_compat_v1', 'select count(*) as count from public.v_media_announcements_compat_v1'),
    ('view','public.v_media_activities_compat_v1', 'select count(*) as count from public.v_media_activities_compat_v1'),
    ('view','public.v_media_gallery_compat_v1', 'select count(*) as count from public.v_media_gallery_compat_v1'),
    ('view','public.v_services_catalog_compat_v1', 'select count(*) as count from public.v_services_catalog_compat_v1')
  ) as t(object_type, contract_name, count_sql)
), resolved as (
  select
    object_type,
    contract_name,
    case
      when object_type='schema' then exists(select 1 from information_schema.schemata s where s.schema_name = contract_name)
      else to_regclass(contract_name) is not null
    end as present,
    count_sql
  from objects
)
select
  'media_services_legacy_inventory' as section,
  object_type,
  contract_name,
  present,
  case
    when present and count_sql is not null then (xpath('/row/count/text()', query_to_xml(count_sql, false, true, '')))[1]::text::bigint
    else null
  end as row_count
from resolved
order by object_type, contract_name;
