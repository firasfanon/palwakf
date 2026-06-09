-- Database Wave B-1A — Controlled Media Import/Seed Contract Review
-- 04: Sovereign boundary UAT. No DML.

select * from (values
  ('sovereign_boundary','no_waq_assets_mutation_in_this_script', true, 'Read-only review only; no waqf/waqf_assets/awqaf_system DML.'),
  ('sovereign_boundary','no_public_media_extraction_in_this_script', true, 'Legacy public media tables remain unchanged; no import/move/delete in read-only review files.'),
  ('sovereign_boundary','no_flutter_runtime_reroute_in_this_script', true, 'Runtime reroute remains blocked pending controlled seed apply and UAT.'),
  ('sovereign_boundary','media_public_wrappers_preserved_read_only', true, 'Existing public.v_media_*_compat_v1 wrappers remain read-only facades.'),
  ('sovereign_boundary','services_compatibility_closure_preserved', true, 'No service reroute or service wrapper change in this pack.'),
  ('sovereign_boundary','locations_authority_gate_preserved', true, 'Locations authority gate remains open; no locations wrapper activation.'),
  ('sovereign_boundary','wave_b1b_not_authorized', true, 'Selective sovereign extraction remains blocked.'),
  ('planning_boundary','controlled_import_apply_candidate_not_run_by_default', true, 'File 05 is an apply candidate and must not be run without explicit approval.')
) as t(section, check_key, passed, note);
