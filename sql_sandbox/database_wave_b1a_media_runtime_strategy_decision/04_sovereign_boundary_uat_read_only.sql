-- Database Wave B-1A Media Runtime Strategy Decision
-- 04_sovereign_boundary_uat_read_only.sql
-- Read-only boundary assertions.

select * from (values
  ('sovereign_boundary'::text, 'no_waq_assets_mutation_in_this_script', true, 'Read-only strategy pack only; no waqf/waqf_assets/awqaf_system DML.'),
  ('sovereign_boundary', 'no_public_media_extraction_in_this_script', true, 'Legacy public media tables remain unchanged; no import/move/delete.'),
  ('sovereign_boundary', 'no_flutter_runtime_reroute_in_this_script', true, 'Runtime reroute remains blocked pending controlled data strategy.'),
  ('sovereign_boundary', 'media_public_wrappers_preserved_read_only', true, 'Existing public.v_media_*_compat_v1 wrappers remain read-only facades.'),
  ('sovereign_boundary', 'services_compatibility_closure_preserved', true, 'No service reroute or service wrapper change in this pack.'),
  ('sovereign_boundary', 'locations_authority_gate_preserved', true, 'Locations authority gate remains open; no locations wrapper activation.'),
  ('sovereign_boundary', 'wave_b1b_not_authorized', true, 'Selective sovereign extraction remains blocked.')
) as t(section, check_key, passed, note);
