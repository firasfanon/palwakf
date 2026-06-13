
# Hotfix Runtime: BreakingNewsSlider

## المشكلة

التطبيق اشتغل، لكن الصفحة الرئيسية تعطلت بسبب:

```text
BreakingNewsSlider
Unexpected null value
```

## السبب

إعدادات شريط الأخبار العاجلة كانت null لحظة بناء الواجهة، والكود استخدم:

```dart
settingsState.settings!
```

## التصحيح

استخدام إعدادات افتراضية آمنة لحين تحميل الإعدادات:

```dart
final settings =
    settingsState.settings ?? const BreakingNewsSectionSettings();
```

## لا يوجد

```text
لا SQL
لا public base tables
لا service_role
لا RLS mutation
لا production approval
```

## المطلوب بعد التطبيق

```bash
flutter analyze
flutter test test/core/contracts/cms_payload_contracts_test.dart
flutter run -d chrome --dart-define=PWF_ALLOW_LEGACY_PUBLIC_MEDIA_BASE_FALLBACK=false
```

ثم افتح:

```text
/home
/app/media-center
/app/media-center/publish
```
