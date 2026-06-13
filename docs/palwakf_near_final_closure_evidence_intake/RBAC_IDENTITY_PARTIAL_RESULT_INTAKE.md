
# RBAC Identity Evidence Pasted Results

## identity_columns

The user pasted identity column evidence for:

```text
core.admin_users
platform_access.admin_users
public.admin_users
```

Observed:

- `core.admin_users` and `platform_access.admin_users` have matching non-null structural columns for:
  - `id`
  - `email`
  - `name`
  - `role`
  - `department`
  - `is_superuser`
- `public.admin_users` exists with all columns nullable, which is consistent with a compatibility/read surface rather than a strict source-of-truth table.

## platform_access role/permission/scope tables

The user pasted:

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

Interpretation:

`platform_access` contains the required role/permission/scope surfaces to act as the preferred RBAC authority for new platform development.

## preliminary decision row

The user pasted:

```text
platform_access.admin_users should be treated as the preferred platform administrative identity authority if it is linked to auth.users and role/permission/scope tables are present.
ddl_dml_authorized = false
read_only = true
```

## Remaining RBAC evidence gap

The current pasted results do not include the `identity_foreign_keys` section.

Required final proof:

```text
platform_access.admin_users.id -> auth.users.id
```

or equivalent FK/contract evidence.

## Current RBAC Decision

```text
RBAC_PLATFORM_ACCESS_AUTHORITY_STRUCTURAL_EVIDENCE_ACCEPTED_AUTH_USERS_FK_PENDING
```
