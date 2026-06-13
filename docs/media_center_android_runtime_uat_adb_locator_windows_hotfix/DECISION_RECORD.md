# Decision Record

```json
{
  "batch": "MEDIA_CENTER_ANDROID_RUNTIME_UAT_ADB_LOCATOR_WINDOWS_HOTFIX",
  "date": "2026_06_13",
  "base": "media_center_mobile_android_runtime_device_uat_pack_2026_06_13.zip",
  "evidence": "UAT script failed because adb.exe was not found in environment/PATH.",
  "changed_files": [
    "scripts/uat_media_center_android_runtime.ps1"
  ],
  "fix": [
    "Resolve adb from ANDROID_HOME",
    "Resolve adb from ANDROID_SDK_ROOT",
    "Resolve adb from LOCALAPPDATA Android SDK default path",
    "Resolve adb from USERPROFILE Android SDK default path",
    "Resolve adb from PATH",
    "Add optional DeviceSerial support"
  ],
  "boundaries": [
    "no SQL",
    "no Flutter change",
    "no Android build change",
    "no media_center mutation",
    "no public mutation",
    "no public base tables",
    "no service_role",
    "no production approval"
  ],
  "status": "android-runtime-uat-adb-locator-windows-hotfix-prepared / adb-default-windows-sdk-path-added / device-serial-option-added / apk-build-prior-accepted / runtime-uat-retest-pending / no-sql / no-public-base-tables / no-service-role / production-not-approved"
}
```
