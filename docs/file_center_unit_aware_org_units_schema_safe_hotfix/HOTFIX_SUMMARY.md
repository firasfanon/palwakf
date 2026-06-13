
# File Center Unit-aware Org Units Schema-safe Hotfix

## Trigger

The read-only inventory failed with:

```text
ERROR: 42703: column "type" does not exist
LINE 45: type,
```

## Cause

The diagnostic query assumed `core.org_units.type` exists. The actual table contract differs.

## Fix

Use schema-safe optional-field reads:

```sql
to_jsonb(ou)->>'unit_type'
to_jsonb(ou)->>'type'
to_jsonb(ou)->>'name_ar'
to_jsonb(ou)->>'slug'
```

This avoids direct references to optional columns.

## Also Fixed

The runtime wrapper projection now uses schema-safe org unit fields too:

```text
owner_unit_name_ar
owner_unit_slug
owner_unit_type
```

## Preserved

```text
no administrative unit inference
default restricted/unassigned
no file deletion
no storage.objects mutation
no fake owner records
no RLS mutation
no service_role
production-not-approved
```
