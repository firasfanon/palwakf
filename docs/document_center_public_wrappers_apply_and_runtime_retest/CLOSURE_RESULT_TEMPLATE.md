
# Document Center Public Wrappers Runtime Retest Result Template

Paste results here after apply/retest.

## SQL Apply Result

```text
document_center_public_wrappers_apply_result:
service_attachments_wrapper_present:
media_assets_wrapper_present:
service_attachments_authenticated_select:
media_assets_authenticated_select:
production_approved:
```

## SQL Verification

```text
document_center_public_wrappers_presence:
document_center_service_attachments_sample:
document_center_media_assets_sample:
document_center_storage_counts:
```

## Flutter

```text
flutter analyze:
flutter test cms_payload_contracts:
smoke suite:
flutter run:
```

## Browser

```text
/admin/documents:
home/news:
console errors:
network markers:
```

## Decision

Expected final decision if all pass:

```text
DOCUMENT_CENTER_PUBLIC_WRAPPERS_APPLIED_AND_RUNTIME_RETEST_PASSED
```
