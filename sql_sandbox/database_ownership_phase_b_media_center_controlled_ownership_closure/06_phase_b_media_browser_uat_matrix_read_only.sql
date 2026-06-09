-- Database Ownership Phase B — Media browser UAT matrix. READ ONLY.

with t(route_family, route_path, expected_evidence) as (
  values
    ('media_public_route'::text, '/home'::text, 'homepage media cards do not break and no red console/network errors'::text),
    ('media_public_route', '/home/news', 'news list loads from approved media compatibility surface'),
    ('media_public_route', '/home/news/:id', 'news detail route resolves stable compat id and displays content'),
    ('media_public_route', '/home/announcements', 'announcements list loads from approved media compatibility surface'),
    ('media_public_route', '/home/announcements/:id', 'announcement detail route resolves stable compat id and displays content'),
    ('media_admin_route', '/admin/media-center/news', 'admin news management route has no RenderFlex/PostgREST red errors'),
    ('media_admin_route', '/admin/media-center/announcements', 'admin announcements management route has no RenderFlex/PostgREST red errors'),
    ('media_admin_route', '/admin/media-center/activities', 'admin activities management route has no RenderFlex/PostgREST red errors')
)
select
  'phase_b_media_browser_uat_matrix'::text as section,
  route_family,
  route_path,
  expected_evidence,
  false as evidence_accepted_by_this_script,
  false as execution_authorized,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as archive_delete_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only
from t;
