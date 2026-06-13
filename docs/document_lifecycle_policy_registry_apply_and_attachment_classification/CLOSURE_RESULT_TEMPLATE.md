
# Lifecycle Apply Result Template

Paste after running apply and verification.

## Apply Result

```text
document_lifecycle_apply_result:
document_types_table_present:
service_wrapper_present:
media_wrapper_present:
document_type_count:
classified_service_attachment_count:
production_approved:
```

## Verification

```text
document_lifecycle_registry_presence:
document_lifecycle_document_types:
service_attachment_lifecycle_columns:
service_attachment_classification_summary:
document_center_wrappers_lifecycle_counts:
document_center_storage_counts:
```

## Runtime

```text
flutter analyze:
flutter test:
smoke:
admin documents browser:
```

## Expected Decision

```text
DOCUMENT_LIFECYCLE_POLICY_REGISTRY_APPLIED_AND_ATTACHMENT_CLASSIFICATION_VERIFIED
```
