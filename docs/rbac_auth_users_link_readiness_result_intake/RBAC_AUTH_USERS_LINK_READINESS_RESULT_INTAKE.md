
# RBAC Auth Users Link Readiness Result Intake

## User-Supplied Read-only Result

| section | platform_access_admin_users_count | auth_users_count | matched_by_id_count | orphan_admin_users_count | email_mismatch_count | recommended_decision | ddl_dml_authorized | read_only |
|---|---:|---:|---:|---:|---:|---|---|---|
| rbac_auth_users_link_summary | 86 | 86 | 86 | 0 | 0 | RBAC_AUTH_USERS_PHYSICAL_FK_READY_FOR_AUTHORIZED_APPLY_DESIGN | false | true |

## Interpretation

The evidence confirms:

```text
platform_access.admin_users rows = 86
auth.users rows = 86
matched by id = 86
orphans = 0
email mismatches = 0
```

Therefore:

```text
platform_access.admin_users.id
```

is data-compatible with:

```text
auth.users.id
```

for a future physical FK design.

## Decision

```text
RBAC_AUTH_USERS_PHYSICAL_FK_READY_FOR_AUTHORIZED_APPLY_DESIGN
```

## Important Boundary

This is **not** FK application approval.

The supplied result explicitly says:

```text
ddl_dml_authorized = false
read_only = true
```

Therefore, no FK should be created until a separate authorized apply batch is opened.
