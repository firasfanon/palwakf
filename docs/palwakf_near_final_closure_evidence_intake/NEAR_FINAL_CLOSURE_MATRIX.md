
# PalWakf Near-Final Closure Matrix

## Accepted Evidence

| Item | Status | Decision |
|---|---|---|
| `flutter analyze` | Passed | `ANALYZER_CLEAN_ACCEPTED` |
| CMS payload contract tests | Passed | `CMS_CONTRACT_TESTS_ACCEPTED` |
| Smoke Suite | Passed 4/4 | `SMOKE_SUITE_AUTHENTICATED_FULL_PASS_ACCEPTED` |
| CMS Add News | HTTP 201 | `CMS_ADD_NEWS_NETWORK_VERIFIED` |
| Technical Services protected RPC | HTTP 200 | `TECHNICAL_SERVICES_PROTECTED_RPC_VERIFIED` |
| Technical Services Operations Center | Screenshot visible | `TECHNICAL_SERVICES_OPERATIONS_CENTER_BROWSER_CERTIFIED` |
| RBAC role/permission/scope tables | Present under platform_access | `RBAC_PLATFORM_ACCESS_STRUCTURAL_EVIDENCE_ACCEPTED` |
| RBAC public/admin/core identity columns | Present | `RBAC_IDENTITY_SURFACES_PARTIAL_EVIDENCE_ACCEPTED` |

## Still Pending

| Item | Missing Evidence | Required Decision |
|---|---|---|
| RBAC FK to auth.users | `identity_foreign_keys` result not pasted | `RBAC_IDENTITY_SOURCE_OF_TRUTH_PLATFORM_ACCESS_ACCEPTED` |

## Overall Decision

```text
PALWAKF_NEAR_FINAL_CLOSURE_ACCEPTED_RBAC_AUTH_USERS_FK_PENDING
```

## Final Closure Condition

To fully close the stabilization gate, paste the result of the FK section only:

```sql
select
  'identity_foreign_keys' as section,
  tc.table_schema,
  tc.table_name,
  tc.constraint_name,
  kcu.column_name,
  ccu.table_schema as foreign_table_schema,
  ccu.table_name as foreign_table_name,
  ccu.column_name as foreign_column_name
from information_schema.table_constraints tc
join information_schema.key_column_usage kcu
  on tc.constraint_name = kcu.constraint_name
 and tc.table_schema = kcu.table_schema
join information_schema.constraint_column_usage ccu
  on ccu.constraint_name = tc.constraint_name
 and ccu.table_schema = tc.table_schema
where tc.constraint_type = 'FOREIGN KEY'
  and (
    (tc.table_schema = 'platform_access' and tc.table_name = 'admin_users')
    or (tc.table_schema = 'core' and tc.table_name = 'admin_users')
    or (tc.table_schema = 'public' and tc.table_name = 'admin_users')
  )
order by tc.table_schema, tc.table_name, tc.constraint_name;
```
