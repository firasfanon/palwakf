
# Technical Services Operations Center Browser Evidence Gate

## Objective

Close the Technical Services Operations Center browser view after authenticated smoke has already passed.

## Already Accepted

```text
SMK-08 — Technical Services dashboard RPC — HTTP 200
Smoke summary: passed=4 skipped=0 failed=0
```

## Required Route

```text
/admin/platform/technical-services
```

Optional secondary route:

```text
/admin/platform/technical-services/audit
```

## Required Visible UI Elements

The screenshot must show:

```text
مركز الإغلاق التشغيلي والأدلة
Evidence
Notifications
Decisions
```

or equivalent cards/counts.

## Required Network Evidence

DevTools → Network → Fetch/XHR:

```text
/rpc/rpc_platform_technical_services_dashboard_v1
Status 200
```

## Required Console State

Accepted:

```text
No critical Flutter runtime exception
No TabController length mismatch
No repeated RenderFlex overflow blocking the page
```

## Closure Decision

| Condition | Decision |
|---|---|
| Operations Center visible + RPC 200 + no critical runtime error | TECHNICAL_SERVICES_OPERATIONS_CENTER_BROWSER_CERTIFIED |
| RPC 200 but Operations Center not visible | TECHNICAL_SERVICES_BROWSER_VIEW_PENDING |
| Operations Center visible but RPC missing | TECHNICAL_SERVICES_NETWORK_EVIDENCE_PENDING |
| Console has blocking runtime exception | TECHNICAL_SERVICES_BROWSER_RUNTIME_BLOCKED |

## Evidence Paste Template

```text
Route:
Visible sections:
Network RPC:
Status:
Console:
Decision:
Notes:
```
