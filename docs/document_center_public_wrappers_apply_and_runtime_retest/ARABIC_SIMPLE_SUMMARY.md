
# DOCUMENT_CENTER_PUBLIC_WRAPPERS_APPLY_AND_RUNTIME_RETEST

## الهدف

تطبيق public wrappers آمنة حتى يقرأ `/admin/documents` من:

```text
public.v_document_center_service_attachments_v1
public.v_document_center_media_assets_v1
```

بدل القراءة المباشرة من:

```text
platform_services
media_center
```

## ما تم تجهيزه

```text
1. SQL apply للـ wrappers
2. SQL verification
3. SQL rollback
4. runtime retest runbook
5. closure template
```

## الحدود

```text
لا كشف مباشر للـ owner schemas
لا RLS mutation
لا data mutation
لا service_role في Flutter
لا production approval
```

## الحالة

```text
operator-apply-pending
```
