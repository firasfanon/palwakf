# Decision Record

```json
{
  "batch": "MEDIA_CENTER_ANDROID_BUILD_SCRIPT_POWERSHELL_VARIABLE_HOTFIX",
  "date": "2026_06_13",
  "base": "media_center_android_core_library_desugaring_build_hotfix_2026_06_13.zip",
  "error": "PowerShell parser error: Variable reference is not valid because ':' followed $LASTEXITCODE",
  "fix": "Use $($LASTEXITCODE): inside interpolated string",
  "changed_files": [
    "scripts/build_media_center_android_debug.ps1"
  ],
  "boundaries": [
    "no SQL",
    "no Android Gradle change",
    "no public base tables",
    "no service_role",
    "no production approval"
  ],
  "status": "powershell-build-script-variable-hotfix-prepared / last-exit-code-interpolation-fixed / android-build-retest-pending / no-sql / no-gradle-change / no-public-base-tables / no-service-role / production-not-approved"
}
```
