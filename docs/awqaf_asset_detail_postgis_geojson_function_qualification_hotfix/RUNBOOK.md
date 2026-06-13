# Runbook

Run:

1. `00_READ_ME_FIRST.sql`
2. `01_PREFLIGHT_postgis_and_function_read_only.sql`
3. `02_APPLY_replace_waqf_asset_detail_rpc_qualified_postgis.sql`
4. `03_VERIFY_function_definition_and_rpc_smoke_read_only.sql`
5. `04_FINAL_GATE_read_only.sql`

Do not run 98 unless an explicit rollback is required.
