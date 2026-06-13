
# Document Lifecycle View Replace Order Hotfix

## Trigger

Apply failed with:

```text
ERROR: 42P16: cannot change name of view column "created_at" to "confidentiality_level"
HINT: Use ALTER VIEW ... RENAME COLUMN ... to change name of view column instead.
```

## Cause

PostgreSQL does not allow `CREATE OR REPLACE VIEW` to change existing column names/order.  
The lifecycle-aware wrapper inserted new columns before an existing `created_at` column.

## Fix

Drop only the two public wrappers, then recreate them with the lifecycle-aware projection:

```text
public.v_document_center_service_attachments_v1
public.v_document_center_media_assets_v1
```

## Preserved

```text
no file deletion
no storage.objects mutation
no owner schema exposure
no RLS mutation
no service_role
production-not-approved
```
