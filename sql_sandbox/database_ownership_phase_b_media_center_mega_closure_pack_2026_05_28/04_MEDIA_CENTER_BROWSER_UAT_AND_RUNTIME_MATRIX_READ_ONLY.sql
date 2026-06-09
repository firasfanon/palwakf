-- Database Ownership Phase B — Media Center Mega Closure Pack
-- 04 — Browser and runtime UAT matrix. READ ONLY.

with route_matrix(route_family, route_path, expected_runtime_source, expected_evidence) as (
  values
    ('public_media'::text, '/home'::text, 'public media compatibility views', 'homepage media/news/announcement blocks load without red console/network errors'),
    ('public_media', '/home/news', 'public.v_media_news_compat_v1', 'news list loads published items and remains responsive'),
    ('public_media', '/home/news/:id', 'public.v_media_news_compat_v1', 'news detail resolves stable id/content key'),
    ('public_media', '/home/announcements', 'public.v_media_announcements_compat_v1', 'announcements list loads published items'),
    ('public_media', '/home/announcements/:id', 'public.v_media_announcements_compat_v1', 'announcement detail resolves stable id/content key'),
    ('public_media', '/home/activities', 'public.v_media_activities_compat_v1', 'activities list loads without 400/404/406'),
    ('admin_media', '/admin/media-center/news', 'admin surface preserved', 'admin route opens without RenderFlex/PostgREST red errors'),
    ('admin_media', '/admin/media-center/announcements', 'admin surface preserved', 'admin route opens without RenderFlex/PostgREST red errors'),
    ('admin_media', '/admin/media-center/activities', 'admin surface preserved', 'admin route opens without RenderFlex/PostgREST red errors')
)
select
  'phase_b_media_browser_runtime_uat_matrix'::text as section,
  route_family,
  route_path,
  expected_runtime_source,
  expected_evidence,
  false as evidence_accepted_by_this_script,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as archive_delete_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only
from route_matrix;
