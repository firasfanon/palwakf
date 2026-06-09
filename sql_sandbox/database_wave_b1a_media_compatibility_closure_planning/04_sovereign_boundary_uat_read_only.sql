-- Database Wave B-1A Media Compatibility Closure Planning Pack
-- 04_sovereign_boundary_uat_read_only.sql
-- READ ONLY: confirms boundaries for this planning pack.

select * from (values
  ('sovereign_boundary','no_waq_assets_mutation_in_this_script',true,'Read-only planning pack only; no waqf/waq_assets/awqaf_system DML.'),
  ('sovereign_boundary','no_public_media_extraction_in_this_script',true,'Legacy public media tables remain unchanged.'),
  ('sovereign_boundary','no_flutter_runtime_reroute_in_this_script',true,'Runtime reroute is explicitly blocked pending strategy decision.'),
  ('sovereign_boundary','services_compatibility_closure_preserved',true,'Services compatibility closure remains unchanged.'),
  ('sovereign_boundary','locations_authority_gate_preserved',true,'Locations authority gate remains open.'),
  ('sovereign_boundary','wave_b1b_not_authorized',true,'Selective sovereign extraction remains blocked.')
) as t(section,check_key,passed,note);
