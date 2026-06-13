
# Media Center Android Core Library Desugaring Build Hotfix

## Evidence Intake

The Android debug build failed in Gradle:

```text
Execution failed for task ':app:checkDebugAarMetadata'.
Dependency ':flutter_local_notifications' requires core library desugaring to be enabled for :app.
```

The same evidence also shows that `flutter analyze` was clean and CMS tests passed before the Android build step:

```text
flutter analyze = No issues found
flutter test = All tests passed
```

## Root Cause

`flutter_local_notifications` requires Android core library desugaring, but the Android app module did not enable it.

## Fix

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

The chosen `2.0.3` dependency follows the Android Developers documentation for AGP 7.4+ and is compatible with the current AGP 8.x line.

## Script Fix

Updated:

```text
scripts/build_media_center_android_debug.ps1
```

The script now checks `$LASTEXITCODE` after every `flutter` command and will not print success if Gradle fails.

## Warnings Not Fixed Here

The build log also warned about future support drops for:

```text
Gradle 8.12.0
Android Gradle Plugin 8.9.1
Kotlin 2.1.0
Built-in Kotlin migration
```

These are modernization warnings, not the current blocking failure. They should be handled in a separate dependency-modernization batch.

## Boundaries

```text
no SQL
no public base tables
no service_role
no RLS mutation
no media_center mutation
no production approval
```
