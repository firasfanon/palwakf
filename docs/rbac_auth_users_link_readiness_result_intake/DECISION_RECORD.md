# Decision Record

```json
{
  "batch": "RBAC Auth Users Link Readiness Result Intake",
  "date": "2026_06_11",
  "base": "rbac_auth_users_link_remediation_design_2026_06_11.zip",
  "evidence": {
    "platform_access_admin_users_count": 86,
    "auth_users_count": 86,
    "matched_by_id_count": 86,
    "orphan_admin_users_count": 0,
    "email_mismatch_count": 0,
    "recommended_decision": "RBAC_AUTH_USERS_PHYSICAL_FK_READY_FOR_AUTHORIZED_APPLY_DESIGN",
    "ddl_dml_authorized": false,
    "read_only": true
  },
  "accepted_decisions": [
    "RBAC_AUTH_USERS_PHYSICAL_FK_READY_FOR_AUTHORIZED_APPLY_DESIGN",
    "PALWAKF_STABILIZATION_EVIDENCE_COMPLETE_RBAC_FK_READY_FOR_AUTHORIZED_APPLY_DESIGN"
  ],
  "not_performed": [
    "No SQL apply",
    "No FK creation",
    "No RLS change",
    "No production approval"
  ],
  "future_authorized_batch": "RBAC_AUTH_USERS_PHYSICAL_FK_AUTHORIZED_APPLY_CANDIDATE",
  "sql_apply": false,
  "ddl_dml_authorized": false,
  "rls_changed": false,
  "fk_created": false,
  "service_role_used": false,
  "production_approved": false,
  "status": "final-stabilization-evidence-complete / rbac-auth-users-link-ready-for-authorized-apply-design / platform-access-admin-users-86 / auth-users-86 / matched-by-id-86 / orphan-admin-users-0 / email-mismatch-0 / no-sql-apply / no-fk-created / no-rls-change / no-service-role / production-not-approved"
}
```
