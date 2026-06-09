-- Development 9D — Phase 3 Runtime Read Adapter Remediation Static UAT
-- READ ONLY. No DDL. No DML. No RPC creation. No runtime write reroute.
-- Purpose: record that Flutter read paths are remediated to the public core/admin
-- compatibility wrapper while direct owner-write paths remain blocked pending RPC review.

with evidence(section, check_key, passed, note) as (
  values
    ('runtime_read_adapter', 'lib/core/access/access_repository.dart', true,
      'Access bootstrap reads admin profile through public.v_core_admin_users_compat_v1.'),
    ('runtime_read_adapter', 'lib/data/repositories/admin_users_repository.dart', true,
      'Admin users list fallback reads through public.v_core_admin_users_compat_v1; write paths remain blocked.'),
    ('runtime_read_adapter', 'lib/data/repositories/auth_repository.dart', true,
      'Login username resolution and profile read use public.v_core_admin_users_compat_v1; updateProfile remains owner-write blocker.'),
    ('runtime_read_adapter', 'lib/features/tasks_system/data/repositories/admin_users_repository.dart', true,
      'Tasks admin users list reads through public.v_core_admin_users_compat_v1; write paths remain blocked.'),
    ('runtime_read_adapter', 'lib/features/tasks_system/data/repositories/auth_repository.dart', true,
      'Tasks auth profile read uses public.v_core_admin_users_compat_v1.'),
    ('owner_write_blocker', 'owner_write_rpcs_installed', false,
      'Owner-write RPCs are not installed by Development 9D.'),
    ('owner_write_blocker', 'flutter_write_reroute_authorized', false,
      'No Flutter write reroute is authorized; direct write paths are documented blockers until RPC review closes.'),
    ('evidence_blocker', 'role_rls_browser_console_evidence_supplied', false,
      'Fresh Role/RLS/Browser Console evidence is still required before production or write reroute.'),
    ('sovereign_boundary', 'no_auth_users_migration', true,
      'auth.users remains Supabase Auth identity source and is not migrated.'),
    ('sovereign_boundary', 'no_destructive_sql', true,
      'This read-only UAT contains no DROP/DELETE/TRUNCATE/ALTER/rename/archive/exact public table replacement.'),
    ('sovereign_boundary', 'no_waqf_assets_mutation', true,
      'No waqf_assets/waqf/awqaf_system DDL or DML is included.')
)
select * from evidence;
