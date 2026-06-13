
# Hotfix Kotlin compilerOptions DSL

## النتيجة الحالية

تم تجاوز:

```text
flutter analyze
flutter test
```

لكن Android build توقف عند:

```text
android/app/build.gradle.kts line 20
```

بسبب:

```text
jvmTarget: String لم يعد مقبولًا
```

## التصحيح

تم استبدال:

```kotlin
kotlinOptions {
    jvmTarget = JavaVersion.VERSION_11.toString()
}
```

بـ:

```kotlin
kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_11)
    }
}
```

## تحسين السكربت

لن يحاول السكربت إيقاف Gradle daemon إذا لم يجد `JAVA_HOME/java` في PowerShell الحالي.

## لا يوجد

```text
لا SQL
لا media_center mutation
لا public mutation
لا public base tables
لا service_role
لا production approval
```
