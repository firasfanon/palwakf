# Governing Contract Appendix — Technical Services Dashboard

## Rule

Technical services in PalWakf must be governance-first. The admin dashboard may expose readiness pages for backup, maintenance, health, deployment, and audit, but it must not execute sensitive backend operations directly from Flutter.

## Binding Constraints

- Flutter must not contain `service_role` keys.
- Backup and restore operations require backend contracts, approval status, audit records, and rollback plans.
- Maintenance mode requires a central backend flag and shell-level read behavior before activation.
- Health checks must be read-only.
- Audit records must not be deletable from the UI.
- Production approval requires explicit browser evidence, SQL/RPC evidence where relevant, and rollback documentation.

## Current Status

`frontend-routes-prepared / backend-actions-deferred / production-not-approved`
