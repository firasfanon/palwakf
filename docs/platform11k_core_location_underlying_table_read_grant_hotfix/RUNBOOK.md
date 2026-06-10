# Runbook

Run order:

1. `00_READ_ME_FIRST.sql`
2. `01_PREFLIGHT_underlying_surface_acl_read_only.sql`
3. `02_APPLY_underlying_authenticated_read_grants.sql`
4. `03_VERIFY_underlying_acl_read_only.sql`
5. `04_AUTHENTICATED_RPC_SMOKE_read_only.sql`
6. `05_FINAL_GATE_read_only.sql`

After that, repeat Awqaf browser retest.
