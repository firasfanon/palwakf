# RBAC Identity Source of Truth Decision

## Problem

The platform has multiple identity/admin-related surfaces, including references to:

```text
core.admin_users
platform_access.admin_users
auth.users
```

This may create ambiguity unless a source-of-truth policy is documented.

## Recommended Policy

`platform_access` should be treated as the primary authority for platform administrative access, permissions, roles, scopes, and system membership.

## Source of Truth

| Area | Recommended Authority |
|---|---|
| Authentication identity | `auth.users` |
| Platform administrative identity | `platform_access.admin_users` |
| Permissions | `platform_access` |
| Role/scope assignments | `platform_access` |
| Historical/core compatibility | compatibility views or controlled migration from `core.admin_users` |

## Rules

1. Flutter must not infer admin access from unrelated public tables.
2. RBAC checks must resolve through platform access wrappers/RPCs.
3. Unit scope must be explicit.
4. Any duplicate admin identity table must be mapped to the official authority through a documented compatibility layer.
5. No direct permission bypass through frontend code.

## Migration Approach

### Phase 1 — Documentation

- Inventory both identity surfaces.
- Document active application dependencies.
- Identify fields needed from each surface.

### Phase 2 — Compatibility

- Provide compatibility views for legacy code.
- Keep reads stable.

### Phase 3 — Consolidation

- Route new features to `platform_access`.
- Deprecate direct dependency on legacy identity surfaces.

## Acceptance Criteria

- One official identity authority is named.
- Compatibility surfaces are documented.
- New features use `platform_access`.
- Role and unit scope evidence can be tested in browser.
