# Billing System Financial Contract Bootstrap + Zakat Payment Readiness Only — Root Safe Retest

## Current root-fix note

If the SQL Editor still returns:

```text
ERROR 42P01: relation "billing_system" does not exist
```

do **not** keep rerunning older open SQL tabs. Use the files in this folder from this baseline only.

The root fix removes all direct `billing_system.*` relation scans from read-only retest scripts and avoids `to_regclass('billing_system.*')`.

## Run order after the payload already appeared

Do not rerun `01` unless the readiness wrapper is missing. Run:

1. `04_billing_system_single_safe_retest_no_relation_refs.sql` — preferred consolidated retest.

Alternative:

1. `02_billing_system_zakat_payment_readiness_uat_read_only.sql`
2. `03_billing_system_sovereign_boundary_read_only.sql`

## Expected safe decision

```text
BILLING_READINESS_CONTRACT_PASSED_PAYMENT_WORKFLOW_DISABLED
```

or from script `02`:

```text
BILLING_CONTRACT_BOOTSTRAP_READY_PAYMENT_WORKFLOW_DISABLED
```

## Operational limits

- No payment workflow.
- No payment gateway.
- No receipt issuance.
- No transaction posting.
- No production financial approval.
- No waqf/waqf_assets/awqaf_system mutation.
