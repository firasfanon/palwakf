-- Database Wave B-1A — Sovereign Boundary UAT
-- READ ONLY. No DDL. No DML. No migration.

select * from (
  values
    ('sovereign_boundary','no_waq_assets_mutation_in_this_script',true,'Read-only readiness pack only; no waqf/waqf_assets/awqaf_system DML.'),
    ('sovereign_boundary','no_media_wrapper_activation_in_this_script',true,'Media bootstrap planning only; no wrappers are activated.'),
    ('sovereign_boundary','no_locations_wrapper_activation_in_this_script',true,'Locations authority gate remains open; no wrapper activation.'),
    ('sovereign_boundary','services_compatibility_closure_preserved',true,'No new service reroute in this pack.'),
    ('sovereign_boundary','wave_b1b_not_authorized',true,'Selective sovereign extraction remains blocked.')
) as t(section, check_key, passed, note);
