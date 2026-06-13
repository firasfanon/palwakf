
# RBAC Identity Source-of-Truth SQL Result Intake Template

## SQL File

```text
sql_diagnostics/rbac_identity_source_of_truth/03_READ_ONLY_source_of_truth_evidence_gate.sql
```

## Execution Mode

```text
READ ONLY
```

## Required Pasted Results

Paste the result tables for:

1. `identity_surfaces`
2. `identity_columns`
3. `identity_foreign_keys`
4. `platform_access_role_permission_scope_tables`
5. `platform_access_role_permission_scope_routines`
6. `rbac_source_of_truth_preliminary_decision`

## Acceptance Rules

| Evidence | Expected |
|---|---|
| `platform_access.admin_users` exists | Required for preferred authority |
| FK from `platform_access.admin_users` to `auth.users` | Strong evidence |
| Role/permission/scope tables under `platform_access` | Required for RBAC authority |
| `core.admin_users` exists too | Allowed only as legacy/compatibility or historical identity surface |
| public identity surface | Must not become source of truth unless explicitly justified |

## Possible Decisions

| Condition | Decision |
|---|---|
| `platform_access.admin_users` + FK to `auth.users` + permissions/roles/scopes present | RBAC_IDENTITY_SOURCE_OF_TRUTH_PLATFORM_ACCESS_ACCEPTED |
| `platform_access.admin_users` missing | RBAC_IDENTITY_SOURCE_OF_TRUTH_BLOCKED |
| FK to auth.users missing | RBAC_IDENTITY_AUTH_LINK_REVIEW_REQUIRED |
| Duplicate active identity surfaces unresolved | RBAC_IDENTITY_COMPATIBILITY_MAPPING_REQUIRED |

## Evidence Paste Template

```text
identity_surfaces:
identity_columns:
identity_foreign_keys:
platform_access_role_permission_scope_tables:
platform_access_role_permission_scope_routines:
decision:
notes:
```
