-- Full Site Audit Clean Admin Console Retest Result Intake
-- READ ONLY marker; no database mutation.
select * from (values
  ('full_site_audit_clean_admin_console_retest', 'auth_token_400_cleared_in_supplied_screenshots', true, false, false, true),
  ('full_site_audit_clean_admin_console_retest', 'canonical_database_migration_route_rendered', true, false, false, true),
  ('full_site_audit_clean_admin_console_retest', 'legacy_alias_direct_retest_pending', false, false, false, true),
  ('full_site_audit_clean_admin_console_retest', 'production_approved', false, false, false, true)
) as t(section, gate_key, passed, execution_authorized_by_this_script, production_approved, read_only);
