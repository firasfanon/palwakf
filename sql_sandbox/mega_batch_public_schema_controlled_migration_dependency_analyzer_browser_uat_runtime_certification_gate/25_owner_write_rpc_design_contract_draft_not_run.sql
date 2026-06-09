-- Public Schema Phase 3 — Owner-Write RPC Design Contract
-- Date: 2026-05-23
-- Mode: DESIGN ONLY / DRAFT NOT RUN.
-- This file intentionally contains no CREATE FUNCTION, INSERT, UPDATE, DELETE, ALTER, DROP, RENAME, or GRANT statements.
-- It emits the proposed RPC contract matrix so the next implementation batch can be reviewed before any DDL.

with rpc_design as (
  select * from (values
    ('public.rpc_platform_system_register_v1', 'platform.platform_systems', 'upsert governed platform system registration', 'superuser/platform_admin only; validate system_key; audit event; rollback by disabling new RPC route flag'),
    ('public.rpc_platform_user_role_upsert_v1', 'platform.user_system_roles', 'grant or update role for a user/system pair', 'superuser/platform_admin or scoped admin; validate role_key/system_key; audit event'),
    ('public.rpc_platform_user_role_delete_v1', 'platform.user_system_roles', 'remove role for a user/system pair', 'deny self-lockout; audit event; soft-safe delete semantics preferred'),
    ('public.rpc_platform_user_permission_grant_v1', 'platform.user_system_permissions', 'grant explicit permission for user/system pair', 'validate permission catalog; audit event; deny privilege escalation'),
    ('public.rpc_platform_user_permission_revoke_v1', 'platform.user_system_permissions', 'revoke explicit permission for user/system pair', 'audit event; preserve inherited role permissions'),
    ('public.rpc_core_admin_user_profile_update_v1', 'core.admin_users', 'update admin profile/status fields without touching auth.users', 'auth.uid context; core owner only; audit event'),
    ('public.rpc_core_admin_user_link_v1', 'core.admin_users', 'link an existing auth user to an admin profile', 'does not create or migrate auth.users; requires existing auth identity'),
    ('public.rpc_core_admin_user_deactivate_v1', 'core.admin_users', 'deactivate admin profile while preserving audit history', 'deny deleting auth identity; audit event')
  ) as t(proposed_rpc, target_owner_surface, purpose, required_guard)
), implementation_rules as (
  select * from (values
    ('security', 'SECURITY DEFINER may be allowed only after owner/schema review and locked search_path.'),
    ('rls', 'RPCs must enforce auth.uid/admin scope checks explicitly; do not rely on Flutter-side checks.'),
    ('audit', 'Every write RPC must emit an audit event or controlled editorial/administrative event row.'),
    ('rollback', 'Repository adapters must keep legacy-write fallback disabled/enabled by one explicit contract flag until UAT closes.'),
    ('public_role', 'public remains RPC/view wrapper surface only; it must not become sovereign owner.'),
    ('forbidden', 'No service_role inside Flutter and no direct auth.users mutation.')
  ) as t(rule_key, rule_text)
)
select 'proposed_rpc' as section, proposed_rpc as key, target_owner_surface as target, purpose || ' | guard: ' || required_guard as note
from rpc_design
union all
select 'implementation_rule', rule_key, null::text, rule_text
from implementation_rules
order by section, key;
