# Decision Record

```json
{
  "batch": "PALWAKF_FILE_CENTER_HOME_NEWS_PUBLIC_API_EDGE_MEGA_BATCH",
  "date": "2026_06_13",
  "combined_requests": [
    "FILE_CENTER_EXPLICIT_UNIT_ASSIGNMENT_AND_OWNER_RECORD_MAPPING_WORKFLOW",
    "HOME_NEWS_MEDIA_EXPERIENCE_AND_HOMEPAGE_CHALLENGES_CLOSURE_MEGA_BATCH",
    "PUBLIC_SCHEMA_IS_COMPATIBILITY_AND_API_EDGE_ONLY_NOT_SYSTEM_SOURCE_OF_TRUTH"
  ],
  "public_schema_decision": "PUBLIC_SCHEMA_IS_COMPATIBILITY_AND_API_EDGE_ONLY_NOT_SYSTEM_SOURCE_OF_TRUTH",
  "frontend_changes": [
    "lib/features/document_center/domain/document_center_models.dart",
    "lib/features/document_center/data/document_center_repository.dart",
    "lib/features/document_center/presentation/pages/document_center_unified_page.dart",
    "lib/data/services/news_service.dart",
    "lib/core/database/pwf_database_owner_surfaces.dart"
  ],
  "sql_included": [
    "diagnostics",
    "file center explicit assignment/mapping RPC workflow",
    "verification",
    "rollback"
  ],
  "boundaries": [
    "no public base tables",
    "no owner data migration to public",
    "public views/functions are API edge only",
    "no file deletion",
    "no storage.objects mutation",
    "no fake owner records",
    "no public media auto-publish",
    "no RLS mutation",
    "no service_role",
    "no production approval"
  ],
  "status": "mega-batch-prepared / file-center-explicit-unit-assignment-workflow-prepared / home-news-media-experience-runtime-hardening-prepared / public-schema-api-edge-only-contract-applied-in-code-and-docs / no-public-base-tables / no-owner-truth-in-public / no-service-role / production-not-approved / operator-apply-and-runtime-retest-pending"
}
```
