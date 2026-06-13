# Platform Admin Settings — Gateway Card Overflow Hotfix

## الدليل

بعد إصلاح TabController، صفحة `/admin/platform/technical-services` أصبحت تعمل.  
لكن عند فتح `/admin/settings` ظهر خطأ واجهي:

```text
A RenderFlex overflowed by 8.9 pixels on the bottom
```

الخطأ داخل بطاقات بوابة الإدارة، وليس في Backend.

## السبب

بطاقات `_GatewayCard` كانت تحتوي:

- padding ثابت 16
- أيقونة 44px
- عنوان
- وصف من سطرين

ومع قيود GridView الحالية أصبحت البطاقة قصيرة، فزاد المحتوى عموديًا عن المساحة المتاحة.

## التصحيح

تم تعديل `_GatewayCard` داخل:

```text
lib/presentation/screens/admin/main/management/settings/settings_screen.dart
```

ليستخدم:

- `LayoutBuilder`
- وضع compact عند ضيق البطاقة
- padding أصغر
- أيقونة أصغر
- `maxLines: 1` للعنوان
- وصف مرن داخل `Flexible`
- وصف سطر واحد في compact mode

## ما لم يتغير

- لا SQL.
- لا RLS.
- لا service_role.
- لا تغيير في RPC.
- لا تغيير في مسارات لوحة الخدمات التقنية.
