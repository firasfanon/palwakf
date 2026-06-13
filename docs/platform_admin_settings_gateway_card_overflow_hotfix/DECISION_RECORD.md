# Decision Record

```json
{
  "batch": "Platform Admin Settings Gateway Card Overflow Hotfix",
  "date": "2026_06_11",
  "base": "platform_admin_settings_tabcontroller_mismatch_hotfix_2026_06_11.zip",
  "runtime_evidence": {
    "route": "/admin/settings",
    "exception": "A RenderFlex overflowed by 8.9 pixels on the bottom",
    "widget": "_GatewayCard / Column inside Ink / Padding",
    "technical_services_route": "/admin/platform/technical-services operational after previous hotfix"
  },
  "root_cause": "Gateway cards had fixed padding, 44px icon, title, and two-line description inside a short GridView cell; on narrower screens the vertical content exceeded available height.",
  "fix": [
    "Wrap _GatewayCard content with LayoutBuilder",
    "Use compact padding and icon size when cell height/width is constrained",
    "Limit title to one line",
    "Limit description to one line in compact mode and wrap it in Flexible",
    "Preserve route navigation and visual style"
  ],
  "changed_files": [
    "lib/presentation/screens/admin/main/management/settings/settings_screen.dart"
  ],
  "sql_changed": false,
  "rls_changed": false,
  "service_role_used": false,
  "production_approved": false,
  "status": "staging-code-ready / admin-settings-gateway-card-overflow-fixed / technical-services-runtime-preserved / no-sql / no-rls-change / production-not-approved"
}
```
