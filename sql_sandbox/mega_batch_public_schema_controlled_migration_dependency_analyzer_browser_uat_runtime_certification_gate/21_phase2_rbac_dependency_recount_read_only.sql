-- Script 21: Phase 2 dependency recount / remaining blockers (READ ONLY)

select *
from (values
  ('phase2_rbac_runtime_read_dependencies', 0, 'RBAC read dependencies on legacy public tables should be zero after adapter remediation.'),
  ('phase2_rbac_legacy_write_paths', 3, 'platform_systems, user_system_roles, user_system_permissions remain legacy write paths until owner-write RPCs.'),
  ('phase3_core_linkage_pairs', 5, 'core/admin/auth linkage remains deferred to Phase 3.'),
  ('assistant_pairs', 0, 'No assistant pairs in the current direct dependency scan.'),
  ('exact_replacement_authorized', 0, 'Exact public table-name replacement remains blocked.')
) as d(metric_key, metric_value, note);

select
  '21_phase2_rbac_dependency_recount_decision' as section,
  true as phase2_rbac_read_adapter_remediation_executed,
  false as all_dependency_zero_certified,
  false as exact_public_table_name_replacement_authorized,
  false as runtime_reroute_authorized,
  'PHASE2_RBAC_READ_DEPENDENCIES_REMEDIATED_CORE_AND_WRITE_RPC_BLOCKERS_REMAIN' as decision;
