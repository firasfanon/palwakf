
# Hotfix تنظيف flutter analyze

## السبب

نتيجة SQL ناجحة، والاختبارات نجحت، والتطبيق اشتغل على Chrome، لكن `flutter analyze` أعطى مشكلتين:

```text
unnecessary_import
unused_import
```

## التصحيح

تم حذف استيرادين غير مستخدمين فقط:

```text
dart:typed_data
package:go_router/go_router.dart
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
