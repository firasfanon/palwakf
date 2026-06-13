# Decision Record

```json
{
  "batch": "Platform Admin Settings TabController Mismatch Hotfix",
  "date": "2026_06_11",
  "base": "platform_technical_services_final_operations_center_closure_2026_06_11.zip",
  "runtime_evidence": {
    "route": "/admin/platform/technical-services",
    "rpc": "rpc_platform_technical_services_dashboard_v1",
    "rpc_status": 200,
    "remaining_exception": "Controller's length property (8) does not match the number of children (9) present in TabBarView's children property"
  },
  "root_cause": "SettingsScreen used AdminPanelRegistry.tabs.length for DefaultTabController, but rendered AdminPanelRegistry.orderedGroups as TabBarView children. tabs=8, groups=9.",
  "fix": [
    "SettingsScreen now derives tabs from orderedGroups",
    "DefaultTabController length uses groups.length",
    "TabBar tabs and TabBarView children are generated from the same group list",
    "Fallback tab item is created for groups without an explicit AdminPanelRegistry.tabs entry"
  ],
  "changed_files": [
    "lib/presentation/screens/admin/main/management/settings/settings_screen.dart"
  ],
  "sql_changed": false,
  "rls_changed": false,
  "service_role_used": false,
  "production_approved": false,
  "status": "staging-code-ready / tabcontroller-8-vs-9-mismatch-fixed / technical-services-rpc-200-evidence-accepted / admin-settings-tabs-groups-aligned / no-sql / no-rls-change / production-not-approved"
}
```
