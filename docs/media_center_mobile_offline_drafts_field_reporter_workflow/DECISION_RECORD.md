# Decision Record

```json
{
  "batch": "MEDIA_CENTER_MOBILE_OFFLINE_DRAFTS_AND_FIELD_REPORTER_WORKFLOW",
  "date": "2026_06_13",
  "base": "media_center_android_build_script_powershell_variable_hotfix_2026_06_13.zip",
  "purpose": "Support field reporters with local mobile drafts before official platform submission.",
  "new_route": "/app/media-center/drafts",
  "changed_files": [
    "lib/features/media_center_mobile/data/repositories/media_center_mobile_local_draft_store.dart",
    "lib/features/media_center_mobile/presentation/providers/media_center_local_draft_providers.dart",
    "lib/features/media_center_mobile/presentation/pages/media_center_local_drafts_page.dart",
    "lib/features/media_center_mobile/presentation/pages/media_center_quick_publish_page.dart",
    "lib/features/media_center_mobile/presentation/pages/media_center_mobile_operational_home_page.dart",
    "lib/app/routing/app_routes.dart",
    "lib/app/routing/go_router_config.dart",
    "lib/app/routing/route_groups/common_routes_group.dart"
  ],
  "storage_semantics": {
    "local_draft": "temporary local SharedPreferences only",
    "official_source_of_truth": "media_center after RPC submission",
    "public_schema": "API edge only"
  },
  "boundaries": [
    "no SQL apply",
    "no public base tables",
    "no service_role",
    "no production approval"
  ],
  "status": "mobile-offline-drafts-prepared / field-reporter-local-draft-workflow-added / app-media-center-drafts-route-added / quick-publish-save-local-draft-added / local-draft-not-official-until-rpc-submit / no-sql-apply / no-public-base-tables / no-service-role / production-not-approved / retest-pending"
}
```
