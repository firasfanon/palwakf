-- Platform Database Dependency Wave A — Access Helpers Actual Remediation Pack
-- SQL 38: post-apply validation, read-only.

with target_functions(object_key, function_signature, legacy_token, expected_token) as (
  values
    ('assistant_admin_column_discovery_helper', 'assistant._find_admin_users_column(text[])', 'public.admin_users', 'v_core_admin_users_compat_v1'),
    ('assistant_authenticated_admin_helper', 'assistant.is_authenticated_admin_user()', 'public.admin_users', 'v_core_admin_users_compat_v1'),
    ('assistant_manage_access_helper', 'assistant.can_manage_assistant()', 'public.admin_users', 'v_core_admin_users_compat_v1'),
    ('core_admin_boolean_helper', 'core.pwf_is_admin_user()', 'public.admin_users', 'v_core_admin_users_compat_v1'),
    ('core_unit_edit_access_helper', 'core.fn_can_edit_unit(uuid)', 'public.admin_users', 'v_core_admin_users_compat_v1'),
    ('tasks_audit_manage_helper', 'tasks._can_manage_audit_tasks()', 'public.admin_users', 'v_core_admin_users_compat_v1')
), defs as (
  select tf.*, p.oid, case when p.oid is not null then pg_get_functiondef(p.oid) else null end as body
  from target_functions tf
  left join pg_proc p on p.oid = to_regprocedure(tf.function_signature)
)
select
  'wave_a_access_helpers_post_apply_validation' as section,
  object_key,
  function_signature,
  oid is not null as function_present,
  coalesce(body ilike '%' || legacy_token || '%', false) = false as legacy_direct_token_removed,
  coalesce(body ilike '%' || expected_token || '%', false) as compatibility_surface_used,
  case
    when oid is null then 'MISSING_FUNCTION'
    when body ilike '%' || legacy_token || '%' then 'FAILED_LEGACY_DIRECT_TOKEN_STILL_PRESENT'
    when body not ilike '%' || expected_token || '%' then 'FAILED_EXPECTED_COMPAT_SURFACE_NOT_FOUND'
    else 'PASSED_BODY_REVIEW_STATIC_CHECK'
  end as decision,
  false as dependency_zero_certified,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as archive_delete_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as read_only
from defs;
