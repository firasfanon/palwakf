# CMS SharedContentSaveHelper — Final StateError Compile Hotfix

## السبب

`flutter analyze` و `flutter run -d chrome` توقفا عند خطأ واحد:

```text
Too many positional arguments: 1 expected, but 2 found
shared_content_save_helper.dart:126:40
```

السبب صياغة رسالة `StateError(...)` حول `removedColumns.join(', ')`.

## التصحيح

تم إنشاء متغير مستقل:

```dart
final removedList = removedColumns.join(', ');
```

ثم تمرير رسالة واحدة فقط إلى `StateError`.

## ما بقي محفوظًا

- fallback للعمود `news_articles.author = إدارة المحتوى`.
- إزالة الحقول الاختيارية غير الموجودة.
- إعادة المحاولة عند PGRST204.
- CMS write يبقى direct Supabase table access.
- لا SQL.
- لا RLS.
- لا service_role.
