-- Database Wave B-1A Media Bootstrap Apply Result Sovereign Boundary — READ ONLY
select * from (values
  ('sovereign_boundary','no_waq_assets_mutation_in_this_script',true,'Read-only UAT; no waqf/waqf_assets/awqaf_system DML.'),
  ('sovereign_boundary','no_public_media_extraction_in_this_script',true,'Legacy public media tables remain unchanged; no import/move/delete.'),
  ('sovereign_boundary','no_public_media_wrapper_activation_in_this_script',true,'No public.v_media_* wrapper is activated by this read-only replay.'),
  ('sovereign_boundary','services_compatibility_closure_preserved',true,'Services compatibility closure remains unchanged.'),
  ('sovereign_boundary','locations_authority_gate_preserved',true,'Locations authority gate remains open.'),
  ('sovereign_boundary','wave_b1b_not_authorized',true,'Selective sovereign extraction remains blocked.'),
  ('media_center_bootstrap','empty_contracts_created_only',true,'media_center contracts created without legacy data import.')
) as t(section, check_key, passed, note);
