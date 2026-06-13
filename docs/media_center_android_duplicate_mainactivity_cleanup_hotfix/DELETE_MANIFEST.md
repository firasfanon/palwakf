
# Delete Manifest

The following duplicate Android source file must be absent:

```text
android/app/src/main/java/com/example/waqf/MainActivity.java
```

Canonical retained source:

```text
android/app/src/main/kotlin/com/example/waqf/MainActivity.kt
```

Rationale:

```text
Both files declare com.example.waqf.MainActivity, causing Kotlin redeclaration during :app:compileDebugKotlin.
```

For updates-only application, run:

```powershell
.\scripts\cleanup_android_duplicate_mainactivity.ps1
```

The Android debug build script runs this cleanup automatically before build.
