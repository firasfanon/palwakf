-- Database Wave B-1A — Sovereign Boundary UAT for Flutter Media Runtime Reroute Pack
-- Read-only statement of boundaries. This script performs no DML/DDL.

select * from (values
  ('sovereign_boundary','no_waq_assets_mutation_in_this_script',true,'Read-only UAT only; no waqf/waqf_assets/awqaf_system DML.'),
  ('sovereign_boundary','no_public_media_extraction_in_this_script',true,'Legacy public media tables remain unchanged; no import/move/delete.'),
  ('sovereign_boundary','no_sql_schema_change_in_this_pack',true,'Flutter reroute pack adds no SQL DDL/DML.'),
  ('sovereign_boundary','activities_not_rerouted',true,'Activities remain out of scope because preflight returned zero rows.'),
  ('sovereign_boundary','gallery_not_rerouted',true,'Gallery remains blocked pending asset/content mapping.'),
  ('sovereign_boundary','locations_authority_gate_preserved',true,'No locations wrapper activation.'),
  ('sovereign_boundary','wave_b1b_not_authorized',true,'Selective sovereign extraction remains blocked.'),
  ('sovereign_boundary','production_not_approved',true,'Browser UAT/analyzer evidence still required.')
) as t(section, check_key, passed, note);
