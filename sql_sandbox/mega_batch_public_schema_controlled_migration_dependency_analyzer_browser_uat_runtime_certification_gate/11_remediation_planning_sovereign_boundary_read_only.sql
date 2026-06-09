-- Mega Batch — Public Schema Direct Dependency Remediation Plan + Route Console Evidence Pack
-- 11_remediation_planning_sovereign_boundary_read_only.sql
-- SELECT-only sovereign and destructive-action boundary.

select * from (
  values
    ('11_sovereign_boundary', 'no_waq_assets_mutation_in_this_script', true, 'SELECT-only; no waqf_assets, waqf, or awqaf_system DML.'),
    ('11_sovereign_boundary', 'no_destructive_sql_in_this_script', true, 'No DROP/DELETE/ARCHIVE/RENAME/ALTER statements are included.'),
    ('11_scope_boundary', 'runtime_reroute_not_executed', true, 'This pack provides remediation planning and evidence templates only.'),
    ('11_scope_boundary', 'exact_replacement_not_authorized', true, 'Exact public table-name replacement remains blocked.'),
    ('11_scope_boundary', 'production_not_approved', true, 'No production approval is granted by this evidence/planning pack.'),
    ('11_scope_boundary', 'one_family_at_a_time_required', true, 'Reroute planning must proceed one family at a time with rollback.')
) as t(section, check_key, passed, note);
