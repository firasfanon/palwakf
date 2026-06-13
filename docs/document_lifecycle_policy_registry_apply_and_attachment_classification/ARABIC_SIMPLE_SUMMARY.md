
# DOCUMENT_LIFECYCLE_POLICY_REGISTRY_APPLY_AND_ATTACHMENT_CLASSIFICATION

## الهدف

تطبيق سجل سياسات أنواع الوثائق ودورة الحياة، ثم تصنيف مرفقات الخدمات القائمة دون حذف أي ملفات.

## ما ستطبقه الحزمة

```text
platform_documents.document_types
seed document type policies
lifecycle columns على platform_services.service_request_attachments
تصنيف/backfill لمرفقات الخدمات
تحديث public wrappers لتعرض lifecycle metadata
```

## التصنيفات

```text
transient
operational
long_term_reference
legal_evidence
public_media
```

## الحدود

```text
لا حذف ملفات
لا تعديل storage.objects
لا حذف أو تعديل destructive في media_center
لا RLS mutation
لا service_role في Flutter
لا production approval
```

## الحالة

```text
operator-apply-pending
```
