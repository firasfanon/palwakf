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
/admin/settings
/admin/platform/technical-services
```

Expected Console:
- No `Controller's length property (8) ... children (9)`.
- No repeated `_GatewayCard` bottom RenderFlex overflow.
- Technical Services dashboard still opens.

## Technical Services Evidence

Network proof remains:

```text
/rpc/rpc_platform_technical_services_dashboard_v1
Status 200
```
