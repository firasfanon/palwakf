
# PALWAKF Platform Identity RBAC Authority Consolidation — Apply Result Closure

## User-Supplied Apply Evidence

### Existing FK Constraint Check

| constraint_name | constraint_definition |
|---|---|
| `admin_users_governorate_fkey` | `FOREIGN KEY (governorate) REFERENCES core.governorates(code) ON DELETE SET NULL` |
| `admin_users_id_fkey` | `FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE` |
| `admin_users_unit_id_fkey` | `FOREIGN KEY (unit_id) REFERENCES core.org_units(id)` |
| `platform_access_admin_users_id_auth_users_id_fk` | `FOREIGN KEY (id) REFERENCES auth.users(id)` |

### Apply Result

| field | value |
|---|---|
| constraint_name | `platform_access_admin_users_id_auth_users_id_fk` |
| table_schema | `platform_access` |
| table_name | `admin_users` |
| validated | `true` |
| constraint_definition | `FOREIGN KEY (id) REFERENCES auth.users(id)` |
| ddl_authorized_by_user | `true` |
| production_approved | `false` |

### Post-Apply Data Integrity

| metric | value |
|---|---:|
| platform_access_admin_users_count | 86 |
| auth_users_count | 86 |
| matched_by_id_count | 86 |
| orphan_admin_users_count | 0 |
| email_mismatch_count | 0 |
| decision | `POST_APPLY_DATA_INTEGRITY_PASSED` |

## Technical Interpretation

The apply succeeded and the new FK is validated.

However, the existing FK check shows that an older FK already existed:

```text
admin_users_id_fkey
FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE
```

The new FK also references the same parent and column:

```text
platform_access_admin_users_id_auth_users_id_fk
FOREIGN KEY (id) REFERENCES auth.users(id)
```

Therefore, the RBAC auth link is now proven, but there is a redundant FK constraint on the same column pair.

## Decision

```text
PALWAKF_PLATFORM_IDENTITY_RBAC_AUTHORITY_CONSOLIDATION_APPLIED_AND_VERIFIED_DUPLICATE_FK_DETECTED
```

## Accepted

- DDL authorization was present.
- FK apply result returned a validated constraint.
- Post-apply data integrity passed.
- `platform_access.admin_users` and `auth.users` are fully matched by ID.
- No orphan rows.
- No email mismatches.
- Production approval remains false.

## Governance Note

Because `admin_users_id_fkey` already existed, a future cleanup may drop the redundant newly-created constraint:

```text
platform_access_admin_users_id_auth_users_id_fk
```

while preserving:

```text
admin_users_id_fkey
```

This cleanup is not required for data integrity, but it is recommended for schema cleanliness to avoid duplicate enforcement overhead and confusion.

## Current Runtime Decision

```text
RBAC_AUTH_USERS_LINK_VERIFIED
```

## Current Schema Hygiene Decision

```text
RBAC_DUPLICATE_AUTH_USERS_FK_CLEANUP_RECOMMENDED_NOT_REQUIRED_FOR_RUNTIME
```
