
# DOCUMENT_LIFECYCLE_POLICY_REGISTRY_APPLY_AND_ATTACHMENT_CLASSIFICATION

## Nature

This is a controlled database apply package for document lifecycle governance.

## What it applies

```text
platform_documents.document_types
document type policy seed rows
lifecycle columns on platform_services.service_request_attachments
classification/backfill for existing service attachments
lifecycle-aware public wrappers for /admin/documents
```

## What it does not do

```text
No file deletion
No storage.objects mutation
No media_center destructive mutation
No RLS mutation
No service_role in Flutter
No production approval
```

## Operator Order

1. Run:

```text
sql_apply/document_lifecycle_policy_registry_apply_and_attachment_classification/01_APPLY_document_lifecycle_policy_registry_and_classification.sql
```

2. Run:

```text
sql_verification/document_lifecycle_policy_registry_apply_and_attachment_classification/01_VERIFY_document_lifecycle_policy_registry_and_classification.sql
```

3. Runtime retest:

```bash
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
dart run tools/smoke/palwakf_smoke_suite.dart
flutter run -d chrome
```

4. Open:

```text
/admin/documents
```

Expected:

```text
No PGRST106
Lifecycle chips remain visible
Service/media wrappers remain readable
```

## Rollback

Only if a verified blocker appears:

```text
sql_rollback/document_lifecycle_policy_registry_apply_and_attachment_classification/01_ROLLBACK_document_lifecycle_policy_registry_and_classification.sql
```
