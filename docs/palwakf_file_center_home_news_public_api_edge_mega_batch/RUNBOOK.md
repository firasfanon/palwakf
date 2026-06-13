
# Operator Runbook

## 1. Diagnostics

```text
sql_diagnostics/palwakf_file_center_home_news_public_api_edge_mega_batch/01_READ_ONLY_preflight.sql
```

## 2. Apply SQL workflow

```text
sql_apply/palwakf_file_center_home_news_public_api_edge_mega_batch/01_APPLY_file_center_explicit_assignment_public_api_edge_workflow.sql
```

## 3. Verify

```text
sql_verification/palwakf_file_center_home_news_public_api_edge_mega_batch/01_VERIFY_file_center_home_news_public_api_edge.sql
```

## 4. Flutter checks

```bash
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
dart run tools/smoke/palwakf_smoke_suite.dart
flutter run -d chrome
```

## 5. Browser retest

```text
/home
/home/news
/home/announcements
/home/activities
/admin/documents
```
