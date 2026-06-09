-- Public Schema Phase 3 — Core/Admin/Auth Linkage Planning Gate
-- Date: 2026-05-23
-- Mode: READ ONLY. This script emits a planning decision only.
-- It does not create, alter, drop, rename, delete, archive, or mutate any data.

with phase3_scope as (
  select * from (values
    ('phase', 'phase_3_core_admin_auth_linkage', 'Core/Admin/Auth linkage is isolated from RBAC and from public table-name replacement.'),
    ('owner', 'core', 'Administrative profile/linkage belongs to core-owned compatibility/RPC surfaces.'),
    ('auth', 'auth.users', 'Supabase auth.users remains the authentication identity source and is never migrated.'),
    ('legacy_public', 'public.admin_users', 'Direct Flutter/PostgREST use remains a blocker until wrappers/RPCs are implemented and retested.'),
    ('blocked', 'exact_public_table_name_replacement', 'Blocked until dependency-zero, owner-write RPCs, role/RLS/browser evidence, and explicit approval.'),
    ('sovereign_boundary', 'waqf_assets', 'No mutation to waqf_assets, waqf schema, or awqaf_system is included or authorized.')
  ) as t(section, key, note)
), phase3_file_pairs as (
  select * from (values
    ('lib/core/access/access_repository.dart', 'public.admin_users', 'read profile for access bootstrap', 'needs core/admin compatibility read wrapper or RPC'),
    ('lib/data/repositories/admin_users_repository.dart', 'public.admin_users', 'admin user list/update/insert paths', 'needs owner-write RPC design before write reroute'),
    ('lib/data/repositories/auth_repository.dart', 'public.admin_users', 'login/profile lookup', 'needs auth-safe core/admin wrapper; auth.users not migrated'),
    ('lib/features/tasks_system/data/repositories/admin_users_repository.dart', 'public.admin_users', 'tasks system admin profile linkage', 'needs shared platform/core admin adapter'),
    ('lib/features/tasks_system/data/repositories/auth_repository.dart', 'public.admin_users', 'tasks system auth/admin lookup', 'needs shared platform/core admin adapter')
  ) as t(file_path, legacy_public_surface, current_usage, required_remediation)
), decision as (
  select * from (values
    ('phase3_planning_gate', 'decision', 'PHASE3_CORE_ADMIN_AUTH_LINKAGE_PLANNING_ONLY_RUNTIME_REMEDIATION_NOT_EXECUTED'),
    ('phase3_planning_gate', 'production_gate', 'NOT_APPROVED'),
    ('phase3_planning_gate', 'runtime_reroute', 'NOT_AUTHORIZED'),
    ('phase3_planning_gate', 'owner_write_rpcs', 'DESIGN_ONLY_NOT_CREATED')
  ) as t(section, key, value)
)
select 'phase3_scope' as result_group, section, key, note as value
from phase3_scope
union all
select 'phase3_file_pairs', file_path, legacy_public_surface, current_usage || ' -> ' || required_remediation
from phase3_file_pairs
union all
select 'phase3_decision', section, key, value
from decision
order by result_group, section, key;
