# Executive Runbook — Ownership Routing Contract + Schema Ownership Matrix

## Scope

Contract and matrix only.

## Do not run destructive SQL

```text
No DROP
No DELETE
No TRUNCATE
No RENAME
No archive
No exact public replacement
No Auth/RBAC rewrite
No waqf/GIS mutation
```

## Optional read-only scripts

```text
01_SCHEMA_OWNERSHIP_MATRIX_READ_ONLY.sql
02_PUBLIC_LEGACY_FREEZE_CLASSIFICATION_READ_ONLY.sql
03_PLATFORM_NAVIGATION_OWNER_TARGET_DESIGN_READ_ONLY.sql
04_NO_PUBLIC_NEW_TABLE_GATE_READ_ONLY.sql
05_PRODUCTION_GATE_READ_ONLY.sql
```

These scripts are evidence markers only.
