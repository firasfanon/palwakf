-- Public Schema Phase 3 — Runtime Remediation + Owner-Write RPC Implementation Preflight Gate
-- Date: 2026-05-23
-- Batch: Development 9C
-- Mode: READ ONLY decision/evidence gate.
-- This script does not create RPCs, alter schemas, reroute runtime, or mutate data.

with supplied_sql26_retest as (
  select * from (values
    ('owner_surface_probe', 'core.admin_users', true, 'Visible via schema-safe pg_namespace/pg_class probe.'),
    ('owner_surface_probe', 'platform.platform_permissions', true, 'Visible via schema-safe pg_namespace/pg_class probe.'),
    ('owner_surface_probe', 'platform.platform_systems', true, 'Visible via schema-safe pg_namespace/pg_class probe.'),
    ('owner_surface_probe', 'platform.user_system_permissions', true, 'Visible via schema-safe pg_namespace/pg_class probe.'),
    ('owner_surface_probe', 'platform.user_system_roles', true, 'Visible via schema-safe pg_namespace/pg_class probe.'),
    ('public_wrapper_probe', 'public.v_core_admin_users_compat_v1', true, 'Compatibility wrapper visible.'),
    ('public_wrapper_probe', 'public.v_platform_permissions_compat_v1', true, 'Compatibility wrapper visible.'),
    ('public_wrapper_probe', 'public.v_platform_systems_compat_v1', true, 'Compatibility wrapper visible.'),
    ('public_wrapper_probe', 'public.v_platform_user_system_permissions_compat_v1', true, 'Compatibility wrapper visible.'),
    ('public_wrapper_probe', 'public.v_platform_user_system_roles_compat_v1', true, 'Compatibility wrapper visible.')
  ) as t(section, check_key, passed, note)
), blockers as (
  select * from (values
    ('owner_write_rpcs_installed', false, 'Proposed RPCs remain not installed; expected for Development 9/9B/9C design-only state.'),
    ('role_rls_browser_console_evidence_supplied', false, 'Fresh role/RLS/browser-console evidence was not supplied.'),
    ('runtime_read_adapter_remediation_executed', false, 'No Flutter/Core/Admin/Auth runtime adapter remediation executed in 9C.'),
    ('owner_write_rpc_implementation_authorized', false, 'Implementation requires explicit body review: RLS/audit/search_path/rollback/self-lockout guards.'),
    ('production_approved', false, 'Production remains blocked.')
  ) as t(check_key, passed, note)
), sovereign_boundary as (
  select * from (values
    ('no_waqf_assets_mutation', true, 'Read-only decision gate only; no waqf_assets/waqf/awqaf_system DDL or DML.'),
    ('no_destructive_sql', true, 'No DROP/DELETE/TRUNCATE/ALTER/rename/archive/exact public table replacement.'),
    ('no_auth_users_migration', true, 'auth.users remains Supabase Auth identity source and is not migrated.'),
    ('no_flutter_service_role', true, 'No service_role use inside Flutter is authorized.')
  ) as t(check_key, passed, note)
)
select 'sql26_retest_accepted' as section, check_key, passed, note
from supplied_sql26_retest
union all
select 'preflight_blocker', check_key, passed, note
from blockers
union all
select 'sovereign_boundary', check_key, passed, note
from sovereign_boundary
order by section, check_key;
