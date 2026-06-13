
# DOCUMENT_CENTER_PUBLIC_WRAPPERS_APPLY_AND_RUNTIME_RETEST

## Purpose

Apply safe public wrappers for `/admin/documents` so Flutter does not directly query private owner schemas:

```text
platform_services
media_center
```

## Apply Order

Run in Supabase SQL Editor:

```text
sql_apply/document_center_public_wrappers_apply_and_runtime_retest/01_APPLY_document_center_public_wrappers.sql
```

Then run:

```text
sql_verification/document_center_public_wrappers_apply_and_runtime_retest/01_VERIFY_document_center_public_wrappers.sql
```

## Runtime Retest

Run:

```bash
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
dart run tools/smoke/palwakf_smoke_suite.dart
flutter run -d chrome
```

Open:

```text
/admin/documents
/home/news
```

Expected:

```text
/admin/documents:
- no PGRST106 for platform_services/media_center
- service/media counters may reflect actual wrapper rows
- document-intelligence remains visible

/home/news:
- no RenderFlex unbounded height assertion
```

## Protected Technical Smoke

If you want SMK-08 to be 200 instead of SKIP:

```powershell
$env:SUPABASE_ACCESS_TOKEN="<admin user JWT>"
dart run tools/smoke/palwakf_smoke_suite.dart
```

## Rollback

Only if wrappers cause a verified runtime blocker:

```text
sql_rollback/document_center_public_wrappers_apply_and_runtime_retest/01_ROLLBACK_document_center_public_wrappers.sql
```
