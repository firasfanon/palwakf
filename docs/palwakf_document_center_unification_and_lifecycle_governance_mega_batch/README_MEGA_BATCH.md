
# PALWAKF_DOCUMENT_CENTER_UNIFICATION_AND_LIFECYCLE_GOVERNANCE_MEGA_BATCH

## هدف الدفعة

تحويل `/admin/documents` من شاشة وثائق ثابتة إلى بوابة موحّدة تقرأ من الأسطح القائمة:

```text
document-intelligence
platform_services.service_request_attachments
media_center.content_assets
```

مع تجهيز طبقة حوكمة دورة حياة الوثائق:

```text
transient
operational
long_term_reference
legal_evidence
public_media
```

## ما تم تضمينه

- Flutter Document Center feature.
- ربط `/admin/documents` بالصفحة الموحدة الجديدة.
- Repository read-only يقرأ من الأسطح القائمة مع fallback آمن عند فشل سطح.
- SQL diagnostics لجرد الأسطح والجداول.
- SQL drafts فقط لسجل أنواع الوثائق وسياسات retention/lifecycle.
- Verification SQL.
- Governance docs.
- لا إنشاء جدول مرفقات مكرر.
- لا SQL apply.
- لا RLS apply.
- لا production approval.

## قرار معماري

لا نعتمد `media_center.content_attachments` كجدول جديد الآن.

الأولوية:

```text
استخدام media_center.content_assets للمركز الإعلامي
استخدام platform_services.service_request_attachments للخدمات
استخدام document_intelligence للمعالجة والتحليل
توحيد العرض والحياة الوثائقية عبر /admin/documents
```
