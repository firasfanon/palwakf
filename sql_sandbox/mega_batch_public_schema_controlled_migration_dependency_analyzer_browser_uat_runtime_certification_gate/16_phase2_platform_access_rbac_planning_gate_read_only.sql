-- 16_phase2_platform_access_rbac_planning_gate_read_only.sql
-- Phase 2 planning gate for platform access/RBAC direct dependencies.
-- Read-only. This does not modify RBAC runtime, RLS, roles, permissions, or data.

with rbac_pairs(pair_no, legacy_public_table, owner_target, file_path, first_line, target_surface, remediation_scope, risk_level) as (
  values
    (1, 'public.user_system_permissions', 'platform.user_system_permissions', 'lib/core/access/access_repository.dart', 60, 'public.v_platform_user_system_permissions_compat_v1 / future RBAC read adapter', 'runtime permission read path', 'high'),
    (2, 'public.user_system_roles', 'platform.user_system_roles', 'lib/core/access/access_repository.dart', 43, 'public.v_platform_user_system_roles_compat_v1 / future RBAC read adapter', 'runtime role read path', 'high'),
    (3, 'public.platform_permissions', 'platform.platform_permissions', 'lib/data/repositories/rbac_admin_repository.dart', 33, 'future public/platform RBAC admin RPC or compatibility wrapper', 'admin permission catalog path', 'high'),
    (4, 'public.platform_systems', 'platform.platform_systems', 'lib/data/repositories/rbac_admin_repository.dart', 11, 'future public/platform systems admin RPC or compatibility wrapper', 'admin system catalog path', 'high'),
    (5, 'public.user_system_permissions', 'platform.user_system_permissions', 'lib/data/repositories/rbac_admin_repository.dart', 50, 'public.v_platform_user_system_permissions_compat_v1 / future RBAC admin adapter', 'admin user permission path', 'high'),
    (6, 'public.user_system_roles', 'platform.user_system_roles', 'lib/data/repositories/rbac_admin_repository.dart', 41, 'public.v_platform_user_system_roles_compat_v1 / future RBAC admin adapter', 'admin user role path', 'high'),
    (7, 'public.platform_permissions', 'platform.platform_permissions', 'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart', 17, 'future public/platform RBAC admin RPC or compatibility wrapper', 'tasks admin permission catalog path', 'high'),
    (8, 'public.platform_systems', 'platform.platform_systems', 'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart', 9, 'future public/platform systems admin RPC or compatibility wrapper', 'tasks admin system catalog path', 'high'),
    (9, 'public.user_system_permissions', 'platform.user_system_permissions', 'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart', 34, 'public.v_platform_user_system_permissions_compat_v1 / future RBAC admin adapter', 'tasks admin user permission path', 'high'),
    (10, 'public.user_system_roles', 'platform.user_system_roles', 'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart', 25, 'public.v_platform_user_system_roles_compat_v1 / future RBAC admin adapter', 'tasks admin user role path', 'high')
)
select
  '16_phase2_platform_access_rbac_dependency_inventory' as section,
  pair_no,
  legacy_public_table,
  owner_target,
  file_path,
  first_line,
  target_surface,
  remediation_scope,
  risk_level,
  'PLANNING_ONLY_NO_RUNTIME_REROUTE' as decision
from rbac_pairs
order by pair_no;

with summary as (
  select
    10::int as platform_access_rbac_pairs,
    4::int as unique_legacy_public_tables,
    3::int as unique_runtime_repository_groups,
    false::boolean as phase2_runtime_remediation_executed,
    false::boolean as dependency_zero_certified,
    false::boolean as route_console_clean_evidence_accepted,
    false::boolean as runtime_reroute_authorized
)
select
  '16_phase2_platform_access_rbac_planning_gate' as section,
  platform_access_rbac_pairs,
  unique_legacy_public_tables,
  unique_runtime_repository_groups,
  phase2_runtime_remediation_executed,
  dependency_zero_certified,
  route_console_clean_evidence_accepted,
  runtime_reroute_authorized,
  'PHASE2_RBAC_PLANNING_ONLY_RUNTIME_REMEDIATION_NOT_EXECUTED' as decision
from summary;
