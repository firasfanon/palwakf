-- Database Wave B-1A Media Bootstrap Draft Pack
-- 04_sovereign_boundary_uat_read_only.sql
-- READ ONLY. No DDL/DML.

select * from (
  values
    ('sovereign_boundary', 'no_waq_assets_mutation_in_this_script', true, 'Read-only draft pack only; no waqf/waqf_assets/awqaf_system DML.'),
    ('sovereign_boundary', 'no_media_wrapper_activation_in_this_script', true, 'Media bootstrap draft only; no wrappers are activated.'),
    ('sovereign_boundary', 'no_public_media_extraction_in_this_script', true, 'Legacy public media tables remain unchanged.'),
    ('sovereign_boundary', 'services_compatibility_closure_preserved', true, 'No service reroute or service wrapper change in this pack.'),
    ('sovereign_boundary', 'locations_authority_gate_preserved', true, 'Locations authority gate remains open.'),
    ('sovereign_boundary', 'wave_b1b_not_authorized', true, 'Selective sovereign extraction remains blocked.')
) as t(section, check_key, passed, note);
