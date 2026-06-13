# Decision Record

```json
{
  "batch": "MEDIA_CENTER_ANDROID_CORE_LIBRARY_DESUGARING_BUILD_HOTFIX",
  "date": "2026_06_13",
  "base": "media_center_official_first_mobile_operational_workflow_android_readiness_2026_06_13.zip",
  "evidence": {
    "android_build_failed": true,
    "failure_task": ":app:checkDebugAarMetadata",
    "blocking_dependency": ":flutter_local_notifications",
    "required_fix": "enable core library desugaring",
    "flutter_analyze_prior": "No issues found",
    "cms_tests_prior": "All tests passed"
  },
  "changes": {
    "android/app/build.gradle.kts": [
      "isCoreLibraryDesugaringEnabled = true",
      "coreLibraryDesugaring(\"com.android.tools:desugar_jdk_libs:2.0.3\")"
    ],
    "scripts/build_media_center_android_debug.ps1": [
      "strict LASTEXITCODE checking",
      "verify APK path exists before success message"
    ]
  },
  "not_fixed_here": [
    "Gradle 8.12 -> 8.14+ modernization",
    "AGP 8.9.1 -> 8.11.1+ modernization",
    "Kotlin 2.1.0 -> 2.2.20+ modernization",
    "Built-in Kotlin migration"
  ],
  "boundaries": [
    "no SQL",
    "no public base tables",
    "no service_role",
    "no RLS mutation",
    "no media_center mutation",
    "no production approval"
  ],
  "status": "android-desugaring-build-hotfix-prepared / flutter-local-notifications-aarmetadata-blocker-targeted / build-script-false-success-fixed / analyzer-prior-clean / cms-tests-prior-passed / android-debug-build-retest-pending / no-sql / no-public-base-tables / no-service-role / production-not-approved"
}
```
