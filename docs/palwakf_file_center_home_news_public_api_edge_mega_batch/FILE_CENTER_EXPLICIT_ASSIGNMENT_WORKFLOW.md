
# FILE_CENTER_EXPLICIT_UNIT_ASSIGNMENT_AND_OWNER_RECORD_MAPPING_WORKFLOW

## Purpose

Add explicit assignment/mapping workflow for files already registered in:

```text
platform_documents.file_object_registry
```

## RPCs

```text
public.rpc_file_object_assign_unit_scope_v1
public.rpc_file_object_mark_owner_mapping_v1
```

These are public API-edge functions only. They do not make public the source of truth.

## Rules

```text
No automatic unit inference.
No public visibility through unit assignment RPC.
No fake owner records.
No file deletion.
No storage.objects mutation.
All changes are audited in platform_documents.file_object_mapping_events.
```
