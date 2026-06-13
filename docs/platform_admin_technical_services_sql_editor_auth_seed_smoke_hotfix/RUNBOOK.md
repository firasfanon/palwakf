# Runbook

Run in this order:

1. `00A_SQL_EDITOR_AUTH_SEED_SMOKE_HOTFIX_READ_ME.sql`
2. `04_SEED_initial_health_release_records.sql`
3. `05_VERIFY_backend_contract_read_only.sql`
4. `06A_AUTHENTICATED_RPC_SMOKE_KNOWN_USER.sql`
5. `07_FINAL_GATE_read_only.sql`

If `06A` fails with `PLATFORM_TECHNICAL_FORBIDDEN`, run:

`06B_ADMIN_USER_RESOLUTION_HELPER_read_only.sql`

Then send the result so the admin user resolver can be aligned.
