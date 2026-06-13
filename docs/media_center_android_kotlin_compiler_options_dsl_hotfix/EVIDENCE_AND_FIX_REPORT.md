
# Media Center Android Kotlin compilerOptions DSL Hotfix

## Evidence

The latest Android build reached the Android Gradle build stage after passing the Dart gates:

```text
flutter analyze = No issues found
flutter test = All tests passed
```

The build then failed in:

```text
android/app/build.gradle.kts line 20
```

with:

```text
Using 'jvmTarget: String' is an error.
Please migrate to the compilerOptions DSL.
```

## Root Cause

After upgrading Kotlin Gradle Plugin to align with Kotlin metadata 2.3.x, the old Kotlin DSL block is no longer accepted:

```kotlin
kotlinOptions {
    jvmTarget = JavaVersion.VERSION_11.toString()
}
```

## Fix

Updated:

```text
android/app/build.gradle.kts
```

from the old `kotlinOptions` style to:

```kotlin
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_11)
    }
}
```

## Script Hygiene

Updated:

```text
scripts/build_media_center_android_debug.ps1
```

The script no longer attempts `gradlew --stop` when `JAVA_HOME/java` is not available in the current shell. This avoids a misleading Java error before Flutter uses its own Android toolchain path.

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
