
# RBAC Identity Foreign Key Evidence Intake

## User Supplied Result

The FK diagnostic query returned:

```text
Success. No rows returned
```

## Query Intent

The query searched for foreign keys involving:

```text
platform_access.admin_users
core.admin_users
public.admin_users
```

and specifically looked for a physical relationship such as:

```text
platform_access.admin_users.id -> auth.users.id
```

## Evidence Interpretation

No FK row was returned. Therefore, the evidence does **not** prove a physical FK from `platform_access.admin_users` to `auth.users`.

## Accepted Facts

Based on previously supplied evidence:

- `platform_access.admin_users` exists.
- `platform_access.platform_permissions` exists.
- `platform_access.platform_role_permission_map` exists.
- `platform_access.user_permissions` exists.
- `platform_access.user_scope_assignments` exists.
- `platform_access.user_scope_assignment_units` exists.
- `platform_access.user_system_roles` exists.
- `platform_access.user_system_permissions` exists.
- `public.admin_users` exists with nullable columns, consistent with compatibility/read surface behavior.
- `core.admin_users` and `platform_access.admin_users` are structurally similar.

## Decision

```text
RBAC_PLATFORM_ACCESS_STRUCTURAL_AUTHORITY_ACCEPTED_AUTH_USERS_PHYSICAL_FK_ABSENT
```

## Required Follow-up

A future RBAC remediation/design batch should choose one of the following:

1. Add an approved FK from `platform_access.admin_users.id` to `auth.users.id`, if operationally safe.
2. Keep no physical FK but document the logical identity contract and enforce it through RPC/RLS checks.
3. Create a compatibility view mapping legacy/core/public identity surfaces to `platform_access`.
4. Run dependency and data consistency checks before any DDL.

No FK/DDL change is authorized by this evidence intake.
