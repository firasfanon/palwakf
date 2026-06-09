-- 18_phase2_rbac_planning_sovereign_boundary_read_only.sql
-- Read-only sovereign and scope boundary for route-console closure + Phase 2 RBAC planning.

select
  '18_sovereign_boundary' as section,
  'no_waq_assets_mutation_in_this_script' as check_key,
  true as passed,
  'SELECT-only; no waqf_assets, waqf, or awqaf_system DML.' as note
union all
select
  '18_sovereign_boundary',
  'no_destructive_sql_in_this_script',
  true,
  'No DROP/DELETE/ARCHIVE/RENAME/ALTER statements are included.'
union all
select
  '18_scope_boundary',
  'route_console_closure_does_not_accept_missing_evidence',
  true,
  'Route Console evidence remains pending unless the user supplies clean per-route browser console proof.'
union all
select
  '18_scope_boundary',
  'phase2_rbac_planning_only',
  true,
  'This pack inventories and plans RBAC remediation but does not change runtime data sources.'
union all
select
  '18_scope_boundary',
  'exact_replacement_not_authorized',
  true,
  'Exact public table-name replacement remains blocked.'
union all
select
  '18_scope_boundary',
  'production_not_approved',
  true,
  'No production approval is granted by this batch.';
