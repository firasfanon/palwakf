
# Post-hotfix Verification

Run:

```bash
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
dart run tools/smoke/palwakf_smoke_suite.dart
flutter run -d chrome
```

Open:

```text
/home/news
/admin/documents
```

Expected:

```text
/home/news: no RenderFlex unbounded height assertion
/admin/documents: no PGRST106 red panel for platform_services/media_center direct schema reads
```

If wrapper SQL is not applied yet:

```text
/admin/documents may show document-intelligence rows only
service/media metrics may remain zero
```

That is acceptable until public wrapper views are applied with explicit SQL authorization.
