
# Media Center Mobile Android Runtime Device UAT Runbook

## Build

```powershell
.\scripts\build_media_center_android_debug.ps1
```

## Install and Launch

```powershell
.\scripts\uat_media_center_android_runtime.ps1 -SkipBuild
```

## Package

```text
com.example.waqf
```

## APK

```text
build\app\outputs\flutter-apk\app-debug.apk
```

## Evidence to Return

```text
1. PowerShell output from UAT script.
2. Screenshot of app launch.
3. Screenshot of /app/media.
4. Screenshot of /app/media-center.
5. Screenshot of /app/media-center/publish.
6. Screenshot of /app/media-center/drafts.
7. Screenshot showing local draft saved.
8. Screenshot showing local draft resumed.
9. Any runtime console/device logs if an error appears.
```

## Closure Decision Template

```text
MEDIA_CENTER_MOBILE_ANDROID_RUNTIME_DEVICE_UAT_ACCEPTED
or
MEDIA_CENTER_MOBILE_ANDROID_RUNTIME_DEVICE_UAT_BLOCKED_<REASON>
```
