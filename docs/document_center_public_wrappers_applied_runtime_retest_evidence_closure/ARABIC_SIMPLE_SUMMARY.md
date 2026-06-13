
# إغلاق تطبيق public wrappers لمركز الوثائق

## نتيجة SQL

```text
service_attachments_wrapper_present = true
media_assets_wrapper_present = true
service_attachments_authenticated_select = true
media_assets_authenticated_select = true
production_approved = false
```

## نتيجة التخزين

```text
document-intelligence = 5
media-gallery = 6
```

## نتيجة المتصفح

```text
/home/news يعمل ولا يظهر خطأ RenderFlex في اللقطة
/admin/documents يعمل ولا تظهر لوحة PGRST106
مركز الوثائق يعرض سجلات الذكاء الوثائقي
```

## القرار

```text
DOCUMENT_CENTER_PUBLIC_WRAPPERS_APPLIED_AND_RUNTIME_RETEST_PASSED
```

## الحدود

```text
لا RLS mutation
لا data mutation
لا service_role
لا production approval
```

## ملاحظة

بقاء مرفقات الخدمات أو أصول الإعلام = 0 لا يعني فشل الـ wrappers.  
يعني فقط أن الربط العددي/التصنيفي لهذه الأسطح يحتاج جردًا أو بيانات فعلية لاحقة.
