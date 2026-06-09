-- Database Wave B-1A Media Bootstrap Contract Approval
-- 03_media_contract_approval_decision_matrix.sql
-- Read-only decision matrix. No DDL/DML.

select * from (values
  ('media_center', 'bootstrap_contract', 'approved_for_next_controlled_schema_apply', 'Create empty media_center contracts only; no data import.'),
  ('media_center', 'wrapper_activation', 'blocked', 'Requires bootstrap apply, RLS UAT, published-only public view UAT.'),
  ('media_center', 'public_media_extraction', 'blocked', 'Do not move legacy public media tables in B-1A.'),
  ('services', 'services_compatibility_closure', 'preserve', 'No new service reroute in this pack.'),
  ('locations', 'locations_authority_gate', 'blocked', 'Authority decision remains open.'),
  ('waqf', 'waqf_assets_boundary', 'forbidden', 'No mutation/no extraction/no wrapper activation.'),
  ('wave_b1b', 'selective_sovereign_extraction', 'not_authorized', 'Extraction remains unauthorized.')
) as t(domain_key, contract_key, approval_state, note);
