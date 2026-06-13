# Technical Services Operational Runbook

## Scope

This runbook governs the Platform Technical Services Center:

```text
/admin/platform/technical-services
/admin/platform/technical-services/backup
/admin/platform/technical-services/maintenance
/admin/platform/technical-services/health
/admin/platform/technical-services/deployment
/admin/platform/technical-services/audit
```

## Operating Principles

1. Flutter does not execute dangerous infrastructure operations.
2. Flutter records governed requests, evidence, decisions, and metadata.
3. Backup/restore requires request and approval.
4. Maintenance windows require planning and approval.
5. Health checks are read/refresh operations, not destructive actions.
6. Audit events are mandatory for decisions and operational changes.

## Lifecycle: Backup Registry

### Purpose

Record backup metadata, not execute raw backup/restore from Flutter.

### Flow

1. Admin creates backup request.
2. System records request metadata.
3. Authorized operator performs external backup process.
4. Evidence is attached.
5. Decision is recorded.
6. Request is closed.

### Evidence Required

- Backup ID/reference
- Timestamp
- Operator
- Storage reference
- Integrity/checksum if available
- Approval record

## Lifecycle: Maintenance Window

### Flow

1. Create planned maintenance window.
2. Approve window.
3. Publish user-facing maintenance status if required.
4. Execute maintenance outside Flutter.
5. Record evidence.
6. Complete or rollback.
7. Close decision.

### Required Fields

- Title
- Maintenance message
- Start time
- End time
- Affected surfaces
- Approval decision
- Completion evidence

## Lifecycle: Health Snapshot

### Flow

1. Admin opens System Health.
2. Health snapshot RPC runs.
3. Results are displayed.
4. Failures become technical service requests if required.
5. Evidence is attached for critical failures.

## Lifecycle: Audit Review

### Flow

1. Open Audit & Logs page.
2. Filter events by severity, service type, or date.
3. Review event details.
4. Escalate if required.
5. Record decision.

## RACI

| Activity | Responsible | Accountable | Consulted | Informed |
|---|---|---|---|---|
| Create request | Admin/Operator | Platform Admin | System Owner | Stakeholders |
| Approve request | Platform Admin | Super Admin | Technical Lead | Operator |
| Execute external action | Operator | Technical Lead | Platform Admin | Stakeholders |
| Attach evidence | Operator/Admin | Technical Lead | Auditor | Platform Admin |
| Close decision | Platform Admin | Super Admin | Auditor | Stakeholders |

## Closure Criteria

A technical operation is closed only when:

- request exists
- evidence is attached
- decision is recorded
- audit event exists
- final status is complete/closed/deferred with reason
