
# RBAC Auth Users Link Remediation Result Intake Template

## Required Result Sections

Paste results for:

1. `identity_table_presence`
2. `identity_row_counts`
3. `platform_access_admin_to_auth_orphans`
4. `platform_access_admin_to_auth_sample_orphans`
5. `platform_access_admin_to_auth_matches`
6. `platform_access_auth_email_mismatch_count`
7. `platform_access_auth_email_mismatch_sample`
8. `admin_id_presence_across_surfaces`
9. `admin_email_presence_across_surfaces`
10. `current_auth_context`
11. `current_platform_access_admin_resolution`
12. `view_dependencies_text`
13. `routine_dependencies_text`

## Decision Outcomes

| Evidence | Decision |
|---|---|
| orphans = 0, current user resolves, dependencies safe | `RBAC_AUTH_USERS_PHYSICAL_FK_READY_FOR_AUTHORIZED_APPLY_DESIGN` |
| orphans > 0 but current user resolves | `RBAC_LOGICAL_AUTH_CONTRACT_RECOMMENDED` |
| admin IDs do not match auth IDs | `RBAC_BRIDGE_TABLE_REQUIRED` |
| many dependencies on core/public admin_users | `RBAC_COMPATIBILITY_VIEW_REQUIRED` |
| current auth context cannot resolve | `RBAC_AUTH_CONTEXT_MAPPING_BLOCKED` |

## Paste Template

```text
identity_table_presence:
identity_row_counts:
platform_access_admin_to_auth_orphans:
platform_access_admin_to_auth_sample_orphans:
platform_access_admin_to_auth_matches:
platform_access_auth_email_mismatch_count:
platform_access_auth_email_mismatch_sample:
admin_id_presence_across_surfaces:
admin_email_presence_across_surfaces:
current_auth_context:
current_platform_access_admin_resolution:
view_dependencies_text:
routine_dependencies_text:
operator_decision:
notes:
```
