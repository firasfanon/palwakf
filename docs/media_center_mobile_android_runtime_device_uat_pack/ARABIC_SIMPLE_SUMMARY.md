
# تجهيز UAT لتطبيق Android

## الهدف

بعد نجاح بناء APK، ننتقل إلى اختبار تشغيل التطبيق فعليًا على جهاز Android أو Emulator.

## ما أضيف

```text
scripts/uat_media_center_android_runtime.ps1
docs/.../ANDROID_RUNTIME_UAT_CHECKLIST.md
docs/.../RUNBOOK.md
```

## ماذا يفعل السكربت؟

```text
1. يتحقق من وجود APK.
2. يبحث عن adb.
3. يعرض الأجهزة المتصلة.
4. يثبت APK.
5. يشغّل التطبيق.
6. يطبع قائمة اختبارات UAT اليدوية.
```

## المسارات المطلوب فحصها

```text
/app/media
/app/media-center
/app/media-center/publish
/app/media-center/drafts
```

## لا يوجد

```text
لا SQL
لا تعديل media_center
لا تعديل public
لا public base tables
لا service_role
لا production approval
```
