# Decision Record

```json
{
  "batch": "DOCUMENT_LIFECYCLE_POLICY_REGISTRY_APPLY_AND_ATTACHMENT_CLASSIFICATION",
  "date": "2026_06_12",
  "base": "document_center_public_wrappers_applied_runtime_retest_evidence_closure_2026_06_12.zip",
  "purpose": "Apply document lifecycle governance registry and classify existing service attachments without deleting files.",
  "includes": [
    "platform_documents.document_types",
    "seed document type policies",
    "service_request_attachments lifecycle columns",
    "service attachment classification/backfill",
    "lifecycle-aware public wrappers",
    "verification SQL",
    "rollback SQL",
    "runtime retest runbook"
  ],
  "boundaries": [
    "no file deletion",
    "no storage.objects mutation",
    "no media_center destructive mutation",
    "no RLS mutation",
    "no service_role in Flutter",
    "no production approval"
  ],
  "status": "document-lifecycle-policy-registry-apply-package-ready / attachment-classification-prepared / lifecycle-aware-public-wrappers-prepared / verification-and-rollback-prepared / no-file-deletion / no-storage-mutation / no-rls-mutation / no-service-role / production-not-approved / operator-apply-pending"
}
```
