# Decision Record

```json
{
  "batch": "MEDIA_CENTER_MOBILE_OFFLINE_DRAFTS_UNUSED_IMPORT_FINAL_ANALYZER_HOTFIX",
  "date": "2026_06_13",
  "base": "media_center_mobile_offline_drafts_route_type_decoupling_analyzer_hotfix_2026_06_13.zip",
  "evidence": {
    "flutter_analyze_remaining_issue": "unused_import",
    "file": "lib/app/routing/go_router_config.dart",
    "unused_import": "../../features/media_center_mobile/data/repositories/media_center_mobile_local_draft_store.dart"
  },
  "changed_files": [
    "lib/app/routing/go_router_config.dart"
  ],
  "fix": "remove unused import after route type decoupling",
  "boundaries": [
    "no SQL",
    "no Gradle changes",
    "no public base tables",
    "no service_role",
    "no production approval"
  ],
  "status": "offline-drafts-final-unused-import-hotfix-prepared / go-router-unused-import-removed / analyzer-clean-retest-pending / android-build-retest-pending / no-sql / no-gradle-change / no-public-base-tables / no-service-role / production-not-approved"
}
```
