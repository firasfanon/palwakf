
# تصحيح core.org_units schema-safe

## الخطأ

```text
ERROR: 42703
column "type" does not exist
```

## السبب

استعلام الجرد قرأ:

```text
core.org_units.type
```

بينما العمود غير موجود في جدول الوحدات الفعلي.

## التصحيح

تم استخدام قراءة آمنة للأعمدة الاختيارية:

```text
to_jsonb(ou)->>'unit_type'
to_jsonb(ou)->>'type'
to_jsonb(ou)->>'name_ar'
to_jsonb(ou)->>'slug'
```

## الحوكمة محفوظة

```text
لا استنتاج للوحدة من اسم الملف
الافتراضي restricted + unassigned
لا حذف ملفات
لا تعديل storage.objects
لا fake owner records
لا RLS mutation
لا service_role
لا production approval
```
