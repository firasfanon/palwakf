-- Platform Database Dependency Remediation Wave A
-- SQL 27: RLS/browser evidence matrix (READ ONLY)
-- Lists required evidence before any execution candidate can be reviewed.

select *
from (values
  ('rls_actor_case', 'anonymous', 'all owner-write RPCs denied', false),
  ('rls_actor_case', 'unauthorized_authenticated_user', 'all owner-write RPCs denied', false),
  ('rls_actor_case', 'wrong_unit_user', 'cross-unit writes denied', false),
  ('rls_actor_case', 'scoped_user', 'only scoped read/write allowed by contract', false),
  ('rls_actor_case', 'platform_admin', 'admin write allowed only via RPC/audit', false),
  ('rls_actor_case', 'superuser', 'superuser positive path audited', false),
  ('browser_console_route', '/admin/database-migration', 'no RenderFlex/no 400-404-406/no red console', false),
  ('browser_console_route', '/admin/dashboard', 'no RenderFlex/no 400-404-406/no red console', false),
  ('browser_console_route', '/admin/home-management', 'no RenderFlex/no 400-404-406/no red console', false),
  ('browser_console_route', '/home', 'no RenderFlex/no 400-404-406/no red console', false),
  ('browser_console_route', '/home/news', 'no RenderFlex/no 400-404-406/no red console', false),
  ('browser_console_route', '/home/announcements', 'no RenderFlex/no 400-404-406/no red console', false)
) as t(section, case_key, expected_evidence, accepted_by_this_script)
cross join lateral (
  select
    false as execution_authorized,
    false as production_approved,
    false as destructive_sql_authorized,
    false as exact_public_table_replacement_authorized,
    true as no_auth_users_migration,
    true as no_flutter_elevated_secret,
    true as no_waqf_assets_mutation,
    true as read_only
) safety;
