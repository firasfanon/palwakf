-- Database Wave B-1A
-- 02_sovereign_boundary_uat_read_only.sql
-- Read-only boundary confirmation.

select * from (values
  ('sovereign_boundary','no_waq_assets_mutation_in_this_script', true, 'Read-only decision pack only; no waqf/waqf_assets/awqaf_system DML.'),
  ('sovereign_boundary','no_public_media_extraction_in_this_script', true, 'No import/move/delete from public legacy media tables.'),
  ('sovereign_boundary','no_flutter_runtime_change_in_this_pack', true, 'This pack is decision/UAT documentation only.'),
  ('sovereign_boundary','activities_not_rerouted', true, 'Activities remain outside runtime reroute.'),
  ('sovereign_boundary','gallery_not_rerouted', true, 'Gallery remains blocked pending asset/content mapping.'),
  ('sovereign_boundary','locations_authority_gate_preserved', true, 'No locations activation.'),
  ('sovereign_boundary','wave_b1b_not_authorized', true, 'Selective extraction remains blocked.'),
  ('sovereign_boundary','production_not_approved', true, 'Production approval requires console clean evidence.')
) as t(section, check_key, passed, note);
