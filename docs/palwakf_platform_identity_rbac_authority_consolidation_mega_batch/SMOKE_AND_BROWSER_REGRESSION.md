
# Identity RBAC Authority Smoke and Regression

## After Apply Commands

```bash
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
dart run tools/smoke/palwakf_smoke_suite.dart
```

Expected:

```text
flutter analyze = No issues found
CMS contract tests = All tests passed
Smoke suite = passed=4 skipped=0 failed=0
```

## Browser Regression

Open:

```text
/admin/platform/technical-services
/admin/platform/technical-services/audit
/admin/media-center/news
```

Expected:

- Technical Services RPC remains 200.
- Operations Center still renders.
- CMS Add News still returns 201/200/204.
- No `service_role` is introduced in Flutter.
