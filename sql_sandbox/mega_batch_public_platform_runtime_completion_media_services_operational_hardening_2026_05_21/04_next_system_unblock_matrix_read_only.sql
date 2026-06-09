-- Next system unblock matrix — read only
select * from (values
  ('awqaf_system','unblocked_for_next_mega_batch','Respect waqf_assets governance and role/browser/UAT gates.'),
  ('nosok','unblocked_for_next_mega_batch','Use nosok schema with core reference wrappers; no public as source of truth.'),
  ('mustakshif','unblocked_for_next_mega_batch','Spatial analysis only; no sovereign mutation.'),
  ('cases','unblocked_for_next_mega_batch','Use cases bounded contracts and RBAC.'),
  ('billing_system','unblocked_for_next_mega_batch','Use financial/payment boundaries and audit gates.')
) as t(system_key, decision, note);
