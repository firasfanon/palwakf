-- Platform Development 10I
-- SQL/RLS no unsafe mutation probe after actual Negative UAT runner (read-only).
--
-- Edit the two UUIDs only if the runner used different target/superuser ids.
-- No DDL, no DML, no auth.users mutation, no waqf mutation.

with input as (
  select
    'f661a211-4d81-4965-9069-46c2162717de'::uuid as target_admin_user_id,
    '96f6cdc2-67f9-4352-b9f8-775ef509fed8'::uuid as superuser_self_user_id
),
rpc_privileges as (
  select
    p.proname,
    has_function_privilege('anon', p.oid, 'EXECUTE') as anon_can_execute,
    has_function_privilege('authenticated', p.oid, 'EXECUTE') as authenticated_can_execute
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
),
forbidden_systems as (
  select
    'platform.platform_systems_forbidden_negative_keys_absent'::text as check_key,
    count(*) as offending_count
  from platform.platform_systems
  where key::text in (
    'negative_uat_anon_forbidden',
    'negative_uat_unit_admin_forbidden_system'
  )
),
forbidden_target_superuser_role as (
  select
    'target_user_not_granted_superuser_role_by_negative_uat'::text as check_key,
    count(*) as offending_count
  from platform.user_system_roles r, input i
  where r.user_id = i.target_admin_user_id
    and r.system_key::text = 'platformAdmin'
    and r.role::text = 'superuser'
),
superuser_self_guard as (
  select
    'superuser_self_still_active_and_superuser'::text as check_key,
    case
      when exists (
        select 1
        from core.admin_users a, input i
        where a.id = i.superuser_self_user_id
          and coalesce(a.is_active, false) = true
          and coalesce(a.is_superuser, false) = true
      )
      then 0 else 1
    end as offending_count
),
anon_privilege_violation as (
  select
    'anon_execute_privilege_absent_for_all_owner_write_rpcs'::text as check_key,
    count(*) filter (where anon_can_execute) as offending_count
  from rpc_privileges
),
authenticated_privilege_expected as (
  select
    'authenticated_execute_privilege_present_for_all_owner_write_rpcs'::text as check_key,
    case when count(*) = 8 and bool_and(authenticated_can_execute) then 0 else 1 end as offending_count
  from rpc_privileges
),
combined as (
  select * from forbidden_systems
  union all select * from forbidden_target_superuser_role
  union all select * from superuser_self_guard
  union all select * from anon_privilege_violation
  union all select * from authenticated_privilege_expected
)
select
  'sql_rls_no_unsafe_mutation_probe' as section,
  check_key,
  offending_count,
  (offending_count = 0) as passed
from combined
order by check_key;

select
  'sovereign_boundary' as section,
  'no_waq_assets_mutation_in_this_script' as check_key,
  true as passed,
  'Read-only SELECTs only; no waqf/waq_assets/awqaf_system DML.' as note;

select
  'auth_boundary' as section,
  'no_auth_users_mutation_in_this_script' as check_key,
  true as passed,
  'Read-only SELECTs only; no auth.users DML.' as note;
