
# مركز الوثائق الموحّد

## القرار

```text
PALWAKF_DOCUMENT_CENTER_UNIFICATION_AND_LIFECYCLE_GOVERNANCE_MEGA_BATCH
```

## ماذا تم؟

تحويل `/admin/documents` من شاشة static إلى بوابة موحدة تقرأ من:

```text
document-intelligence
platform_services.service_request_attachments
media_center.content_assets
```

## الفكرة الحوكمية

الملفات ليست نوعًا واحدًا:

```text
مؤقت
تشغيلي
مرجع طويل الأمد
دليل قانوني
إعلامي عام
```

لذلك تم تجهيز سياسة lifecycle وSQL drafts لسجل أنواع الوثائق، دون تطبيق SQL.

## ما لم يتم؟

```text
لا SQL apply
لا RLS apply
لا حذف
لا جدول content_attachments مكرر
لا service_role
لا production approval
```
