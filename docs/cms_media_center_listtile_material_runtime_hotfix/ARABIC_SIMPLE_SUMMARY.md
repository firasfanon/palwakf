# CMS Media Center — ListTile Material Runtime Hotfix

## السبب

تشغيل `flutter run -d chrome` نجح، لكن Console أظهر runtime assertion متكررًا:

```text
ListTile background color or ink splashes may be invisible.
```

السبب أن `ListTile` / `SwitchListTile` موجود داخل `DecoratedBox` بخلفية بيضاء من `SharedAdminSurfaceCard`. Flutter يحتاج أن يرسم ListTile التأثيرات على أقرب `Material` ancestor، وليس خلف `DecoratedBox`.

## التصحيح

تم تعديل:

```text
lib/presentation/screens/admin/main/management/home_management/widgets/shared/shared_content_admin_ui.dart
```

وتحديدًا `SharedAdminSurfaceCard`:

- قبل التصحيح: `Container + BoxDecoration`
- بعد التصحيح: `Material + RoundedRectangleBorder + elevation`

## ما حافظنا عليه

- اللون الأبيض للكروت.
- الحواف الدائرية.
- الحدود.
- الظل/elevation.
- لا تغيير في البيانات.
- لا SQL.
- لا RLS.
- لا تحويل CMS إلى RPC.

## المطلوب بعد التطبيق

```bash
flutter analyze
flutter run -d chrome
```

ثم افتح:

```text
/admin/media-center/news
/admin/media-center/announcements
```

المتوقع أن تختفي رسائل:

```text
ListTile background color or ink splashes may be invisible
```
