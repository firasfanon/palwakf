# Decision Record

```json
{
  "batch": "RBAC Auth Users Link Remediation Design",
  "date": "2026_06_11",
  "base": "palwakf_final_closure_evidence_complete_rbac_fk_absent_2026_06_11.zip",
  "trigger": "Final evidence showed identity_foreign_keys returned no rows.",
  "purpose": "Design safe remediation paths for linking platform_access administrative identity to auth.users.",
  "current_finding": "platform_access RBAC structure accepted, but physical FK to auth.users is absent/not proven.",
  "candidate_paths": {
    "A": "Physical FK platform_access.admin_users.id -> auth.users.id after zero-orphan proof",
    "B": "Logical auth contract via RPC/RLS helper using auth.uid()",
    "C": "Compatibility authority view for legacy/core/public identity surfaces",
    "D": "Bridge table if admin_user_id and auth_user_id cannot be identical"
  },
  "included": [
    "read-only diagnostics",
    "decision matrix",
    "SQL draft only for candidate paths",
    "result intake template"
  ],
  "not_included": [
    "no SQL apply",
    "no FK creation",
    "no RLS mutation",
    "no data migration",
    "no production approval"
  ],
  "sql_apply": false,
  "read_only_sql_diagnostics": true,
  "ddl_drafts_only": true,
  "rls_changed": false,
  "fk_created": false,
  "service_role_used": false,
  "production_approved": false,
  "status": "rbac-auth-users-link-remediation-design-ready / read-only-diagnostics-prepared / physical-fk-draft-prepared-no-apply / logical-auth-contract-draft-prepared-no-apply / compatibility-view-draft-prepared-no-apply / bridge-table-draft-prepared-no-apply / no-sql-apply / no-rls-change / no-fk-created / no-service-role / production-not-approved"
}
```
