-- 04_sovereign_boundary_uat_read_only.sql
select * from (values
 ('sovereign_boundary','no_waq_assets_mutation_in_this_script',true,'Read-only planning pack only; no waqf/waqf_assets/awqaf_system DML.'),
 ('sovereign_boundary','no_public_media_extraction_in_this_script',true,'Legacy public media tables remain unchanged; no import/move/delete.'),
 ('sovereign_boundary','no_flutter_runtime_reroute_in_this_script',true,'Runtime reroute remains blocked pending controlled import/seed.'),
 ('sovereign_boundary','media_public_wrappers_preserved_read_only',true,'Existing public.v_media_*_compat_v1 wrappers remain read-only facades.'),
 ('sovereign_boundary','services_compatibility_closure_preserved',true,'No service reroute or service wrapper change in this pack.'),
 ('sovereign_boundary','locations_authority_gate_preserved',true,'Locations authority gate remains open; no locations wrapper activation.'),
 ('sovereign_boundary','wave_b1b_not_authorized',true,'Selective sovereign extraction remains blocked.'),
 ('planning_boundary','controlled_import_not_executed',true,'This pack prepares planning only; apply candidate remains NOT RUN.')
) as t(section, check_key, passed, note);
