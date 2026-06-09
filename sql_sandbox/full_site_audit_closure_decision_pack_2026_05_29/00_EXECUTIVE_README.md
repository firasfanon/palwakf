# Full Site Audit Closure Decision Pack — SQL Sandbox

This folder contains read-only decision markers only.

Run order, if SQL evidence markers are desired:

```text
01_FULL_SITE_AUDIT_CLOSURE_STATUS_READ_ONLY.sql
02_FULL_SITE_AUDIT_PRODUCTION_GATE_READ_ONLY.sql
```

These scripts do not read or modify application tables. They only emit static decision rows for governance evidence.

Forbidden in this pack:

```text
DDL
DML
GRANT / REVOKE
DROP / DELETE / ARCHIVE
exact public table replacement
Auth/RBAC helper rewrite
auth.users migration
waqf / waqf_assets / awqaf_system / GIS mutation
```
