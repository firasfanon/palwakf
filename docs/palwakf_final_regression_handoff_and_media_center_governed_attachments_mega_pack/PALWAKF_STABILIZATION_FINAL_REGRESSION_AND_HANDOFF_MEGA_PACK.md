
# PALWAKF_STABILIZATION_FINAL_REGRESSION_AND_HANDOFF_MEGA_PACK

## Required Commands

Run from project root:

```bash
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
dart run tools/smoke/palwakf_smoke_suite.dart
```

## Expected Results

```text
flutter analyze = No issues found
CMS contract tests = All tests passed
Smoke suite = passed=4 skipped=0 failed=0
```

## SQL Post-Cleanup Verification

Run:

```sql
select
  con.conname as constraint_name,
  pg_get_constraintdef(con.oid) as constraint_definition,
  con.convalidated as validated
from pg_constraint con
join pg_class rel on rel.oid = con.conrelid
join pg_namespace nsp on nsp.oid = rel.relnamespace
where nsp.nspname = 'platform_access'
  and rel.relname = 'admin_users'
  and con.contype = 'f'
order by con.conname;
```

Expected:

- `admin_users_id_fkey` exists.
- `platform_access_admin_users_id_auth_users_id_fk` does not exist.
- No duplicate FK to `auth.users`.

## Browser Regression

Open:

```text
/admin/platform/technical-services
/admin/platform/technical-services/audit
/admin/media-center/news
/admin/settings
```

Expected:

- Technical Services RPC remains `200`.
- Operations Center renders.
- CMS Add News still returns `201/200/204`.
- No `TabController` mismatch.
- No critical `RenderFlex` overflow.

## Closure Decision

If all pass:

```text
PALWAKF_STABILIZATION_FINAL_REGRESSION_ACCEPTED_HANDOFF_READY
```
