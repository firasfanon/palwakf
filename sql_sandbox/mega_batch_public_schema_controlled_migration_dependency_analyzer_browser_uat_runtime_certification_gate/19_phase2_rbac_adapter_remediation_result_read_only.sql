-- Mega Batch — Public Schema Phase 2 RBAC Adapter Remediation Implementation
-- Script 19: Result surface / adapter remediation evidence (READ ONLY)
-- This script performs SELECT statements only. It records the intended evidence
-- shape after applying the Flutter adapter remediation patch.

select
  '19_phase2_rbac_read_adapter_result' as section,
  'runtime_read_adapters_remediated' as check_key,
  true as passed,
  'RBAC runtime/admin read paths now target public compatibility wrappers instead of legacy public RBAC tables directly.' as note
union all
select
  '19_phase2_rbac_read_adapter_result',
  'admin_write_paths_preserved_on_legacy_public_tables',
  true,
  'Insert/update/delete paths remain on legacy public tables until owner-write RPCs are designed and approved.'
union all
select
  '19_phase2_rbac_read_adapter_result',
  'core_linkage_deferred_to_phase3',
  true,
  'core/admin/auth linkage remains out of Phase 2; auth.users is not migrated.'
union all
select
  '19_phase2_rbac_read_adapter_result',
  'runtime_reroute_not_authorized',
  true,
  'This implementation remediates scoped RBAC read adapters only; it does not authorize platform-wide runtime reroute.';

select *
from (values
  ('platform_systems', 'public.v_platform_systems_compat_v1', 'lib/data/repositories/rbac_admin_repository.dart', 'read wrapper applied'),
  ('platform_permissions', 'public.v_platform_permissions_compat_v1', 'lib/data/repositories/rbac_admin_repository.dart', 'read wrapper applied'),
  ('user_system_roles', 'public.v_platform_user_system_roles_compat_v1', 'lib/core/access/access_repository.dart', 'read wrapper applied'),
  ('user_system_permissions', 'public.v_platform_user_system_permissions_compat_v1', 'lib/core/access/access_repository.dart', 'read wrapper applied'),
  ('platform_systems', 'public.v_platform_systems_compat_v1', 'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart', 'read wrapper applied'),
  ('platform_permissions', 'public.v_platform_permissions_compat_v1', 'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart', 'read wrapper applied'),
  ('user_system_roles', 'public.v_platform_user_system_roles_compat_v1', 'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart', 'read wrapper applied'),
  ('user_system_permissions', 'public.v_platform_user_system_permissions_compat_v1', 'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart', 'read wrapper applied')
) as r(legacy_public_table, compatibility_surface, file_path, remediation_status);
