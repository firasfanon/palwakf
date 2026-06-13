# Browser UAT Checklist

Run after SQL apply and Flutter build:

```bash
flutter analyze
flutter run -d chrome
```

Routes:

- `/admin/platform/technical-services`
- `/admin/platform/technical-services/backup`
- `/admin/platform/technical-services/maintenance`
- `/admin/platform/technical-services/health`
- `/admin/platform/technical-services/deployment`
- `/admin/platform/technical-services/audit`

Expected:

- Dashboard loads with backend connected status.
- Metrics appear from `rpc_platform_technical_services_dashboard_v1`.
- Backup request form creates a request through RPC.
- Maintenance window form creates a planned window.
- Health refresh calls `rpc_platform_technical_health_snapshot_refresh_v1`.
- Release form records a release.
- Audit page shows created audit events.
- No service_role appears in browser code.
- No backup/restore/export is executed from Flutter.
- Console has no new blocking errors from technical services.
