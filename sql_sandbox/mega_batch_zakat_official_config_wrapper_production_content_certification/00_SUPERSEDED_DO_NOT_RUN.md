# SUPERSEDED — DO NOT RUN AS FINAL ZAKAT OWNERSHIP

This SQL pack was prepared before the final Zakat ownership decision.
It made `platform_services.zakat_public_config` the owner of public Zakat config.

Final contract adopted on 2026-05-22:

- `zakat` schema owns Zakat operational rules/configuration.
- `billing_system` owns payments, receipts, and financial transactions.
- `platform_services` is limited to public service/request interfaces.
- `public` exposes read-only views/RPC wrappers only.

Use instead:

`sql_sandbox/mega_batch_zakat_domain_ownership_realignment_billing_integration_contract/`
