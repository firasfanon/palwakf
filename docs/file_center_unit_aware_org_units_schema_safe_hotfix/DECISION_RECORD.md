# Decision Record

```json
{
  "batch": "FILE_CENTER_UNIT_AWARE_ORG_UNITS_SCHEMA_SAFE_HOTFIX",
  "date": "2026_06_12",
  "base": "file_center_storage_mapping_unit_aware_scope_before_apply_2026_06_12.zip",
  "trigger_error": "ERROR 42703 column type does not exist",
  "cause": "Diagnostic referenced optional core.org_units.type directly.",
  "fix": "Use to_jsonb(ou)->>'field' for optional org_units fields in diagnostics and wrapper.",
  "status": "file-center-unit-aware-org-units-schema-safe-hotfix-ready / org-units-type-column-error-fixed / optional-org-unit-fields-jsonb-projected / default-restricted-unassigned-scope-preserved / no-file-deletion / no-storage-mutation / no-fake-owner-records / no-rls-mutation / no-service-role / production-not-approved / operator-apply-pending"
}
```
