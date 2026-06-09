-- Platform Development 10 — Owner-write RPC Body Submission Checklist
-- READ ONLY. No CREATE FUNCTION. No GRANT. No DDL. No DML.
-- Purpose: define the exact SQL-body evidence that must be supplied before implementation.

with rpc_requirements(rpc_name, owner_target, expected_args, required_body_controls, body_supplied, body_approved) as (
  values
    ('public.rpc_core_admin_user_profile_update_v1', 'core.admin_users', 'uuid,jsonb',
      'actor from auth.uid; superuser/platform_admin/scoped admin check; allow-list fields; audit; locked search_path; no auth.users mutation', false, false),
    ('public.rpc_core_admin_user_link_v1', 'core.admin_users', 'uuid,jsonb',
      'existing auth identity only; no auth.users insert/update; uniqueness guard; audit; locked search_path', false, false),
    ('public.rpc_core_admin_user_deactivate_v1', 'core.admin_users', 'uuid,jsonb',
      'deny deleting auth identity; deny self-lockout; deactivate profile only; audit; locked search_path', false, false),
    ('public.rpc_platform_system_register_v1', 'platform.platform_systems', 'text,jsonb',
      'superuser/platform_admin only; validate system_key and ownership contract; audit; rollback feature flag', false, false),
    ('public.rpc_platform_user_role_upsert_v1', 'platform.user_system_roles', 'uuid,text,text,jsonb',
      'validate role/system; scoped authority; deny privilege escalation and self-lockout; audit; locked search_path', false, false),
    ('public.rpc_platform_user_role_delete_v1', 'platform.user_system_roles', 'uuid,text,jsonb',
      'deny self-lockout; preserve inherited permissions; prefer soft-safe semantics; audit; locked search_path', false, false),
    ('public.rpc_platform_user_permission_grant_v1', 'platform.user_system_permissions', 'uuid,text,text,jsonb',
      'validate permission catalog; scoped authority; deny privilege escalation; audit; locked search_path', false, false),
    ('public.rpc_platform_user_permission_revoke_v1', 'platform.user_system_permissions', 'uuid,text,text,jsonb',
      'preserve role-inherited permissions; deny unsafe revoke; audit; locked search_path', false, false)
), global_gate(section, check_key, passed, note) as (
  values
    ('body_submission_gate', 'all_exact_bodies_supplied', false,
      'No executable SQL function bodies were supplied in this batch.'),
    ('body_submission_gate', 'all_exact_bodies_approved', false,
      'No executable SQL function bodies were approved in this batch.'),
    ('body_submission_gate', 'create_function_authorized', false,
      'CREATE FUNCTION is still not authorized.'),
    ('body_submission_gate', 'grant_authorized', false,
      'GRANT is still not authorized.'),
    ('body_submission_gate', 'write_reroute_authorized', false,
      'Flutter write reroute is still not authorized.'),
    ('body_submission_gate', 'negative_uat_evidence_supplied', false,
      'Negative UAT evidence is still not supplied.'),
    ('body_submission_gate', 'production_approved', false,
      'Production remains not approved.')
)
select
  'rpc_body_submission_checklist' as section,
  rpc_name as check_key,
  body_supplied and body_approved as passed,
  'target=' || owner_target || ' | args=' || expected_args || ' | required=' || required_body_controls as note
from rpc_requirements
union all
select section, check_key, passed, note from global_gate;
