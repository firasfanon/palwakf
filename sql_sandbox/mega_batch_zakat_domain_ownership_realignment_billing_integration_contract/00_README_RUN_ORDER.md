# Mega Batch — Zakat Domain Ownership Realignment + Billing Integration Contract

Run order:

1. `01_zakat_domain_ownership_realignment_apply.sql`
2. `02_zakat_public_wrapper_post_apply_uat_read_only.sql`
3. `03_billing_integration_contract_read_only.sql`
4. `04_sovereign_boundary_read_only.sql`

This pack supersedes the earlier `platform_services.zakat_public_config` ownership model.
It creates the operational owner under `zakat`, keeps billing under `billing_system`, and exposes only `public` views/RPC wrappers.

No payment workflow is implemented here. Billing integration is a contract only.
