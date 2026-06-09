-- Development 9F — Owner-Write RPC Exact Body Draft Gate
-- READ ONLY. No CREATE FUNCTION. No GRANT. No DDL. No DML.
-- Purpose: define exact body-draft requirements before any future implementation batch.

with rpc_draft_requirement(
  rpc_name,
  owner_surface,
  argument_contract,
  actor_guard,
  authorization_guard,
  payload_guard,
  audit_guard,
  rollback_guard,
  implementation_authorized
) as (
  values
    ('public.rpc_core_admin_user_profile_update_v1', 'core.admin_users', 'uuid,jsonb',
      'derive actor from auth.uid()',
      'actor must be superuser/platform_admin or permitted scoped admin',
      'allow-list profile/status fields; reject auth.users fields',
      'emit admin profile update audit event',
      'keep Flutter write reroute behind explicit feature flag',
      false),
    ('public.rpc_core_admin_user_link_v1', 'core.admin_users', 'uuid,jsonb',
      'derive actor from auth.uid()',
      'actor must be superuser/platform_admin',
      'target auth identity must already exist; no auth.users insert/update',
      'emit admin link audit event with target user id',
      'legacy write fallback disabled only after UAT',
      false),
    ('public.rpc_core_admin_user_deactivate_v1', 'core.admin_users', 'uuid,jsonb',
      'derive actor from auth.uid()',
      'actor must be superuser/platform_admin and cannot self-lockout',
      'deny deleting auth identity; deactivate profile only',
      'emit deactivation audit event',
      'rollback through status restore only after approval',
      false),
    ('public.rpc_platform_system_register_v1', 'platform.platform_systems', 'text,jsonb',
      'derive actor from auth.uid()',
      'actor must be superuser/platform_admin',
      'validate system_key and domain-owned schema/RPC contract',
      'emit platform system registration audit event',
      'feature flag controls repository use',
      false),
    ('public.rpc_platform_user_role_upsert_v1', 'platform.user_system_roles', 'uuid,text,text,jsonb',
      'derive actor from auth.uid()',
      'actor must be superuser/platform_admin or scoped admin for target system',
      'validate role_key/system_key and deny privilege escalation/self-lockout',
      'emit role upsert audit event',
      'feature flag controls write reroute',
      false),
    ('public.rpc_platform_user_role_delete_v1', 'platform.user_system_roles', 'uuid,text,jsonb',
      'derive actor from auth.uid()',
      'actor must be superuser/platform_admin or scoped admin and cannot self-lockout',
      'preserve inherited role permissions; prefer soft-safe semantics',
      'emit role delete audit event',
      'rollback by restoring previous role assignment',
      false),
    ('public.rpc_platform_user_permission_grant_v1', 'platform.user_system_permissions', 'uuid,text,text,jsonb',
      'derive actor from auth.uid()',
      'actor must be superuser/platform_admin or scoped admin for target system',
      'validate permission catalog and deny privilege escalation',
      'emit permission grant audit event',
      'feature flag controls write reroute',
      false),
    ('public.rpc_platform_user_permission_revoke_v1', 'platform.user_system_permissions', 'uuid,text,text,jsonb',
      'derive actor from auth.uid()',
      'actor must be superuser/platform_admin or scoped admin for target system',
      'preserve inherited role permissions and deny unsafe revoke',
      'emit permission revoke audit event',
      'rollback by restoring explicit permission only after approval',
      false)
), global_gate(section, check_key, passed, note) as (
  values
    ('exact_body_draft_gate', 'create_function_authorized', false,
      '9F defines exact body-draft requirements only; no executable CREATE FUNCTION is authorized.'),
    ('exact_body_draft_gate', 'grant_authorized', false,
      'No GRANT is authorized until function bodies, RLS/auth guards, audit, search_path, rollback, self-lockout, and Role/RLS/browser evidence close.'),
    ('exact_body_draft_gate', 'locked_search_path_required', true,
      'Any future SECURITY DEFINER body must explicitly lock search_path to trusted schemas only.'),
    ('exact_body_draft_gate', 'audit_required', true,
      'Every future write body must emit a controlled audit/admin event.'),
    ('exact_body_draft_gate', 'negative_uat_required', true,
      'Anonymous, unauthorized, scoped user, unit admin, platform admin, and superuser cases must be tested before reroute.'),
    ('sovereign_boundary', 'no_auth_users_migration', true,
      'auth.users remains Supabase Auth identity source and is not migrated.'),
    ('sovereign_boundary', 'no_waqf_assets_mutation', true,
      'No waqf_assets/waqf/awqaf_system DDL or DML is included.')
)
select
  'rpc_exact_body_draft_requirement' as section,
  rpc_name as check_key,
  implementation_authorized as passed,
  owner_surface
    || ' | args=' || argument_contract
    || ' | actor=' || actor_guard
    || ' | auth=' || authorization_guard
    || ' | payload=' || payload_guard
    || ' | audit=' || audit_guard
    || ' | rollback=' || rollback_guard as note
from rpc_draft_requirement
union all
select section, check_key, passed, note from global_gate;
