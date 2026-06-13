
# تصحيح خطأ View Column Order

## الخطأ

```text
ERROR: 42P16
cannot change name of view column "created_at" to "confidentiality_level"
```

## السبب

لا يمكن لـ PostgreSQL استخدام `CREATE OR REPLACE VIEW` عندما يتغير ترتيب أو أسماء أعمدة view موجودة.

## التصحيح

إسقاط public wrappers فقط، ثم إعادة إنشائها:

```text
public.v_document_center_service_attachments_v1
public.v_document_center_media_assets_v1
```

## الحدود

```text
لا حذف ملفات
لا تعديل storage.objects
لا كشف owner schemas
لا RLS mutation
لا service_role
لا production approval
```
