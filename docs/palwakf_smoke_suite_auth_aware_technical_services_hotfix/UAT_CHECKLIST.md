
# UAT Checklist

## Static

```bash
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
```

Expected:

```text
No issues found
All tests passed
```

## Smoke without admin token

```bash
dart run tools/smoke/palwakf_smoke_suite.dart
```

Expected:

```text
passed=3 skipped=1 failed=0
```

## Smoke with admin token

Set one of:

```text
SUPABASE_ACCESS_TOKEN
PALWAKF_SMOKE_ACCESS_TOKEN
PALWAKF_ADMIN_ACCESS_TOKEN
```

Run:

```bash
dart run tools/smoke/palwakf_smoke_suite.dart
```

Expected:

```text
passed=4 skipped=0 failed=0
```
