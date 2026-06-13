
# Hotfix أخطاء Analyzer في مسودات الهاتف

## المشكلة

`flutter analyze` توقف بثلاثة أخطاء:

```text
MediaCenterLocalDraft غير معروف في common_routes_group.dart
labelAr غير معروف في media_center_local_drafts_page.dart
```

## السبب

`common_routes_group.dart` ملف part، لذلك import النوع يجب أن يكون في:

```text
go_router_config.dart
```

وليس داخل ملف route group.

كذلك `labelAr` هو extension ويحتاج import مباشر لملف الـ model.

## التصحيح

تم تعديل:

```text
lib/app/routing/go_router_config.dart
lib/features/media_center_mobile/presentation/pages/media_center_local_drafts_page.dart
```

## لا يوجد

```text
لا SQL
لا Gradle
لا public base tables
لا service_role
لا production approval
```
