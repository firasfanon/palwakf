
# Media Center Android Kotlin Metadata Toolchain Alignment Hotfix

## Evidence

The Android debug build passed the Dart gates:

```text
flutter analyze = No issues found
flutter test = All tests passed
```

Then `flutter build apk` failed in Android/Kotlin compilation:

```text
Execution failed for task ':google_maps_flutter_android:compileDebugKotlin'
Internal compiler error
module was compiled with an incompatible version of Kotlin
binary version of its metadata is 2.3.0, expected version is 2.1.0
```

The log also showed Flutter's guidance:

```text
Your project requires a newer version of the Kotlin Gradle plugin.
```

## Root Cause

The project was using:

```text
Kotlin Gradle Plugin = 2.1.0
AGP = 8.9.1
Gradle = 8.12
```

But Android transitive dependencies now include Kotlin metadata 2.3.0.  
A Kotlin 2.1 compiler cannot reliably compile/analyze metadata produced by Kotlin 2.3.

## Fix

Updated:

```text
android/settings.gradle.kts
```

from:

```kotlin
id("com.android.application") version "8.9.1" apply false
id("org.jetbrains.kotlin.android") version "2.1.0" apply false
```

to:

```kotlin
id("com.android.application") version "8.11.1" apply false
id("org.jetbrains.kotlin.android") version "2.3.10" apply false
```

Updated:

```text
android/gradle/wrapper/gradle-wrapper.properties
```

from:

```text
gradle-8.12-all.zip
```

to:

```text
gradle-8.14-all.zip
```

Updated:

```text
android/gradle.properties
```

with:

```text
kotlin.compiler.execution.strategy=in-process
```

This avoids Kotlin daemon connection instability observed in the log.

Updated:

```text
scripts/build_media_center_android_debug.ps1
```

to stop existing Gradle daemons before build.

## Reference Notes

Kotlin 2.3.0 is documented as compatible with Gradle 7.6.3 through 9.0.0 and AGP 8.2.2 through 8.13.0. AGP 8.11.0 documents Gradle 8.13 as its minimum/default compatibility baseline. The Kotlin Android Gradle plugin portal lists 2.3.10 as an available version.

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
