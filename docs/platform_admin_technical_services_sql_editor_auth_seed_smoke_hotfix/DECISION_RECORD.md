# Decision Record

```json
{
  "batch": "Platform Technical Services — SQL Editor Auth / Seed / Smoke Hotfix",
  "date": "2026-06-11",
  "base": "platform_admin_technical_services_real_operations_mega_batch_2026_06_11.zip",
  "classification": "SQL_EDITOR_AUTH_CONTEXT_AND_SEED_AUTH_GUARD_MISMATCH",
  "fixes": [
    "04 seed no longer calls auth-protected public RPC from SQL Editor",
    "06A concrete authenticated smoke added for known user UUID",
    "06B admin_users resolver helper added"
  ],
  "known_user_id": "96f6cdc2-67f9-4352-b9f8-775ef509fed8",
  "runtime_auth_weakened": false,
  "backup_restore_execution": false,
  "maintenance_mode_global_activation": false,
  "sovereign_business_data_mutation": false,
  "production_approved": false,
  "status": "staging-sql-hotfix-ready / platform-technical-backend-contract-structurally-prepared / seed-script-sql-editor-safe / authenticated-smoke-concretized / runtime-auth-preserved / no-backup-restore-execution / no-maintenance-activation / production-not-approved"
}
```
