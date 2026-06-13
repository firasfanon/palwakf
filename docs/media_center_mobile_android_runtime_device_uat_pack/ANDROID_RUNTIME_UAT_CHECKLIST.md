
# Android Runtime Device/Emulator UAT Checklist

## Scope

This checklist validates the Media Center official-first mobile workflow on Android device/emulator after the debug APK build succeeded.

## Pre-conditions

```text
1. APK exists at build\app\outputs\flutter-apk\app-debug.apk.
2. Android device or emulator is connected.
3. adb is available through ANDROID_HOME, ANDROID_SDK_ROOT, or PATH.
4. The app uses anon/public Supabase keys only.
5. No service_role is present in Flutter/mobile code.
```

## Install and Launch

Run:

```powershell
.\scripts\uat_media_center_android_runtime.ps1 -SkipBuild
```

If APK is missing or stale, run without `-SkipBuild`:

```powershell
.\scripts\uat_media_center_android_runtime.ps1
```

## UAT-01 — App Launch

| Field | Expected |
|---|---|
| Action | Install APK and launch app |
| Expected result | App opens without crash |
| Evidence | Screenshot of first loaded screen + PowerShell log |

## UAT-02 — Mobile Operational Entry

| Field | Expected |
|---|---|
| Screen | `/app/media` |
| Expected result | Official-first media mobile operations screen appears |
| Evidence | Screenshot |

## UAT-03 — Media Browsing

| Field | Expected |
|---|---|
| Screen | `/app/media-center` |
| Expected result | News/announcements/activities load from public API edge |
| Governance | `media_center` remains source of truth, `public` API edge only |
| Evidence | Screenshot + log if available |

## UAT-04 — Quick Publish Screen

| Field | Expected |
|---|---|
| Screen | `/app/media-center/publish` |
| Expected result | Mobile publish form opens with official-first messaging |
| Evidence | Screenshot |

## UAT-05 — Local Draft Save

| Field | Expected |
|---|---|
| Action | Fill title/summary/body and press "حفظ على الهاتف" |
| Expected result | Local draft saved on phone |
| Governance | Local draft is not official content |
| Evidence | Screenshot/toast |

## UAT-06 — Local Draft Resume

| Field | Expected |
|---|---|
| Screen | `/app/media-center/drafts` |
| Action | Open saved draft and press "متابعة التحرير" |
| Expected result | Draft fields are restored in publish screen |
| Evidence | Screenshot |

## UAT-07 — Signed-in Official Submit/Publish

| Field | Expected |
|---|---|
| Actor | Signed-in employee or publisher |
| Action | Submit/review/publish according to role |
| Expected result | Official workflow uses RPC and does not write directly to public base tables |
| Evidence | Network logs or Supabase RPC evidence |

## UAT-08 — Not Signed-in Guard

| Field | Expected |
|---|---|
| Actor | Anonymous user |
| Action | Open publish screen |
| Expected result | Sign-in barrier appears and official submission is blocked |
| Evidence | Screenshot |

## Acceptance Criteria

```text
flutter analyze clean
CMS tests passed
APK installed
App launched
/app/media renders
/app/media-center renders
/app/media-center/publish renders
/app/media-center/drafts renders
local draft save works
local draft resume works
no service_role
no public base-table write
production not approved
```

## Deferred Warnings

```text
Built-in Kotlin migration
package updates
Java source/target 8 warnings
one discontinued dependency
```
