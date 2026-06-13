
# FILE_CENTER_STORAGE_MAPPING_UNIT_AWARE_SCOPE_BEFORE_APPLY

## التصحيح

تم تعديل مسار ربط ملفات Storage ليأخذ الوحدات الإدارية بعين الاعتبار.

## القاعدة

لا نستنتج الوحدة الإدارية من اسم الملف أو اسم الـ bucket.

## القيم الافتراضية لأي ملف Storage غير مربوط بمالك واضح

```text
owner_unit_id = null
governorate_code = null
scope_type = storage_only
scope_id = null
visibility_scope = restricted
unit_assignment_status = unassigned
```

## لماذا؟

لأن الملف قد يتبع:

```text
وزارة
محافظة
مديرية
وحدة
طلب خدمة
قضية
أصل وقفي
مهمة ذكاء وثائقي
```

ولا يجوز أن يظهر لوحدة غير مختصة دون ربط صريح.

## ما تمنعه الحزمة

```text
لا ربط وحدة بالاستنتاج
لا public visibility دون owner mapping
لا fake service attachment
لا fake media asset
لا حذف ملفات
لا تعديل storage.objects
لا RLS mutation
لا service_role
لا production approval
```

## الحالة

```text
operator-apply-pending
```
