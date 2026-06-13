# Decision Record

```json
{
  "batch": "MEDIA_CENTER_OFFICIAL_FIRST_MOBILE_OPERATIONAL_WORKFLOW_AND_ANDROID_READINESS",
  "date": "2026_06_13",
  "base": "media_center_official_first_mobile_visual_contract_alignment_hotfix_2026_06_13.zip",
  "scope": "mobile-first operational workflow plus Android debug readiness",
  "new_route": "/app/media",
  "existing_routes": [
    "/app/media-center",
    "/app/media-center/publish",
    "/official/media/:family/:id"
  ],
  "changed_files": [
    "lib/features/media_center_mobile/presentation/pages/media_center_mobile_operational_home_page.dart",
    "lib/app/routing/app_routes.dart",
    "lib/app/routing/go_router_config.dart",
    "lib/app/routing/route_groups/common_routes_group.dart",
    "scripts/build_media_center_android_debug.ps1",
    "sql_verification/media_center_official_first_mobile_operational_workflow_android_readiness/01_VERIFY_official_first_mobile_operational_readiness.sql"
  ],
  "boundaries": [
    "no SQL apply",
    "no public base tables",
    "no service_role",
    "no RLS mutation",
    "no production approval"
  ],
  "status": "mobile-operational-workflow-prepared / android-debug-build-readiness-script-added / app-media-operational-home-route-added / official-first-workflow-visible / no-sql-apply / no-public-base-tables / no-service-role / production-not-approved / retest-pending"
}
```
