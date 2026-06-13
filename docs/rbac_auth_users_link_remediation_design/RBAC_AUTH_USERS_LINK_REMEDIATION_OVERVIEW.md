
# RBAC Auth Users Link Remediation Design

## Background

The final closure evidence showed:

```text
identity_foreign_keys = Success. No rows returned
```

This means no physical FK was proven between:

```text
platform_access.admin_users.id
```

and:

```text
auth.users.id
```

At the same time, `platform_access` has the strongest RBAC structure:

```text
platform_access.admin_users
platform_access.platform_permissions
platform_access.platform_role_permission_map
platform_access.user_permissions
platform_access.user_scope_assignment_units
platform_access.user_scope_assignments
platform_access.user_system_permissions
platform_access.user_system_roles
```

## Objective

Design a safe remediation path to connect administrative identity to Supabase Auth without breaking existing platform behavior.

## Candidate Remediation Paths

| Path | Description | Risk | When to choose |
|---|---|---:|---|
| A | Add physical FK from `platform_access.admin_users.id` to `auth.users.id` | Medium/High | Only if zero orphans and all IDs are Auth user IDs |
| B | Logical auth contract via RPC/RLS functions | Medium | If FK is unsafe but `auth.uid()` can be resolved to admin identity |
| C | Compatibility view mapping auth/core/public/platform_access | Low/Medium | If legacy identity surfaces must remain during migration |
| D | Deferred migration with bridge table | Medium | If many orphans or historical admin rows exist |

## Non-Goals

- No DDL apply in this pack.
- No FK creation in this pack.
- No RLS mutation in this pack.
- No data migration in this pack.
- No production approval in this pack.
