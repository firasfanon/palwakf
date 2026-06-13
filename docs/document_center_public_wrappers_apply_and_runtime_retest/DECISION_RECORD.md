# Decision Record

```json
{
  "batch": "DOCUMENT_CENTER_PUBLIC_WRAPPERS_APPLY_AND_RUNTIME_RETEST",
  "date": "2026_06_12",
  "base": "palwakf_document_center_public_wrappers_runtime_closure_hotfix_2026_06_12.zip",
  "purpose": "Apply safe public wrappers for /admin/documents and retest runtime without direct owner-schema REST reads.",
  "public_wrappers": [
    "public.v_document_center_service_attachments_v1",
    "public.v_document_center_media_assets_v1"
  ],
  "owner_schemas_preserved_private": [
    "platform_services",
    "media_center"
  ],
  "not_included": [
    "no direct owner-schema exposure",
    "no RLS mutation",
    "no data mutation",
    "no service_role in Flutter",
    "no production approval"
  ],
  "status": "document-center-public-wrappers-apply-package-ready / runtime-retest-gate-prepared / owner-schemas-private-preserved / no-direct-flutter-owner-schema-read / no-rls-mutation / no-data-mutation / no-service-role / production-not-approved / operator-apply-pending"
}
```
