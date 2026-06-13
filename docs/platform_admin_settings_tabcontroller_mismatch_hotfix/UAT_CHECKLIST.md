# UAT Checklist

## Analyzer

```bash
flutter analyze
```

Expected:

```text
No issues found
```

## Runtime

```bash
flutter run -d chrome
```

Open:

```text
/admin/platform/technical-services
/admin/settings
```

Expected Console:
- No `Controller's length property (8) does not match ... children (9)`.

## Technical Services Network

Open DevTools → Network → Fetch/XHR and refresh:

```text
/rpc/rpc_platform_technical_services_dashboard_v1
```

Expected:

```text
Status 200
```

## Operations Center

Expected visible elements:

```text
Backend contract متصل
مركز الإغلاق التشغيلي والأدلة
Evidence
Notifications
Decisions
```
