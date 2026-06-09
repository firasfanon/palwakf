-- 08_route_console_sovereign_boundary_read_only.sql
-- Mega Batch: Public Schema Controlled Migration Route Console Sovereign Boundary
-- Date: 2026-05-22
-- Safety: SELECT-only. No DDL, no DML, no destructive SQL.

select * from (
  values
    ('08_sovereign_boundary', 'no_waq_assets_mutation_in_this_script', true, 'SELECT-only; no waqf_assets, waqf, or awqaf_system DML.'),
    ('08_sovereign_boundary', 'no_destructive_sql_in_this_script', true, 'No DROP/DELETE/ARCHIVE/RENAME/ALTER statements are included.'),
    ('08_scope_boundary', 'runtime_reroute_not_executed', true, 'This pack only plans reroute gates; it does not change Flutter data sources.'),
    ('08_scope_boundary', 'exact_replacement_not_authorized', true, 'Exact public table-name replacement remains blocked.'),
    ('08_scope_boundary', 'production_not_approved', true, 'No production approval is granted by this evidence/planning pack.')
) as checks(section, check_key, passed, note);
