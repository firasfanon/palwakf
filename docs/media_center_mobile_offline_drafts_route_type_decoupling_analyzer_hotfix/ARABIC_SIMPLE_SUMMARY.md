
# Hotfix أقوى لأخطاء Analyzer في مسودات الهاتف

## المشكلة

ما زالت الأخطاء تظهر:

```text
MediaCenterLocalDraft غير معروف في common_routes_group.dart
labelAr غير معروف
```

## التصحيح الأقوى

بدل أن يعتمد ملف routing المشترك على نوع `MediaCenterLocalDraft`، أصبح يمرر:

```dart
state.extra
```

كما هو، ويتم فحص النوع داخل صفحة النشر السريع نفسها.

## كذلك

تم استبدال:

```dart
draft.contentType.labelAr
```

بمساعد محلي:

```dart
_contentTypeLabel(draft.contentType)
```

## لا يوجد

```text
لا SQL
لا Gradle
لا public base tables
لا service_role
لا production approval
```
