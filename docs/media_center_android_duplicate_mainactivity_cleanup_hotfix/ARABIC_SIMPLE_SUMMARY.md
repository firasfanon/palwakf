
# Hotfix تكرار MainActivity في Android

## النتيجة الحالية

تم تجاوز:

```text
flutter analyze
flutter test
```

لكن Android build فشل بسبب:

```text
Redeclaration: MainActivity
```

## السبب

يوجد ملفان يعرّفان نفس الكلاس:

```text
android/app/src/main/kotlin/com/example/waqf/MainActivity.kt
android/app/src/main/java/com/example/waqf/MainActivity.java
```

## التصحيح

تم اعتماد Kotlin كمدخل Android الرسمي:

```text
android/app/src/main/kotlin/com/example/waqf/MainActivity.kt
```

وإزالة Java duplicate من الـ full baseline:

```text
android/app/src/main/java/com/example/waqf/MainActivity.java
```

كما أضيف سكربت تنظيف:

```text
scripts/cleanup_android_duplicate_mainactivity.ps1
```

ويتم تشغيله تلقائيًا من سكربت بناء Android.

## لا يوجد

```text
لا SQL
لا media_center mutation
لا public mutation
لا public base tables
لا service_role
لا production approval
```
