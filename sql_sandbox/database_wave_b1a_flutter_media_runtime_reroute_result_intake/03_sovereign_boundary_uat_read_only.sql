-- Database Wave B-1A — Sovereign Boundary UAT Result Intake
-- Read-only statement. No DDL/DML.

select * from (values
  ('sovereign_boundary','no_waq_assets_mutation_in_this_script',true,'Result intake only; no waqf/waqf_assets/awqaf_system DML.'),
  ('sovereign_boundary','no_public_media_extraction_in_this_script',true,'No import/move/delete from public media tables.'),
  ('sovereign_boundary','no_flutter_functional_change_in_this_pack',true,'This pack only records evidence; previous reroute pack remains unchanged.'),
  ('sovereign_boundary','activities_not_rerouted',true,'Activities remain blocked/out of scope.'),
  ('sovereign_boundary','gallery_not_rerouted',true,'Gallery remains blocked pending asset/content mapping.'),
  ('sovereign_boundary','locations_authority_gate_preserved',true,'No locations wrapper activation.'),
  ('sovereign_boundary','wave_b1b_not_authorized',true,'Selective sovereign extraction remains blocked.'),
  ('sovereign_boundary','production_not_approved',true,'Browser click-through evidence is pending.')
) as t(section, check_key, passed, note);
