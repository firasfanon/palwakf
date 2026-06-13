
# Post-hotfix Verification

Run:

```bash
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
dart run tools/smoke/palwakf_smoke_suite.dart
flutter run -d chrome
```

Then open:

```text
/home/news
/admin/documents
```

Expected:

```text
No RenderFlex unbounded constraint in _NewsHeroCard
/admin/documents loads with available surfaces or non-fatal surface errors
```

For authenticated technical smoke:

```bash
$env:SUPABASE_ACCESS_TOKEN="<admin user JWT>"
dart run tools/smoke/palwakf_smoke_suite.dart
```
