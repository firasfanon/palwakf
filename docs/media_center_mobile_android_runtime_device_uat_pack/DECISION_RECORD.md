# Decision Record

```json
{
  "batch": "MEDIA_CENTER_MOBILE_ANDROID_RUNTIME_DEVICE_UAT_PACK",
  "date": "2026_06_13",
  "base": "media_center_mobile_android_debug_build_success_evidence_closure_2026_06_13.zip",
  "purpose": "Prepare Android device/emulator runtime UAT after successful debug APK build.",
  "package_name": "com.example.waqf",
  "apk_path": "build/app/outputs/flutter-apk/app-debug.apk",
  "added_files": [
    "scripts/uat_media_center_android_runtime.ps1",
    "docs/media_center_mobile_android_runtime_device_uat_pack/ANDROID_RUNTIME_UAT_CHECKLIST.md",
    "docs/media_center_mobile_android_runtime_device_uat_pack/RUNBOOK.md",
    "docs/media_center_mobile_android_runtime_device_uat_pack/ARABIC_SIMPLE_SUMMARY.md",
    "docs/media_center_mobile_android_runtime_device_uat_pack/DECISION_RECORD.md"
  ],
  "uat_routes": [
    "/app/media",
    "/app/media-center",
    "/app/media-center/publish",
    "/app/media-center/drafts"
  ],
  "boundaries": [
    "no SQL",
    "no media_center mutation",
    "no public schema mutation",
    "no public base tables",
    "no service_role",
    "no production approval"
  ],
  "status": "android-runtime-device-uat-pack-prepared / apk-install-launch-script-added / mobile-routes-uat-checklist-added / local-drafts-runtime-uat-defined / official-first-mobile-workflow-uat-defined / no-sql / no-public-base-tables / no-service-role / production-not-approved"
}
```
