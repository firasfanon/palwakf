# CMS SharedContentSaveHelper — removedList Warning Closure

## السبب

آخر نتيجة `flutter analyze` بقيت عند تحذير واحد:

```text
unused_local_variable: removedList
```

## التصحيح

تم استبدال المتغير إلى:

```dart
final removedColumnsText = removedColumns.join(', ');
```

واستخدامه فعليًا داخل رسالة `StateError`:

```dart
'$table: $removedColumnsText. Last error: $message'
```

## ما بقي محفوظًا

- fallback الخاص بـ `news_articles.author`.
- إزالة الحقول الاختيارية غير الموجودة.
- إعادة المحاولة عند أخطاء schema cache.
- CMS write يبقى direct Supabase table access.
- لا SQL.
- لا RLS.
- لا service_role.
