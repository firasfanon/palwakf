with facts as (
  select
    (select count(*) from public.v_media_news_compat_v1) as news_rows,
    (select count(*) from public.v_media_announcements_compat_v1) as announcement_rows,
    (select count(*) from public.v_media_activities_compat_v1) as activity_rows,
    (select count(*) from public.v_media_gallery_compat_v1) as gallery_rows,
    (select count(*) from public.v_services_catalog_compat_v1) as services_rows,
    (select count(*) from media_center.content_assets) as content_assets_rows,
    (to_regclass('core.org_units') is not null) as core_org_units_present,
    (to_regclass('gis.locations') is not null or to_regclass('gis.lgus_boundary') is not null) as gis_spatial_present
)
select 'final_execution_decision' as section,
       case
         when news_rows > 0 and announcement_rows > 0 and services_rows > 0 and core_org_units_present and gis_spatial_present
           then 'EXECUTION_PLAN_APPROVED_NOT_EXECUTED'
         else 'EXECUTION_BLOCKED_MISSING_CRITICAL_CONTRACTS'
       end as decision,
       jsonb_build_object(
         'news_rows', news_rows,
         'announcement_rows', announcement_rows,
         'activity_rows', activity_rows,
         'gallery_rows', gallery_rows,
         'services_rows', services_rows,
         'content_assets_rows', content_assets_rows,
         'core_org_units_present', core_org_units_present,
         'gis_spatial_present', gis_spatial_present,
         'scope', 'decision only; no migration/extraction/reroute in this pack',
         'next_execution', 'single controlled Mega Batch after explicit user approval'
       ) as decision_payload
from facts;
