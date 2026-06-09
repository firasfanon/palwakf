# Full Site Audit After Media + Service Closure — Runbook

This pack is read-only and audit-oriented.

## Run Order

1. `01_FULL_SITE_AUDIT_SCOPE_AND_STATUS_READ_ONLY.sql`
2. `02_FULL_SITE_AUDIT_ROUTE_MATRIX_READ_ONLY.sql`
3. `03_AUTH_TOKEN_400_CLASSIFICATION_READ_ONLY.sql`
4. `04_FULL_SITE_AUDIT_PRODUCTION_GATE_READ_ONLY.sql`

## Important

These scripts do not approve production and do not modify data.
They exist to standardize evidence intake and prevent resuming unsafe Wave A execution.
