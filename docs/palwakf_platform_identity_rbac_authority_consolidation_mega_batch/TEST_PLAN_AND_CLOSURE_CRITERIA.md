
# Mega Batch Test Plan

## SQL Verification

Run:

```text
sql_verification/palwakf_platform_identity_rbac_authority_consolidation_mega_batch/01_POST_APPLY_VERIFY_RBAC_AUTH_USERS_FK.sql
```

Expected:

| section | expected |
|---|---|
| rbac_auth_users_fk_presence | one row |
| validated | true |
| constraint_definition | contains `FOREIGN KEY (id) REFERENCES auth.users(id)` |
| orphan_admin_users_count | 0 |
| email_mismatch_count | 0 |

## Runtime Verification

Run:

```bash
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
dart run tools/smoke/palwakf_smoke_suite.dart
```

## Browser Verification

- `/admin/platform/technical-services`
- `/admin/media-center/news`

## Closure Decision

Only after SQL apply result and post-verification are pasted:

```text
PALWAKF_PLATFORM_IDENTITY_RBAC_AUTHORITY_CONSOLIDATION_APPLIED_AND_VERIFIED
```
