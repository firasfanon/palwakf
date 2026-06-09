-- Database Wave B-1A — Sovereign Boundary UAT after Media Center Bootstrap Apply
-- Read-only, no DML.
select * from (values
  ('sovereign_boundary','no_waq_assets_mutation_in_this_script', true, 'Read-only UAT only; no waqf/waqf_assets/awqaf_system DML.'),
  ('sovereign_boundary','no_public_media_extraction_in_this_script', true, 'Legacy public media tables remain unchanged; no data import/move/delete.'),
  ('sovereign_boundary','no_public_media_wrapper_activation_in_this_script', true, 'No public.v_media_* compatibility wrapper is activated.'),
  ('sovereign_boundary','services_compatibility_closure_preserved', true, 'Services compatibility closure remains unchanged.'),
  ('sovereign_boundary','locations_authority_gate_preserved', true, 'Locations authority gate remains open; no locations wrapper activation.'),
  ('sovereign_boundary','wave_b1b_not_authorized', true, 'Selective sovereign extraction remains blocked.'),
  ('media_center_bootstrap','empty_contracts_created_only', true, 'media_center tables/views/RLS contracts are created without legacy data import.')
) as t(section, check_key, passed, note);
