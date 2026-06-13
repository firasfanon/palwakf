
# PalWakf — Media Center Mobile Application Development Procedures

**Date:** 2026-06-13  
**Track:** Media Center Official-First Mobile Publishing App  
**Platform:** PalWakf  
**Scope:** Flutter Mobile + Android Debug Build + Android Runtime UAT Preparation  
**Status:** Android debug APK built successfully; Android runtime UAT pending device/emulator availability.

---

## 1. Purpose

This document records the procedures, decisions, fixes, and evidence gates completed during the development of the PalWakf mobile application track for the Media Center.

The mobile application track was introduced because Media Center publishing is not only a website/admin-dashboard workflow. Field reporters or authorized employees may need to publish from a phone while attending events, then share the official PalWakf link to social media instead of publishing first on Facebook.

The governing operational model is:

```text
Official platform first
Social media second
```

---

## 2. Governing Boundaries

The following constraints were preserved throughout the mobile development track:

```text
media_center = source of truth
public = API edge only
no public base tables
no service_role in Flutter/mobile
no uncontrolled RLS mutation
no storage/object deletion
no SQL production apply unless explicitly authorized
production not approved
```

The mobile app may create or submit official content only through governed RPC/API-edge workflows. Local phone drafts are not official content until submitted to the platform.

---

## 3. Main Functional Objective

The mobile app supports the following practical workflow:

```text
Reporter or employee is in the field
↓
Creates content from phone
↓
Saves local draft if connection is weak or content is incomplete
↓
Submits to official platform when ready
↓
Authorized publisher reviews/publishes according to role
↓
Public users receive official PalWakf link
↓
Official link is shared to social platforms
```

---

## 4. Mobile Routes Added or Governed

The following mobile routes were introduced or governed:

```text
/app/media
/app/media-center
/app/media-center/publish
/app/media-center/drafts
/official/media/:family/:id
```

### Route Purposes

| Route | Purpose |
|---|---|
| `/app/media` | Mobile operational home for Media Center workflows |
| `/app/media-center` | Browse news, announcements, and activities from public API edge |
| `/app/media-center/publish` | Quick official-first mobile publishing form |
| `/app/media-center/drafts` | Local phone drafts page |
| `/official/media/:family/:id` | Official public detail route for shareable media links |

---

## 5. Official-First Mobile Publishing App MVP

### Batch

```text
MEDIA_CENTER_OFFICIAL_FIRST_MOBILE_PUBLISHING_APP_MVP_MEGA_BATCH
```

### Added

```text
lib/features/media_center_mobile/data/models/media_center_publish_models.dart
lib/features/media_center_mobile/data/repositories/media_center_mobile_publishing_repository.dart
lib/features/media_center_mobile/presentation/providers/media_center_publishing_providers.dart
lib/features/media_center_mobile/presentation/pages/media_center_quick_publish_page.dart
lib/features/media_center_public/presentation/pages/official_media_detail_page.dart
```

### Backend/API Edge Prepared

The batch prepared SQL/RPC workflow files for:

```text
media_center.mobile_publish_events
public.rpc_media_center_mobile_actor_can_publish_v1()
public.rpc_media_center_official_path_v1(text, uuid)
public.rpc_media_center_mobile_create_draft_v1(...)
public.rpc_media_center_mobile_submit_for_review_v1(uuid)
public.rpc_media_center_mobile_publish_v1(uuid)
public.rpc_media_center_public_content_detail_v1(text,text)
```

### Rule

The public schema remains API edge only. It is not the source of truth.

---

## 6. Analyzer Cleanup for Mobile Publishing MVP

### Batch

```text
MEDIA_CENTER_OFFICIAL_FIRST_MOBILE_PUBLISHING_APP_ANALYZER_CLEANUP_HOTFIX
```

### Fixed

Removed unused imports from the first mobile publishing implementation:

```text
dart:typed_data
package:go_router/go_router.dart
```

### Result

The initial analyzer blockers were reduced and later fully closed.

---

## 7. Runtime Fix — Breaking News Slider Null Safety

### Batch

```text
MEDIA_CENTER_OFFICIAL_FIRST_MOBILE_PUBLISHING_APP_BREAKING_NEWS_NULLSAFE_RUNTIME_HOTFIX
```

### Issue

The homepage crashed because `settingsState.settings!` was forced while settings could be null.

### Fix

Replaced forced null-check with safe fallback:

```dart
final settings =
    settingsState.settings ?? const BreakingNewsSectionSettings();

if (items.isEmpty || !settings.enabled) {
  return const SizedBox.shrink();
}
```

### Result

The homepage rendered again and Media Center mobile routes became reachable in browser runtime.

---

## 8. Visual Contract Alignment

### Batch

```text
MEDIA_CENTER_OFFICIAL_FIRST_MOBILE_VISUAL_CONTRACT_ALIGNMENT_HOTFIX
```

### Purpose

The first quick-publishing UI worked functionally, but did not fully respect the PalWakf platform visual contract.

### Added

```text
lib/features/media_center_mobile/presentation/widgets/media_center_mobile_visual_contract.dart
```

### Aligned Screens

```text
/app/media-center
/app/media-center/publish
/official/media/:family/:id
```

### Visual Contract

```text
Dark platform background: #0B1220
Platform gold: #D4AF37
Platform blue: #0E3A6D
Royal red: #B22222
RTL-first
Official-first messaging
Public API edge disclosure
Employee sign-in barrier
```

---

## 9. Mobile Operational Home + Android Readiness

### Batch

```text
MEDIA_CENTER_OFFICIAL_FIRST_MOBILE_OPERATIONAL_WORKFLOW_AND_ANDROID_READINESS
```

### Added

```text
/app/media
```

### Added Files

```text
lib/features/media_center_mobile/presentation/pages/media_center_mobile_operational_home_page.dart
scripts/build_media_center_android_debug.ps1
sql_verification/media_center_official_first_mobile_operational_workflow_android_readiness/01_VERIFY_official_first_mobile_operational_readiness.sql
```

### Purpose

To provide a central mobile entry point for:

```text
Official publishing
Media browsing
Local/field workflow
Android readiness
```

---

## 10. Android Debug Build Script

### Script

```text
scripts/build_media_center_android_debug.ps1
```

### Function

The script performs:

```text
flutter pub get
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
flutter build apk --debug --target lib/main.dart --dart-define=PWF_ALLOW_LEGACY_PUBLIC_MEDIA_BASE_FALLBACK=false
```

### Important Fix

The script was corrected to fail when a command fails. This closed the previous false-success risk where the script printed success even when Gradle failed.

---

## 11. Android Core Library Desugaring

### Batch

```text
MEDIA_CENTER_ANDROID_CORE_LIBRARY_DESUGARING_BUILD_HOTFIX
```

### Issue

Android build failed because `flutter_local_notifications` required core library desugaring.

### Fix

Updated:

```text
android/app/build.gradle.kts
```

Added:

```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
    isCoreLibraryDesugaringEnabled = true
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}
```

### Result

The desugaring blocker was closed.

---

## 12. PowerShell Build Script Variable Fix

### Batch

```text
MEDIA_CENTER_ANDROID_BUILD_SCRIPT_POWERSHELL_VARIABLE_HOTFIX
```

### Issue

PowerShell failed on:

```powershell
$LASTEXITCODE:
```

### Fix

Replaced with:

```powershell
$($LASTEXITCODE):
```

### Result

The script became syntactically valid and command-failure aware.

---

## 13. Offline Drafts + Field Reporter Workflow

### Batch

```text
MEDIA_CENTER_MOBILE_OFFLINE_DRAFTS_AND_FIELD_REPORTER_WORKFLOW
```

### Purpose

Support field reporters when internet is weak or content is not ready for official submission.

### Added

```text
lib/features/media_center_mobile/data/repositories/media_center_mobile_local_draft_store.dart
lib/features/media_center_mobile/presentation/providers/media_center_local_draft_providers.dart
lib/features/media_center_mobile/presentation/pages/media_center_local_drafts_page.dart
```

### Added Route

```text
/app/media-center/drafts
```

### Features

```text
Save local draft on phone
List local drafts
Resume editing
Keep local draft unofficial until RPC submission
```

### Rule

A local draft is only a phone-side temporary copy. It is not official PalWakf content.

---

## 14. Offline Draft Analyzer Fixes

Several analyzer hotfixes were applied to stabilize the offline drafts workflow.

### 14.1 Import Hotfix

```text
MEDIA_CENTER_MOBILE_OFFLINE_DRAFTS_ANALYZER_IMPORTS_HOTFIX
```

Attempted to import missing types and extension libraries.

### 14.2 Route Type Decoupling

```text
MEDIA_CENTER_MOBILE_OFFLINE_DRAFTS_ROUTE_TYPE_DECOUPLING_ANALYZER_HOTFIX
```

Changed routing to avoid requiring `MediaCenterLocalDraft` in route-group scope:

```dart
MediaCenterQuickPublishPage(initialDraft: state.extra)
```

The type check was moved into the feature page.

### 14.3 Final Unused Import Fix

```text
MEDIA_CENTER_MOBILE_OFFLINE_DRAFTS_UNUSED_IMPORT_FINAL_ANALYZER_HOTFIX
```

Removed the final unused import from:

```text
lib/app/routing/go_router_config.dart
```

### Result

```text
flutter analyze = No issues found
```

---

## 15. Android Kotlin Metadata Toolchain Alignment

### Batch

```text
MEDIA_CENTER_ANDROID_KOTLIN_METADATA_TOOLCHAIN_ALIGNMENT_HOTFIX
```

### Issue

Android build failed because dependencies included Kotlin metadata 2.3.0 while the project used Kotlin 2.1.0.

### Fix

Updated:

```text
Kotlin Gradle Plugin: 2.1.0 -> 2.3.10
Android Gradle Plugin: 8.9.1 -> 8.11.1
Gradle Wrapper: 8.12 -> 8.14
```

Added:

```text
kotlin.compiler.execution.strategy=in-process
```

### Result

The Kotlin metadata mismatch blocker was reduced and Android build progressed to the next blocker.

---

## 16. Kotlin compilerOptions DSL Fix

### Batch

```text
MEDIA_CENTER_ANDROID_KOTLIN_COMPILER_OPTIONS_DSL_HOTFIX
```

### Issue

Kotlin 2.3 rejected the old DSL:

```kotlin
kotlinOptions {
    jvmTarget = JavaVersion.VERSION_11.toString()
}
```

### Fix

Updated to:

```kotlin
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_11)
    }
}
```

### Result

The `jvmTarget: String` DSL error was closed.

---

## 17. Duplicate MainActivity Cleanup

### Batch

```text
MEDIA_CENTER_ANDROID_DUPLICATE_MAINACTIVITY_CLEANUP_HOTFIX
```

### Issue

Android build failed with:

```text
Redeclaration:
class MainActivity : FlutterActivity
class MainActivity : FlutterActivity
```

### Cause

Two files declared the same class:

```text
android/app/src/main/kotlin/com/example/waqf/MainActivity.kt
android/app/src/main/java/com/example/waqf/MainActivity.java
```

### Fix

Retained Kotlin as canonical:

```text
android/app/src/main/kotlin/com/example/waqf/MainActivity.kt
```

Removed Java duplicate:

```text
android/app/src/main/java/com/example/waqf/MainActivity.java
```

Added cleanup script:

```text
scripts/cleanup_android_duplicate_mainactivity.ps1
```

### Result

Duplicate `MainActivity` blocker was closed.

---

## 18. Android Debug APK Build Closure

### Batch

```text
MEDIA_CENTER_MOBILE_ANDROID_DEBUG_BUILD_SUCCESS_EVIDENCE_CLOSURE
```

### Accepted Evidence

```text
flutter analyze = No issues found
CMS tests = All tests passed
Android debug APK = Built successfully
APK path = build\app\outputs\flutter-apk\app-debug.apk
```

### Accepted Decision

```text
MEDIA_CENTER_MOBILE_ANDROID_DEBUG_BUILD_SUCCESS_ACCEPTED
```

### Meaning

The mobile app reached a real installable Android debug APK. This confirms the mobile development track is operational at build level.

---

## 19. Android Runtime Device/Emulator UAT Pack

### Batch

```text
MEDIA_CENTER_MOBILE_ANDROID_RUNTIME_DEVICE_UAT_PACK
```

### Added

```text
scripts/uat_media_center_android_runtime.ps1
docs/media_center_mobile_android_runtime_device_uat_pack/ANDROID_RUNTIME_UAT_CHECKLIST.md
docs/media_center_mobile_android_runtime_device_uat_pack/RUNBOOK.md
```

### Purpose

To install and launch the APK on a real Android device or emulator.

### UAT Routes

```text
/app/media
/app/media-center
/app/media-center/publish
/app/media-center/drafts
```

---

## 20. ADB Locator Windows Hotfix

### Batch

```text
MEDIA_CENTER_ANDROID_RUNTIME_UAT_ADB_LOCATOR_WINDOWS_HOTFIX
```

### Issue

UAT script could not find:

```text
adb.exe
```

### Fix

The script now searches:

```text
ANDROID_HOME\platform-tools\adb.exe
ANDROID_SDK_ROOT\platform-tools\adb.exe
%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe
%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools\adb.exe
PATH
```

### Result

The script found:

```text
C:\Users\DELL\AppData\Local\Android\Sdk\platform-tools\adb.exe
```

---

## 21. Device Availability Gate Hotfix

### Batch

```text
MEDIA_CENTER_ANDROID_RUNTIME_UAT_DEVICE_AVAILABILITY_GATE_HOTFIX
```

### Issue

ADB was found, but no Android device or emulator was connected:

```text
adb.exe: no devices/emulators found
```

### Fix

Added:

```text
scripts/list_android_devices_and_emulators.ps1
```

Enhanced:

```text
scripts/uat_media_center_android_runtime.ps1
```

with:

```text
-EmulatorName <AVD_NAME>
-DeviceSerial <serial>
-ListOnly
```

### Result

The UAT script now treats missing device/emulator as a clear environment gate instead of a confusing install failure.

---

## 22. Current Accepted State

```text
media-center-mobile-official-first-workflow-prepared
mobile-visual-contract-aligned
offline-local-drafts-added
flutter-analyze-clean
cms-contract-tests-passed
android-debug-apk-built
adb-locator-fixed
device-availability-gate-prepared
runtime-device-uat-pending
no-sql
no-public-base-tables
no-service-role
production-not-approved
```

---

## 23. Current APK

```text
build\app\outputs\flutter-apk\app-debug.apk
```

---

## 24. Current UAT Commands

### List devices and emulators

```powershell
.\scripts\list_android_devices_and_emulators.ps1
```

### Run UAT after opening a device or emulator

```powershell
.\scripts\uat_media_center_android_runtime.ps1 -SkipBuild
```

### Run UAT with a specific emulator

```powershell
.\scripts\uat_media_center_android_runtime.ps1 -SkipBuild -EmulatorName <AVD_NAME>
```

### Run UAT with a specific device

```powershell
.\scripts\uat_media_center_android_runtime.ps1 -SkipBuild -DeviceSerial <serial>
```

---

## 25. Manual Android Runtime UAT Checklist

After installing and launching the APK, validate:

```text
1. App opens without crash.
2. /app/media renders.
3. /app/media-center renders media content.
4. /app/media-center/publish renders quick publish form.
5. Anonymous actor sees sign-in barrier.
6. Local draft can be saved.
7. /app/media-center/drafts displays local draft.
8. Draft can be resumed.
9. Official submit/publish remains role/RPC governed.
10. No service_role appears in app runtime.
```

---

## 26. Deferred Backlog

The following warnings are not current blockers, but should be handled in a later modernization batch:

```text
Built-in Kotlin migration
Dependency updates
One discontinued package
Java source/target 8 warnings
Plugin KGP migration warnings
```

Recommended future batch:

```text
ANDROID_GRADLE_KOTLIN_PLUGIN_MODERNIZATION_BACKLOG
```

---

## 27. Final Note

This mobile track is now structurally part of the platform development path. Any future Media Center development should consider:

```text
Web public page
Admin dashboard
Mobile publishing app
Official public link sharing
Document/File Center attachments
media_center source of truth
public API edge only
```
