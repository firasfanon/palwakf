# Decision Record

```json
{
  "batch": "Platform Technical Services — Dashboard RPC created_at Order Hotfix",
  "date": "2026-06-11",
  "base": "platform_admin_technical_services_sql_editor_auth_seed_smoke_hotfix_2026_06_11.zip",
  "error": "ERROR 42703: column x.created_at does not exist",
  "root_cause": "backups aggregate ordered by x.created_at while backup subquery did not select created_at",
  "fix": "replace public.rpc_platform_technical_services_dashboard_v1 body and include created_at in backup subquery",
  "table_ddl": false,
  "rls_change": false,
  "runtime_auth_weakened": false,
  "backup_restore_execution": false,
  "maintenance_mode_global_activation": false,
  "sovereign_business_data_mutation": false,
  "production_approved": false,
  "status": "staging-sql-hotfix-ready / platform-technical-dashboard-rpc-created-at-order-fixed / backend-contract-preserved / runtime-auth-preserved / no-ddl / no-rls-change / no-backup-restore-execution / production-not-approved"
}
```
