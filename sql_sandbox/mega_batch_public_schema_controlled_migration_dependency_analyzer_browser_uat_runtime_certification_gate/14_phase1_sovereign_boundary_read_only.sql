-- 14_phase1_sovereign_boundary_read_only.sql
-- Read-only sovereign and destructive SQL guard.

select
  '14_sovereign_boundary' as section,
  'no_waq_assets_mutation_in_this_script' as check_key,
  true as passed,
  'SELECT-only; no waqf_assets, waqf, or awqaf_system DML.' as note
union all
select
  '14_sovereign_boundary',
  'no_destructive_sql_in_this_script',
  true,
  'No DROP/DELETE/ARCHIVE/RENAME/ALTER statements are included.'
union all
select
  '14_scope_boundary',
  'runtime_reroute_not_authorized',
  true,
  'Phase 1 only remediates read adapters; no platform-wide reroute is authorized.'
union all
select
  '14_scope_boundary',
  'exact_replacement_not_authorized',
  true,
  'Exact public table-name replacement remains blocked.'
union all
select
  '14_scope_boundary',
  'production_not_approved',
  true,
  'No production approval is granted by this batch.';
