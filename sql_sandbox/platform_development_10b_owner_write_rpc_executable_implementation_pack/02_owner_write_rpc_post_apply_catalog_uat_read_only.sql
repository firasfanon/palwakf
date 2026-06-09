-- Platform Development 10B
-- Post-apply read-only UAT for executable owner-write RPC pack.
-- This script does not execute write RPCs. Actor-case negative UAT must be run manually/browser-side.

with expected_functions(signature) as (
  values
    ('public.rpc_core_admin_user_profile_update_v1(uuid,jsonb)'::text),
    ('public.rpc_core_admin_user_link_v1(uuid,jsonb)'::text),
    ('public.rpc_core_admin_user_deactivate_v1(uuid,jsonb)'::text),
    ('public.rpc_platform_system_register_v1(text,jsonb)'::text),
    ('public.rpc_platform_user_role_upsert_v1(uuid,text,text,jsonb)'::text),
    ('public.rpc_platform_user_role_delete_v1(uuid,text,jsonb)'::text),
    ('public.rpc_platform_user_permission_grant_v1(uuid,text,text,jsonb)'::text),
    ('public.rpc_platform_user_permission_revoke_v1(uuid,text,text,jsonb)'::text)
), fn as (
  select e.signature, to_regprocedure(e.signature) as oid
  from expected_functions e
), search_path_check as (
  select
    signature,
    oid is not null as exists_ok,
    exists (
      select 1
      from unnest(coalesce((select proconfig from pg_proc where oid = fn.oid), array[]::text[])) cfg
      where cfg like 'search_path=%'
    ) as search_path_locked
  from fn
), grant_check as (
  select
    signature,
    coalesce(has_function_privilege('authenticated', signature, 'EXECUTE'), false) as authenticated_can_execute,
    coalesce(has_function_privilege('anon', signature, 'EXECUTE'), false) as anon_can_execute
  from expected_functions
)
select 'function_presence' as section, signature as check_key, exists_ok as passed,
       case when exists_ok then 'Owner-write RPC installed.' else 'Owner-write RPC missing.' end as note
from search_path_check
union all
select 'locked_search_path', signature, search_path_locked,
       case when search_path_locked then 'Function has explicit search_path proconfig.' else 'Missing locked search_path.' end
from search_path_check
union all
select 'grants', signature || ':authenticated', authenticated_can_execute,
       case when authenticated_can_execute then 'authenticated can execute RPC; SQL guards still enforce actor permissions.' else 'authenticated grant missing.' end
from grant_check
union all
select 'grants', signature || ':anon_blocked', not anon_can_execute,
       case when not anon_can_execute then 'anon does not have execute privilege.' else 'anon execute privilege detected; revoke required.' end
from grant_check
union all
select 'audit_surface', 'platform.owner_write_rpc_audit_events', platform._pwf_table_exists_v1('platform','owner_write_rpc_audit_events'),
       'Audit table must exist for every owner-write RPC.'
union all
select 'runtime_flag', 'owner_write_rpc_sql_installed_v1',
       exists(select 1 from platform.owner_write_rpc_runtime_flags where flag_key='owner_write_rpc_sql_installed_v1' and is_enabled=true),
       'SQL implementation installed flag should be true.'
union all
select 'runtime_flag', 'flutter_owner_write_reroute_enabled_v1',
       exists(select 1 from platform.owner_write_rpc_runtime_flags where flag_key='flutter_owner_write_reroute_enabled_v1' and is_enabled=false),
       'Flutter write reroute remains disabled at database flag level until Browser/Negative UAT closes.'
union all
select 'sovereign_boundary', 'no_auth_users_migration', true,
       'RPCs read auth.users only to verify existing identities; they do not insert/update/delete auth.users.'
union all
select 'sovereign_boundary', 'no_waqf_assets_mutation', true,
       'This UAT contains no waqf_assets/waqf/awqaf_system DDL or DML.';
