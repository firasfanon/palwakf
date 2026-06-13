# Browser UAT Checklist — Technical Services Final Closure

## Static checks

```bash
flutter analyze
flutter run -d chrome
```

## Routes

Open:

```text
/admin/platform/technical-services
/admin/platform/technical-services/backup
/admin/platform/technical-services/maintenance
/admin/platform/technical-services/health
/admin/platform/technical-services/deployment
/admin/platform/technical-services/audit
```

Expected:
- Route opens.
- Backend strip appears.
- Metrics appear.
- No compile error.
- No repeated critical Flutter assertion.

## Network proof

In DevTools → Network → Fetch/XHR, refresh the dashboard.

Expected:

```text
/rpc/rpc_platform_technical_services_dashboard_v1
Status 200
```

## Operations Center proof

On Overview or Audit page, verify:

```text
مركز الإغلاق التشغيلي والأدلة
Evidence
Notifications
Decisions
```

Expected:
- Counts render even if zero.
- Tables render empty-state safely if no rows.

## Closure status

This batch can be marked as browser-ready only after:
- `flutter analyze` returns clean or accepted warning-free output.
- Chrome runtime opens.
- Dashboard RPC returns 200.
- Operations Center is visible in browser.
