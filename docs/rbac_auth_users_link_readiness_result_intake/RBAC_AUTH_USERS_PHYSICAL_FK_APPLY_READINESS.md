
# RBAC Auth Users Physical FK Apply Readiness

## Status

```text
READY_FOR_AUTHORIZED_APPLY_DESIGN
```

## Preconditions Already Satisfied by Evidence

| Check | Result |
|---|---|
| `platform_access.admin_users` row count | 86 |
| `auth.users` row count | 86 |
| ID matches | 86 |
| Orphans | 0 |
| Email mismatches | 0 |

## Remaining Apply-Gate Requirements

Before any FK apply:

1. Explicit user authorization for DDL.
2. Backup/rollback plan.
3. Dependency review for routines/views using `admin_users`.
4. Confirm maintenance window or staging-first execution.
5. Run FK as `NOT VALID` first.
6. Validate constraint separately.
7. Browser/RPC regression test after apply.

## Recommended FK Apply Pattern

Use staged FK creation:

```text
ADD CONSTRAINT ... NOT VALID
VALIDATE CONSTRAINT ...
```

This reduces lock risk and separates creation from validation.

## Do Not Apply Yet

This package only certifies readiness for a future apply design.
