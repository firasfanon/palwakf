# Platform Role Permission Map — Awqaf Assets Access Bridge

## القرار

تم تفويض `platform_role_permission_map`.

## المعنى المعماري

لا يجب توحيد أسماء أدوار المنصة وصلاحيات أوقاف سيستم حرفيًا.

الصحيح:

```text
Platform roles = أدوار عامة
System permissions = صلاحيات تخصصية
platform_role_permission_map = جسر الربط
```

## ما تنشئه الحزمة

`platform_access.platform_role_permission_map`

مع seed أولي لصلاحيات:

- `waqf.assets.read`
- `waqf.assets.review`
- `waqf.assets.manage`
- `waqf.assets.super_admin`

## ما لا تفعله

- لا تعدل `waqf.has_waqf_asset_permission_v1`
- لا تضيف assignments للمستخدمين
- لا تمنح SELECT على `waqf.waqf_assets`
- لا تعدل أصول الوقف
- لا تضيف كود Flutter أو ملفات Awqaf System
