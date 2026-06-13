# Runbook

Run:

1. `03A_FIX_dashboard_rpc_created_at_order.sql`
2. `06C_DASHBOARD_RPC_POST_FIX_SMOKE.sql`
3. `07_FINAL_GATE_read_only.sql`

Then proceed to:

```bash
flutter analyze
flutter run -d chrome
```

Browser UAT routes:

- `/admin/platform/technical-services`
- `/admin/platform/technical-services/backup`
- `/admin/platform/technical-services/maintenance`
- `/admin/platform/technical-services/health`
- `/admin/platform/technical-services/deployment`
- `/admin/platform/technical-services/audit`
