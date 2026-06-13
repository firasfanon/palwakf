# Decision Record

```json
{
  "batch": "Awqaf Asset Detail — Explicit Assignment Renewal Hotfix",
  "date": "2026-06-10",
  "authorization": "User authorized explicit assignment renewal hotfix",
  "base": "platform_role_permission_map_awqaf_assets_access_bridge_2026_06_10.zip",
  "target_user_id": "96f6cdc2-67f9-4352-b9f8-775ef509fed8",
  "target_permission": "waqf.assets.super_admin",
  "target_scope": {
    "scope_governorate_no": null,
    "scope_lgu_code": null
  },
  "target_asset_for_smoke": "721abf33-b243-4bd2-9ece-577128c2fdf4",
  "existing_assignment_id_observed": "48fe3365-b2b2-48c2-86d2-d475414d7ca2",
  "cause": "Existing waqf.assets.super_admin assignment was active but expired at 2026-05-10, so rpc_waqf_asset_detail_v1 raised WAQF_ASSETS_RBAC_DENIED.",
  "scope": {
    "dml_authorized": true,
    "dml_target": "waqf.waqf_asset_rbac_assignments only",
    "waqf_function_change": false,
    "waqf_assets_table_grant": false,
    "waqf_asset_mutation": false,
    "flutter_changes": false,
    "awqaf_system_files": false,
    "production_approved": false
  },
  "status": "staging-apply-ready / awqaf-asset-detail-explicit-assignment-renewal-authorized / target-user-super-admin-renewal-prepared / no-waqf-function-change / no-waqf-assets-table-grant / no-flutter-changes / no-awqaf-system-files / production-release-not-approved-pending-rpc-smoke-and-browser-retest"
}
```
