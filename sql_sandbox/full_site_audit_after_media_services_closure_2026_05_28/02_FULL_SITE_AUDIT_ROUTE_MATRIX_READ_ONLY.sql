with routes(route_family, route_path, expected_evidence, current_gate) as (
  values
    ('public_shell','/home','home renders without red console/network blockers','partial_pass_from_phase_b_phase_c'),
    ('public_media','/home/news','news list renders from media compatibility surface','accepted_phase_b'),
    ('public_media','/home/announcements','announcements list renders from media compatibility surface','accepted_phase_b'),
    ('public_media','/home/activities','activities list renders','accepted_phase_b'),
    ('public_services','/home/services','services catalog renders from public compatibility surface','accepted_phase_c'),
    ('public_services','/home/eservices','e-services portal renders','accepted_phase_c'),
    ('public_services','/home/services/request','request entry renders; submit requires controlled UAT data','rendering_accepted_submit_not_production_approved'),
    ('public_services','/home/services/track','tracking renders; public result exposes safe fields only','rendering_accepted_tracking_data_not_submitted'),
    ('legacy_alias','/services','legacy alias renders or redirects','accepted_phase_c'),
    ('legacy_alias','/services/request','legacy request alias renders or redirects','accepted_phase_c'),
    ('legacy_alias','/services/track','legacy tracking alias renders or redirects','accepted_phase_c'),
    ('admin_shell','/admin/dashboard','admin dashboard renders without strict red console blockers','warning_auth_token_400'),
    ('admin_platform','/admin/database-migration','database migration page renders after compile hotfix','retest_recommended'),
    ('admin_media','/admin/media-center/news','admin news surface renders','accepted_phase_b'),
    ('admin_media','/admin/media-center/announcements','admin announcements surface renders','accepted_phase_b'),
    ('admin_media','/admin/media-center/activities','admin activities surface renders','accepted_phase_b'),
    ('admin_services','/admin/surfaces-services','service admin hub renders','accepted_with_auth_warning'),
    ('admin_services','/admin/surfaces-services/forms-registry','forms registry renders','accepted_with_auth_warning'),
    ('admin_services','/admin/surfaces-services/request-queue','request queue renders','accepted_with_auth_warning'),
    ('admin_services','/admin/surfaces-services/requests','requests workflow renders','accepted_with_auth_warning')
)
select
  'full_site_audit_route_matrix'::text as section,
  route_family,
  route_path,
  expected_evidence,
  current_gate,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as archive_delete_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only
from routes;
