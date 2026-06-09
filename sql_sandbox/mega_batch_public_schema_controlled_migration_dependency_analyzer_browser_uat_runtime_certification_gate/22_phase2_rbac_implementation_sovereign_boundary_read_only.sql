-- Script 22: Phase 2 implementation sovereign/scope boundary (READ ONLY)

select *
from (values
  ('22_sovereign_boundary', 'no_waq_assets_mutation_in_this_script', true, 'SELECT-only; no waqf_assets, waqf, or awqaf_system DML.'),
  ('22_sovereign_boundary', 'no_destructive_sql_in_this_script', true, 'No DROP/DELETE/ARCHIVE/RENAME/ALTER statements are included.'),
  ('22_scope_boundary', 'core_linkage_not_in_phase2', true, 'Core/admin/auth linkage remains deferred to Phase 3; auth.users is not migrated.'),
  ('22_scope_boundary', 'owner_write_rpcs_not_created', true, 'Admin write paths remain legacy public until owner-write RPC design and UAT.'),
  ('22_scope_boundary', 'exact_replacement_not_authorized', true, 'Exact public table-name replacement remains blocked.'),
  ('22_scope_boundary', 'production_not_approved', true, 'No production approval is granted by this batch.')
) as boundary(section, check_key, passed, note);
