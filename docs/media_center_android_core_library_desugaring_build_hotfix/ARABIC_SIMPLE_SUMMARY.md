
# Hotfix Android: Core Library Desugaring

## المشكلة

فشل بناء Android بسبب:

```text
flutter_local_notifications requires core library desugaring
```

## التصحيح

تم تعديل:

```text
android/app/build.gradle.kts
```

وإضافة:

```text
isCoreLibraryDesugaringEnabled = true
coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
```

## تصحيح إضافي

تم تعديل سكربت البناء حتى لا يطبع نجاحًا كاذبًا إذا فشل Gradle.

```text
scripts/build_media_center_android_debug.ps1
```

## غير مشمول

تحذيرات Gradle/AGP/Kotlin المستقبلية مؤجلة لدفعة تحديث تبعيات مستقلة.

## لا يوجد

```text
لا SQL
لا public base tables
لا service_role
لا production approval
```
