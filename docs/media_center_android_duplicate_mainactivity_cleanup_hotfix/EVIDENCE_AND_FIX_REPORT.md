
# Media Center Android Duplicate MainActivity Cleanup Hotfix

## Evidence

The Android build passed the Flutter gates:

```text
flutter analyze = No issues found
flutter test = All tests passed
```

Then failed during Android Kotlin compilation:

```text
e: .../android/app/src/main/kotlin/com/example/waqf/MainActivity.kt:5:7 Redeclaration:
class MainActivity : FlutterActivity
class MainActivity : FlutterActivity
```

## Root Cause

The Android project contains two source files declaring the same fully-qualified class:

```text
android/app/src/main/kotlin/com/example/waqf/MainActivity.kt
android/app/src/main/java/com/example/waqf/MainActivity.java
```

Both resolve to:

```text
com.example.waqf.MainActivity
```

## Fix

Canonical retained:

```text
android/app/src/main/kotlin/com/example/waqf/MainActivity.kt
```

Duplicate removed from the full baseline:

```text
android/app/src/main/java/com/example/waqf/MainActivity.java
```

A cleanup script was added for updates-only application:

```text
scripts/cleanup_android_duplicate_mainactivity.ps1
```

The Android debug build script now runs this cleanup before the build.

## Changed Files

```text
scripts/build_media_center_android_debug.ps1
scripts/cleanup_android_duplicate_mainactivity.ps1
docs/media_center_android_duplicate_mainactivity_cleanup_hotfix/DELETE_MANIFEST.md
```

## Deleted From Full Baseline

```text
android/app/src/main/java/com/example/waqf/MainActivity.java
```

## Boundaries

```text
no SQL
no media_center mutation
no public schema mutation
no public base tables
no service_role
no production approval
```

## Retest

```powershell
.\scripts\build_media_center_android_debug.ps1
```
