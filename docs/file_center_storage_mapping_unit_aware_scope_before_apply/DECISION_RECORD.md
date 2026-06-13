# Decision Record

```json
{
  "batch": "FILE_CENTER_STORAGE_MAPPING_UNIT_AWARE_SCOPE_BEFORE_APPLY",
  "date": "2026_06_12",
  "base": "controlled_file_center_source_record_seed_or_storage_object_mapping_2026_06_12.zip",
  "purpose": "Correct storage-object mapping so raw files are unit-aware, restricted, and unassigned until explicit administrative scope is provided.",
  "unit_governance_defaults": {
    "owner_unit_id": null,
    "governorate_code": null,
    "scope_type": "storage_only",
    "scope_id": null,
    "visibility_scope": "restricted",
    "unit_assignment_status": "unassigned"
  },
  "included": [
    "read-only unit inventory",
    "unit-aware file object registry apply SQL",
    "unit-aware storage wrapper",
    "integrity verification SQL",
    "rollback SQL",
    "runtime retest runbook"
  ],
  "boundaries": [
    "no administrative unit inference from file name",
    "no public visibility without owner mapping",
    "no fake service attachment rows",
    "no fake media asset rows",
    "no file deletion",
    "no storage.objects mutation",
    "no RLS mutation",
    "no service_role",
    "no production approval"
  ],
  "status": "file-center-storage-mapping-unit-aware-scope-package-ready / default-restricted-unassigned-scope-prepared / administrative-unit-inference-blocked / no-public-without-owner-mapping / no-fake-owner-records / no-file-deletion / no-storage-mutation / no-rls-mutation / no-service-role / production-not-approved / operator-apply-pending"
}
```
