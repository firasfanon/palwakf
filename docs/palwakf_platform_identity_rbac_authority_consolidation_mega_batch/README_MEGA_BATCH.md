
# PalWakf Platform Identity RBAC Authority Consolidation Mega Batch

## Authorization

User authorized:

```text
PALWAKF_PLATFORM_IDENTITY_RBAC_AUTHORITY_CONSOLIDATION_MEGA_BATCH
```

Included:

- FK between `platform_access.admin_users.id` and `auth.users.id`
- read-only verification after execution
- rollback SQL
- smoke/tests/docs updates
- no service_role in Flutter
- no automatic production approval

## Evidence Basis

Previously accepted read-only evidence:

| Metric | Value |
|---|---:|
| `platform_access.admin_users` | 86 |
| `auth.users` | 86 |
| matched by ID | 86 |
| orphan admin users | 0 |
| email mismatches | 0 |

Decision:

```text
RBAC_AUTH_USERS_PHYSICAL_FK_READY_FOR_AUTHORIZED_APPLY_DESIGN
```

## Operator Order

1. Run preflight:
   `sql_apply/.../00_PRE_APPLY_GUARD_READ_ONLY.sql`

2. Run apply:
   `sql_apply/.../01_AUTHORIZED_APPLY_platform_access_admin_users_auth_users_fk.sql`

3. Run post-apply verification:
   `sql_verification/.../01_POST_APPLY_VERIFY_RBAC_AUTH_USERS_FK.sql`

4. Run smoke:
   `flutter analyze`
   `flutter test test/core/contracts/cms_payload_contracts_test.dart`
   `dart run tools/smoke/palwakf_smoke_suite.dart`

5. Browser regression:
   `/admin/platform/technical-services`
   `/admin/media-center/news`

## Rollback

Rollback script:

```text
sql_rollback/.../01_ROLLBACK_drop_platform_access_admin_users_auth_users_fk.sql
```

Do not run rollback unless apply causes a verified blocker.

## Production Boundary

This Mega Batch does not imply production approval. It only prepares and authorizes the database FK operation as a controlled apply candidate.
