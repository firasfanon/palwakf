
# PalWakf Remaining Closure Evidence Gate

## Remaining Items

1. CMS Add News Network 201/200/204
2. Technical Services Operations Center browser screenshot
3. RBAC identity read-only SQL result intake

## Current Accepted Evidence

| Area | Status |
|---|---|
| Flutter analyze | Passed: `No issues found` |
| CMS payload contract tests | Passed: `All tests passed` |
| Smoke suite | Passed: `passed=4 skipped=0 failed=0` |
| SMK-08 Technical Services protected RPC | Passed: HTTP 200 with authenticated admin user token |

## Closure Matrix

| Item | Evidence Required | Current Status |
|---|---|---|
| CMS Add News | Network `/rest/v1/news_articles` with 201/200/204 | Pending |
| Technical Services Operations Center | Browser screenshot + RPC 200 | Pending screenshot |
| RBAC Identity | Read-only SQL result tables | Pending SQL result intake |

## Final Closure Decision Options

| All Required Evidence | Final Decision |
|---|---|
| All 3 completed | PALWAKF_STABILIZATION_CORE_CLOSURE_CERTIFIED |
| CMS pending only | PALWAKF_STABILIZATION_CLOSURE_DEFERRED_CMS_WRITE_EVIDENCE |
| Technical Services screenshot pending only | PALWAKF_STABILIZATION_CLOSURE_DEFERRED_TECHNICAL_BROWSER_EVIDENCE |
| RBAC SQL pending only | PALWAKF_STABILIZATION_CLOSURE_DEFERRED_RBAC_IDENTITY_EVIDENCE |
| More than one pending | PALWAKF_STABILIZATION_CLOSURE_PARTIAL_EVIDENCE_ONLY |

## Operator Instructions

### 1. CMS Add News

Open:

```text
/admin/media-center/news
```

Create a test news item. Capture Network:

```text
/rest/v1/news_articles
201 / 200 / 204
```

### 2. Technical Services Operations Center

Open:

```text
/admin/platform/technical-services
```

Capture visible:

```text
مركز الإغلاق التشغيلي والأدلة
Evidence
Notifications
Decisions
```

and Network:

```text
rpc_platform_technical_services_dashboard_v1
200
```

### 3. RBAC SQL

Run read-only SQL:

```text
sql_diagnostics/rbac_identity_source_of_truth/03_READ_ONLY_source_of_truth_evidence_gate.sql
```

Paste all result tables.
