
# Runbook

## 1. SQL Preflight

```text
sql_diagnostics/media_center_official_first_mobile_publishing_app_mvp/01_READ_ONLY_official_first_mobile_preflight.sql
```

## 2. SQL Apply

```text
sql_apply/media_center_official_first_mobile_publishing_app_mvp/01_APPLY_official_first_mobile_publishing_rpc_workflow.sql
```

## 3. SQL Verification

```text
sql_verification/media_center_official_first_mobile_publishing_app_mvp/01_VERIFY_official_first_mobile_publishing_workflow.sql
```

## 4. Flutter

```bash
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
flutter run -d chrome --dart-define=PWF_ALLOW_LEGACY_PUBLIC_MEDIA_BASE_FALLBACK=false
flutter run -d android --dart-define=PWF_ALLOW_LEGACY_PUBLIC_MEDIA_BASE_FALLBACK=false
```

## 5. Browser / Android Retest

```text
/app/media-center
/app/media-center/publish
/official/media/news/<uuid-after-publish>
```

## Expected behavior

```text
- Save Draft works for authenticated user.
- Submit for Review works for authenticated user.
- Publish Now only works for trusted publisher/admin/editor.
- Published item returns official path.
- Share sends official URL.
- Public detail page only shows published public content.
```
