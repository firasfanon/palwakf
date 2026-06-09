-- Platform Database Dependency Wave A — Access Helpers Actual Remediation Pack
-- SQL 39: RLS/Browser evidence matrix, read-only.

select
  'wave_a_access_helpers_rls_actor_case' as section,
  case_key,
  expected_evidence,
  false as accepted_by_this_script,
  false as execution_authorized,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as read_only
from (
  values
    ('anonymous', 'assistant/core/tasks access helpers deny anonymous callers'),
    ('unauthorized_authenticated_user', 'authenticated user without role/permission is denied'),
    ('wrong_unit_user', 'unit-limited user cannot edit or see cross-unit admin/task paths'),
    ('scoped_user', 'scoped user only receives allowed scoped result'),
    ('platform_admin', 'platform admin path is allowed and auditable'),
    ('superuser', 'superuser positive path is allowed and auditable')
) as actor_cases(case_key, expected_evidence)
union all
select
  'wave_a_access_helpers_browser_console_route' as section,
  route_key as case_key,
  'no red console, no 400/404/406/500 network errors after access-helper remediation' as expected_evidence,
  false as accepted_by_this_script,
  false as execution_authorized,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as read_only
from (
  values
    ('/admin/database-migration'),
    ('/admin/dashboard'),
    ('/admin/home-management'),
    ('/admin/assistant'),
    ('/admin/tasks'),
    ('/home'),
    ('/home/news'),
    ('/home/announcements')
) as routes(route_key);
