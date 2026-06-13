# Decision Record

```json
{
  "batch": "MEDIA_CENTER_ANDROID_KOTLIN_COMPILER_OPTIONS_DSL_HOTFIX",
  "date": "2026_06_13",
  "base": "media_center_android_kotlin_metadata_toolchain_alignment_hotfix_2026_06_13.zip",
  "evidence": {
    "flutter_analyze": "No issues found",
    "cms_tests": "All tests passed",
    "android_failure": "android/app/build.gradle.kts line 20",
    "error": "Using 'jvmTarget: String' is an error. Please migrate to the compilerOptions DSL."
  },
  "changes": {
    "android/app/build.gradle.kts": [
      "remove kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }",
      "add import org.jetbrains.kotlin.gradle.dsl.JvmTarget",
      "add kotlin { compilerOptions { jvmTarget.set(JvmTarget.JVM_11) } }"
    ],
    "scripts/build_media_center_android_debug.ps1": [
      "skip gradlew --stop when JAVA_HOME/java is unavailable"
    ]
  },
  "boundaries": [
    "no SQL",
    "no media_center mutation",
    "no public schema mutation",
    "no public base tables",
    "no service_role",
    "no production approval"
  ],
  "status": "android-kotlin-compiler-options-dsl-hotfix-prepared / deprecated-kotlinOptions-jvmTarget-removed / compilerOptions-jvmTarget-JVM_11-added / gradle-daemon-stop-java-guard-added / analyzer-prior-clean / cms-tests-prior-passed / android-build-retest-pending / no-sql / no-public-base-tables / no-service-role / production-not-approved"
}
```
