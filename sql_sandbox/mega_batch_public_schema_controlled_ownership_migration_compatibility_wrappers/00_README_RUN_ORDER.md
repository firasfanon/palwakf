# Mega Batch — Public Schema Controlled Ownership Migration + Compatibility Wrappers

Run order for Supabase SQL Editor:

1. `01_pre_migration_contract_guard_read_only.sql`
2. `02_controlled_shadow_owner_migration_apply.sql`
3. `03_public_compatibility_wrappers_apply.sql`
4. `04_post_migration_uat_read_only.sql`
5. `05_sovereign_boundary_read_only.sql`
6. `06_controlled_migration_gate_decision_read_only.sql`

## Contract

This pack performs controlled owner-shadow migration for high-priority public operational tables into their target schemas, while preserving public legacy tables.

It does **not**:
- drop or delete any public legacy table;
- rename public legacy tables;
- migrate `auth.users`;
- mutate `waqf`, `waqf_assets`, or `awqaf_system`;
- approve production or destructive archive/delete.

## Scope

- Platform shell/page/settings tables → `platform` shadow owner tables.
- Platform RBAC/access registry tables → `platform` shadow owner tables.
- User/admin linkage/cache tables → `core` shadow owner tables.
- Assistant/chat tables → `assistant` shadow owner tables.
- Public compatibility views/RPCs are created with `v_*_compat_v1` names, without replacing existing public table names.

Replacing old public table names with views, archiving, or deleting legacy tables is intentionally deferred until dependency-zero evidence and explicit approval.


## 2026-05-22 — SQL Result Intake Root-Fix Note

The original Script 04/06 used `to_regclass('public.rpc_public_schema_controlled_migration_status_v1()')` to detect a function. That is a function-presence false-negative pattern, because `to_regclass` is intended for relations, not procedures/functions.

Updated behavior:
- Script 04 and Script 06 now use `to_regprocedure('public.rpc_public_schema_controlled_migration_status_v1()')` for the status RPC presence check.
- Script 07 was added as a focused read-only retest.

If Scripts 02 and 03 already succeeded, do not rerun them. Run only:
1. `04_post_migration_uat_read_only.sql` (corrected), optional
2. `05_sovereign_boundary_read_only.sql`, optional
3. `06_controlled_migration_gate_decision_read_only.sql` (corrected), or run only
4. `07_status_rpc_presence_gate_retest_read_only.sql` (preferred focused retest)
