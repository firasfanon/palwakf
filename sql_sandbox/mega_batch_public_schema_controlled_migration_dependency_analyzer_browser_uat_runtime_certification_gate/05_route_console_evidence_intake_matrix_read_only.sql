-- 05_route_console_evidence_intake_matrix_read_only.sql
-- Mega Batch: Public Schema Controlled Migration Route Console Evidence Intake
-- Date: 2026-05-22
-- Safety: SELECT-only. No DDL, no DML, no destructive SQL.
-- Purpose: emit the route-console evidence matrix and record that no route
-- console-clean evidence was supplied in this batch.

select * from (
  values
    ('home', '/home', 'anonymous', 'open and hard-refresh; inspect Network + Console', 'console_clean_required', 'pending_not_supplied'),
    ('home_news', '/home/news', 'anonymous', 'open list; verify cards and latest news', 'console_clean_required', 'pending_not_supplied'),
    ('home_news_detail', '/home/news/:id', 'anonymous', 'open a known published item detail', 'console_clean_required', 'pending_not_supplied'),
    ('home_announcements', '/home/announcements', 'anonymous', 'open list and filters', 'console_clean_required', 'pending_not_supplied'),
    ('home_announcements_detail', '/home/announcements/:id', 'anonymous', 'open a known published announcement detail', 'console_clean_required', 'pending_not_supplied'),
    ('home_gallery', '/home/gallery', 'anonymous', 'verify gallery empty/non-empty state', 'console_clean_required', 'pending_not_supplied'),
    ('home_zakat', '/home/zakat', 'anonymous', 'open calculator; payment remains disabled', 'console_clean_required', 'pending_not_supplied'),
    ('legacy_zakat_alias', '/zakat', 'anonymous', 'verify canonical alias behavior', 'console_clean_required', 'pending_not_supplied'),
    ('legacy_press_alias', '/press-releases', 'anonymous', 'verify canonical alias behavior', 'console_clean_required', 'pending_not_supplied'),
    ('admin_database_migration', '/admin/database-migration', 'platform_admin', 'open gate page; verify route-console/reroute card', 'console_clean_required', 'pending_not_supplied'),
    ('admin_database_migration_unauthorized', '/admin/database-migration', 'unauthorized_user', 'verify fail-closed behavior', 'no_data_leakage_required', 'pending_not_supplied')
) as routes(route_key, route_path, actor, action_required, pass_condition, evidence_status);

select * from (
  values
    ('analyzer', 'accepted_from_previous_gate_result_intake', true, 'flutter analyze returned No issues found'),
    ('chrome_startup', 'accepted_from_previous_gate_result_intake', true, 'flutter run -d chrome reached Debug service and Supabase initialized'),
    ('route_console', 'not_supplied_in_this_batch', false, 'Browser console evidence per route is still required'),
    ('dependency_zero', 'not_certified_in_this_batch', false, 'Static/runtime dependencies must be zero before reroute/destructive planning can advance'),
    ('sovereign_boundary', 'non_negotiable', true, 'No waqf_assets/waqf/awqaf_system mutation')
) as gate_evidence(gate_key, evidence_source, accepted, note);
