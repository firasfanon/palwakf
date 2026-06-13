# Decision Record

```json
{
  "batch": "MEDIA_CENTER_ANDROID_KOTLIN_METADATA_TOOLCHAIN_ALIGNMENT_HOTFIX",
  "date": "2026_06_13",
  "base": "media_center_mobile_offline_drafts_unused_import_final_analyzer_hotfix_2026_06_13.zip",
  "evidence": {
    "flutter_analyze": "No issues found",
    "cms_tests": "All tests passed",
    "android_build_failure": "google_maps_flutter_android:compileDebugKotlin",
    "metadata_error": "binary version 2.3.0 expected 2.1.0",
    "flutter_fix": "requires newer Kotlin Gradle plugin"
  },
  "changes": {
    "android/settings.gradle.kts": {
      "com.android.application": "8.9.1 -> 8.11.1",
      "org.jetbrains.kotlin.android": "2.1.0 -> 2.3.10"
    },
    "android/gradle/wrapper/gradle-wrapper.properties": {
      "gradle": "8.12 -> 8.14"
    },
    "android/gradle.properties": {
      "kotlin.compiler.execution.strategy": "in-process"
    },
    "scripts/build_media_center_android_debug.ps1": {
      "gradle_daemon_stop": true
    }
  },
  "boundaries": [
    "no SQL",
    "no media_center mutation",
    "no public schema mutation",
    "no public base tables",
    "no service_role",
    "no production approval"
  ],
  "status": "android-kotlin-metadata-toolchain-alignment-hotfix-prepared / kotlin-gradle-plugin-upgraded-to-2-3-10 / agp-upgraded-to-8-11-1 / gradle-wrapper-upgraded-to-8-14 / kotlin-in-process-compilation-enabled / analyzer-prior-clean / cms-tests-prior-passed / android-build-retest-pending / no-sql / no-public-base-tables / no-service-role / production-not-approved"
}
```
