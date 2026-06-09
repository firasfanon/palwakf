# Executive Runbook — Public Legacy Exact Body + Mapping Gap Result Intake

## Current decision

```text
PUBLIC_LEGACY_EXACT_BODY_AND_MAPPING_GAP_RESULT_INTaken_REWRITE_BLOCKED
```

## Run order

Only read-only scripts are allowed:

```text
01_RESULT_INTAKE_READ_ONLY.sql
02_EXACT_RUNTIME_DEPENDENCY_CLASSIFIER_READ_ONLY.sql
03_SERVICE_NAVIGATION_OWNER_SEPARATION_READ_ONLY.sql
04_REWRITE_GATE_STILL_BLOCKED_READ_ONLY.sql
05_NEXT_DECISION_GATE_READ_ONLY.sql
```

## Do not run

```text
No DROP / DELETE / ARCHIVE / RENAME
No DDL/DML/GRANT
No exact table replacement
No Auth/RBAC helper rewrite
No Media/Service SQL02
```
