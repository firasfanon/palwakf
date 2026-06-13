
# FILE_CENTER_STORAGE_MAPPING_UNIT_AWARE_SCOPE_BEFORE_APPLY

## Purpose

Make the file-center storage mapping unit-aware before apply.

## Governance Rule

```text
Do not infer administrative units from storage file names or bucket names.
```

Default for raw storage objects:

```text
owner_unit_id = null
governorate_code = null
scope_type = storage_only
scope_id = null
visibility_scope = restricted
unit_assignment_status = unassigned
```

## Why

Different administrative units may have different access rights.  
A storage file can belong to a ministry-level process, a governorate, a unit, a service request, a legal case, a waqf asset, or a document job. Without explicit evidence, it must remain restricted.

## Operator Order

1. Read-only inventory:

```text
sql_diagnostics/file_center_storage_mapping_unit_aware_scope_before_apply/01_READ_ONLY_unit_aware_storage_mapping_inventory.sql
```

2. Apply:

```text
sql_apply/file_center_storage_mapping_unit_aware_scope_before_apply/01_APPLY_unit_aware_file_object_registry.sql
```

3. Verify:

```text
sql_verification/file_center_storage_mapping_unit_aware_scope_before_apply/01_VERIFY_unit_aware_file_object_registry.sql
```

4. Runtime retest:

```text
/admin/documents
```

## Acceptance Criteria

```text
registry_row_count = storage objects in document-intelligence + media-gallery
unassigned_count = registry_row_count initially
restricted_count = registry_row_count initially
unit_without_explicit_assignment_count = 0
public_without_owner_mapping_count = 0
unassigned_not_restricted_count = 0
```

## Rollback

```text
sql_rollback/file_center_storage_mapping_unit_aware_scope_before_apply/01_ROLLBACK_unit_aware_file_object_registry.sql
```
