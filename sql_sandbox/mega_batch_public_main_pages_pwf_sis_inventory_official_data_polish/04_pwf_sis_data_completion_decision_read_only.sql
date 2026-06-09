-- Read-only decision matrix. The output is intentionally conservative.
with c as (
  select
    coalesce((select count(*) from public.v_media_news_compat_v1),0) as news_rows,
    coalesce((select count(*) from public.v_media_announcements_compat_v1),0) as announcement_rows,
    coalesce((select count(*) from public.v_media_activities_compat_v1),0) as activity_rows,
    coalesce((select count(*) from public.v_media_gallery_compat_v1),0) as gallery_rows,
    coalesce((select count(*) from public.v_services_catalog_compat_v1),0) as services_rows,
    coalesce((select count(*) from public.homepage_sections),0) as homepage_sections_rows
)
select 'pwf_sis_public_pages_data_completion_decision' as section,
       case
         when news_rows > 0 and announcement_rows > 0 and services_rows > 0 and homepage_sections_rows > 0
              then 'CORE_PUBLIC_SURFACES_DATA_READY_WITH_ACTIVITIES_GALLERY_AND_TOOLS_GAPS'
         else 'CORE_PUBLIC_SURFACES_DATA_INCOMPLETE'
       end as decision,
       jsonb_build_object(
         'news_rows', news_rows,
         'announcement_rows', announcement_rows,
         'activity_rows', activity_rows,
         'gallery_rows', gallery_rows,
         'services_rows', services_rows,
         'homepage_sections_rows', homepage_sections_rows,
         'known_gaps', jsonb_build_array('zakat official config/source', 'chat official source allowlist', 'static pages official content rows', 'activities/gallery nonzero public wrappers')
       ) as decision_payload
from c;
