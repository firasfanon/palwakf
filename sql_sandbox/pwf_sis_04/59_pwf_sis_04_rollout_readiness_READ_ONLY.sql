-- PWF-SIS-04 rollout readiness evidence — READ ONLY
-- No DDL / No DML / No waqf_assets mutation / No Database Wave B execution.

select * from (
  values
    ('sovereign_boundary', 'no_waq_assets_mutation_in_this_script', true, 'Read-only evidence only; no DDL/DML; no waqf/waqf_assets/awqaf_system mutation.'),
    ('database_wave_b', 'preserved_not_executed_in_pwf_sis_04', true, 'PWF-SIS-04 does not execute SQL54/SQL55 or move public schema tables.'),
    ('production_gate', 'production_not_approved', true, 'Controlled rollout evidence is required before any production approval.'),
    ('browser_evidence', 'responsive_browser_evidence_required', true, 'Desktop/tablet/mobile screenshots and console review are required.'),
    ('role_evidence', 'role_based_ui_validation_required', true, 'Superuser/platform-admin/restricted role checks are required.')
) as t(section, check_key, passed, note);
