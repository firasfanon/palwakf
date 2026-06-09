-- 04_public_runtime_final_sovereign_boundary_read_only.sql
-- Read-only boundary declaration.

select * from (values
  ('sovereign_boundary', 'no_waq_assets_mutation_in_this_script', true, 'Read-only final shell certification helper only; no waqf/waqf_assets/awqaf_system DML.'),
  ('sovereign_boundary', 'no_public_media_extraction_in_this_script', true, 'Legacy public media tables are preserved; no import/move/delete is executed.'),
  ('sovereign_boundary', 'locations_authority_gate_preserved', true, 'No locations wrapper activation is included.'),
  ('sovereign_boundary', 'wave_b1b_not_authorized', true, 'Selective sovereign extraction remains blocked.'),
  ('sovereign_boundary', 'activities_gallery_reroute_not_included', true, 'Activities and gallery remain blocked pending rows/mapping approval.'),
  ('sovereign_boundary', 'production_not_approved', true, 'This pack does not approve production without browser/console evidence.')
) as t(section, check_key, passed, note);
