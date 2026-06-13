# Next Decision

The map alone does not fix the current `rpc_waqf_asset_detail_v1` 403.

Choose one later:

1. Renew/add explicit `waqf_asset_rbac_assignments`.
2. Modify `waqf.has_waqf_asset_permission_v1` to consult the map.
3. Keep the map as a canonical policy table only.
