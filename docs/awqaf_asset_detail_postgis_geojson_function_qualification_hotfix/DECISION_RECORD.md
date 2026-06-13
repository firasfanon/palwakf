# Decision Record

```json
{
  "batch": "Awqaf Asset Detail — PostGIS GeoJSON Function Qualification Hotfix",
  "date": "2026-06-10",
  "authorization": "User authorized Awqaf Asset Detail — PostGIS GeoJSON Function Qualification Hotfix",
  "base": "awqaf_asset_detail_explicit_assignment_renewal_hotfix_2026_06_10.zip",
  "cause": "PostGIS extension is installed in schema extensions and waqf.rpc_waqf_asset_detail_v1 used unqualified st_asgeojson while function search_path was waqf, public, auth.",
  "target_function": "waqf.rpc_waqf_asset_detail_v1(uuid)",
  "change": "Replace st_asgeojson(g.geom) and st_asgeojson(g.centroid) with extensions.st_asgeojson(...).",
  "scope": {
    "ddl_authorized": true,
    "ddl_target": "waqf.rpc_waqf_asset_detail_v1(uuid) only",
    "dml_authorized": false,
    "rbac_change": false,
    "waqf_assets_mutation": false,
    "waqf_assets_table_grant": false,
    "flutter_changes": false,
    "awqaf_system_files": false,
    "production_approved": false
  },
  "status": "staging-apply-ready / awqaf-asset-detail-postgis-geojson-qualification-authorized / rbac-assignment-renewed-and-read-access-true / postgis-extension-schema-confirmed-extensions / waqf-rpc-asset-detail-function-qualification-prepared / no-dml / no-rbac-change / no-waqf-assets-mutation / no-flutter-changes / no-awqaf-system-files / production-release-not-approved-pending-rpc-smoke-and-browser-retest"
}
```
