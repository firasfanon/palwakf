-- Platform Database Dependency Wave A — Access Helpers Actual Remediation Pack
-- SQL 36: preflight, read-only.
-- Purpose: verify compatibility surfaces required by the fail-closed replacement draft.

with required_surfaces(surface_key, object_name, expected_kind, required_for) as (
  values
    ('core_admin_users_compat', 'public.v_core_admin_users_compat_v1', 'view', 'assistant/core/tasks access-helper replacement bodies'),
    ('platform_permissions_compat', 'public.v_platform_user_system_permissions_compat_v1', 'view', 'permission-based fallback checks'),
    ('platform_roles_compat', 'public.v_platform_user_system_roles_compat_v1', 'view', 'role-based fallback checks')
), surface_status as (
  select rs.*, to_regclass(rs.object_name) is not null as present
  from required_surfaces rs
), required_functions(object_key, function_signature, target_action) as (
  values
    ('assistant_admin_column_discovery_helper', 'assistant._find_admin_users_column(text[])', 'replace public.admin_users discovery with v_core_admin_users_compat_v1 discovery'),
    ('assistant_authenticated_admin_helper', 'assistant.is_authenticated_admin_user()', 'replace legacy admin lookup with compatibility view lookup'),
    ('assistant_manage_access_helper', 'assistant.can_manage_assistant()', 'replace legacy admin lookup with compatibility view lookup'),
    ('core_admin_boolean_helper', 'core.pwf_is_admin_user()', 'replace legacy admin lookup with compatibility view lookup'),
    ('core_unit_edit_access_helper', 'core.fn_can_edit_unit(uuid)', 'replace legacy admin/permission lookup with compatibility view lookup'),
    ('tasks_audit_manage_helper', 'tasks._can_manage_audit_tasks()', 'replace legacy admin/role/permission lookup with compatibility view lookup')
), function_status as (
  select rf.*, to_regprocedure(rf.function_signature) is not null as present
  from required_functions rf
)
select
  'wave_a_access_helpers_preflight' as section,
  surface_key as check_key,
  object_name as object_ref,
  expected_kind,
  required_for,
  present as passed,
  false as execution_authorized,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as read_only
from surface_status
union all
select
  'wave_a_access_helpers_preflight' as section,
  object_key as check_key,
  function_signature as object_ref,
  'function' as expected_kind,
  target_action as required_for,
  present as passed,
  false as execution_authorized,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as read_only
from function_status;
