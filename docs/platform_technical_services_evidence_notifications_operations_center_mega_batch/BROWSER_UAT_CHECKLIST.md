# Browser UAT Checklist

SQL:
1. Run 00-06.
2. Verify dashboard smoke has evidence, notifications, operation_decisions.

Flutter:
1. `flutter analyze`
2. `flutter run -d chrome`

Browser:
- `/admin/platform/technical-services`
- `/admin/platform/technical-services/backup`
- `/admin/platform/technical-services/maintenance`
- `/admin/platform/technical-services/health`
- `/admin/platform/technical-services/deployment`
- `/admin/platform/technical-services/audit`

Expected:
- Metrics include Evidence and Notifications.
- Backend contract remains connected.
- Audit events remain visible.
- No backup/restore execution.
- No maintenance auto-activation.
