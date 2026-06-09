-- Platform Password Recovery Procedures Supplement Runtime Implementation
-- Read-only marker only. This pack does not require SQL execution.
select
  'platform_password_recovery_supplement_runtime_implementation' as section,
  false as ddl_dml_authorized,
  false as grant_revoke_authorized,
  false as production_approved,
  true as read_only,
  'Flutter routes and UAT contract only; do not execute DDL/DML from this pack.' as note;
