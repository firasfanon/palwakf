
# Android Runtime UAT ADB Locator Windows Hotfix

## Evidence

The UAT script failed before installing the APK:

```text
adb.exe was not found. Set ANDROID_HOME or ANDROID_SDK_ROOT, or add platform-tools to PATH.
```

## Root Cause

The script only checked configured environment variables and PATH. On Windows, Android Studio commonly installs SDK under:

```text
%LOCALAPPDATA%\Android\Sdk
```

without necessarily exporting `ANDROID_HOME`, `ANDROID_SDK_ROOT`, or `adb` into PATH.

## Fix

Updated:

```text
scripts/uat_media_center_android_runtime.ps1
```

The `Resolve-Adb` function now checks:

```text
ANDROID_HOME\platform-tools\adb.exe
ANDROID_SDK_ROOT\platform-tools\adb.exe
%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe
%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools\adb.exe
PATH
```

Also added optional:

```powershell
-DeviceSerial <serial>
```

for multi-device UAT.

## Retest

```powershell
.\scripts\uat_media_center_android_runtime.ps1 -SkipBuild
```

If multiple devices are attached:

```powershell
.\scripts\uat_media_center_android_runtime.ps1 -SkipBuild -DeviceSerial <serial>
```

## Boundaries

```text
no SQL
no Flutter change
no Android build change
no media_center mutation
no public mutation
no public base tables
no service_role
no production approval
```
