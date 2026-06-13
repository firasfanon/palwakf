# Runbook

Run:

1. `00_READ_ME_FIRST.sql`
2. `01_PREFLIGHT_assignment_context_read_only.sql`
3. `02_APPLY_renew_or_insert_super_admin_assignment.sql`
4. `03_VERIFY_assignment_effective_read_only.sql`
5. `04_AUTHENTICATED_ASSET_DETAIL_RPC_SMOKE_read_only.sql`
6. `05_FINAL_GATE_read_only.sql`

Do not run `98_ROLLBACK_reexpire_known_assignment_optional.sql` unless rollback is explicitly required.
