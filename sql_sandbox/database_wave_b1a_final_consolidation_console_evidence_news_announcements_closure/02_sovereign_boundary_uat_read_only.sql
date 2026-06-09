-- Database Wave B-1A Final Consolidation Sovereign Boundary UAT
-- Read-only. No DML. No schema changes.

select * from (values
  ('sovereign_boundary','no_waq_assets_mutation_in_this_script',true,'Read-only only; no waqf/waqf_assets/awqaf_system DML.'),
  ('sovereign_boundary','no_public_media_extraction_in_this_script',true,'No extraction/move/delete from legacy public media tables.'),
  ('sovereign_boundary','no_locations_activation_in_this_script',true,'Locations authority gate remains open.'),
  ('sovereign_boundary','wave_b1b_not_authorized',true,'Wave B-1B is not authorized by this pack.'),
  ('sovereign_boundary','production_not_approved',true,'Production remains not approved without clean console evidence.')
) as t(section, check_key, passed, note);
