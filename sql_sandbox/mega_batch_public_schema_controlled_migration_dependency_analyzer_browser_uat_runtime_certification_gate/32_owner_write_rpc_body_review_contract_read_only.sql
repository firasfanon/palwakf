-- Development 9E — Owner-Write RPC Body Review Contract
-- READ ONLY. No CREATE FUNCTION. No GRANT. No DDL. No DML.
-- Purpose: record required body-review gates before any owner-write RPC can be installed.

with proposed_rpc(rpc_name, owner_surface, argument_contract, write_intent, body_review_status, implementation_authorized, required_guards) as (
  values
    ('public.rpc_core_admin_user_profile_update_v1', 'core.admin_users', 'uuid,jsonb',
      'update admin profile/status fields without touching auth.users', 'review_required', false,
      'auth.uid actor check; admin/scope check; allow-list fields; audit event; locked search_path; no auth.users mutation'),
    ('public.rpc_core_admin_user_link_v1', 'core.admin_users', 'uuid,jsonb',
      'link an existing auth user to an admin profile', 'review_required', false,
      'existing auth identity only; no auth.users insert/update; uniqueness guard; audit event; locked search_path'),
    ('public.rpc_core_admin_user_deactivate_v1', 'core.admin_users', 'uuid,jsonb',
      'deactivate admin profile while preserving audit history', 'review_required', false,
      'deny deleting auth identity; deny self-lockout; audit event; locked search_path'),
    ('public.rpc_platform_system_register_v1', 'platform.platform_systems', 'text,jsonb',
      'upsert governed platform system registration', 'review_required', false,
      'superuser/platform_admin only; validate system_key; audit event; rollback by feature flag'),
    ('public.rpc_platform_user_role_upsert_v1', 'platform.user_system_roles', 'uuid,text,text,jsonb',
      'grant or update role for a user/system pair', 'review_required', false,
      'validate role/system; deny privilege escalation; deny self-lockout; audit event; locked search_path'),
    ('public.rpc_platform_user_role_delete_v1', 'platform.user_system_roles', 'uuid,text,jsonb',
      'remove role for a user/system pair', 'review_required', false,
      'deny self-lockout; preserve inherited permissions; audit event; locked search_path'),
    ('public.rpc_platform_user_permission_grant_v1', 'platform.user_system_permissions', 'uuid,text,text,jsonb',
      'grant explicit permission for user/system pair', 'review_required', false,
      'validate permission catalog; deny privilege escalation; audit event; locked search_path'),
    ('public.rpc_platform_user_permission_revoke_v1', 'platform.user_system_permissions', 'uuid,text,text,jsonb',
      'revoke explicit permission for user/system pair', 'review_required', false,
      'audit event; preserve role-inherited permissions; locked search_path')
), gate(section, check_key, passed, note) as (
  values
    ('review_gate', 'rpc_body_review_completed', false, 'Exact SQL function bodies are not reviewed or approved in 9E.'),
    ('review_gate', 'rls_auth_uid_guards_approved', false, 'Guards must be encoded inside SQL functions, not only Flutter.'),
    ('review_gate', 'audit_contract_approved', false, 'Audit/admin event contract is documented but not implementation-approved.'),
    ('review_gate', 'search_path_locked_approved', false, 'SECURITY DEFINER is blocked unless search_path is locked and owner-reviewed.'),
    ('review_gate', 'rollback_feature_flag_approved', false, 'Write reroute requires one explicit rollback/feature flag.'),
    ('review_gate', 'self_lockout_guard_approved', false, 'Self-lockout and privilege-escalation guards require review evidence.'),
    ('review_gate', 'implementation_authorized', false, 'No CREATE FUNCTION or repository write reroute is authorized by SQL 32.'),
    ('sovereign_boundary', 'no_auth_users_migration', true, 'auth.users remains Supabase Auth identity source and is not migrated.'),
    ('sovereign_boundary', 'no_waqf_assets_mutation', true, 'No waqf_assets/waqf/awqaf_system DDL or DML is included.')
)
select
  'proposed_rpc_body_review' as section,
  rpc_name as check_key,
  implementation_authorized as passed,
  owner_surface || ' | args=' || argument_contract || ' | status=' || body_review_status || ' | guards=' || required_guards as note
from proposed_rpc
union all
select section, check_key, passed, note
from gate;
