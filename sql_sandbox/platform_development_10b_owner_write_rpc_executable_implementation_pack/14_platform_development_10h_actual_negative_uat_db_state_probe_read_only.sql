-- Platform Development 10H
-- Actual Negative UAT Evidence Bundle DB State Probe (read-only)
-- Purpose: verify preconditions after running the Dart negative-UAT runner.
-- This script does not create functions, grants, or mutate data.

with expected_functions(signature) as (
  values
    ('public.rpc_core_admin_user_profile_update_v1(uuid,jsonb)'),
    ('public.rpc_core_admin_user_link_v1(uuid,jsonb)'),
    ('public.rpc_core_admin_user_deactivate_v1(uuid,jsonb)'),
    ('public.rpc_platform_system_register_v1(text,jsonb)'),
    ('public.rpc_platform_user_role_upsert_v1(uuid,text,text,jsonb)'),
    ('public.rpc_platform_user_role_delete_v1(uuid,text,jsonb)'),
    ('public.rpc_platform_user_permission_grant_v1(uuid,text,text,jsonb)'),
    ('public.rpc_platform_user_permission_revoke_v1(uuid,text,text,jsonb)')
), fn as (
  select
    n.nspname || '.' || p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ')' as signature,
    p.oid
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
    and p.proname in (
      'rpc_core_admin_user_profile_update_v1',
      'rpc_core_admin_user_link_v1',
      'rpc_core_admin_user_deactivate_v1',
      'rpc_platform_system_register_v1',
      'rpc_platform_user_role_upsert_v1',
      'rpc_platform_user_role_delete_v1',
      'rpc_platform_user_permission_grant_v1',
      'rpc_platform_user_permission_revoke_v1'
    )
), checks as (
  select
    'function_presence'::text as section,
    e.signature as check_key,
    (f.oid is not null) as passed,
    'Owner-write RPC must remain installed before actual negative UAT.'::text as note
  from expected_functions e
  left join fn f using(signature)
  union all
  select
    'anon_blocked'::text,
    e.signature,
    (f.oid is not null and not has_function_privilege('anon', f.oid, 'EXECUTE')),
    'anon must not execute owner-write RPCs.'
  from expected_functions e
  left join fn f using(signature)
  union all
  select
    'authenticated_execute'::text,
    e.signature,
    (f.oid is not null and has_function_privilege('authenticated', f.oid, 'EXECUTE')),
    'authenticated can execute; SQL-level guards decide actor authority.'
  from expected_functions e
  left join fn f using(signature)
  union all
  select
    'evidence_runner'::text,
    'actual_negative_uat_runner_required'::text,
    false,
    'Run tools/platform_development_10h/owner_write_rpc_negative_uat_runner.dart and attach generated JSON/MD evidence.'
  union all
  select
    'production_gate'::text,
    'production_approved'::text,
    false,
    'Production remains blocked until generated evidence shows all actor cases denied and admin/write console is clean.'
  union all
  select
    'sovereign_boundary'::text,
    'no_auth_users_migration'::text,
    true,
    'This probe does not migrate or mutate auth.users.'
  union all
  select
    'sovereign_boundary'::text,
    'no_waqf_assets_mutation'::text,
    true,
    'This probe contains no waqf_assets/waqf/awqaf_system DDL or DML.'
)
select * from checks order by section, check_key;
