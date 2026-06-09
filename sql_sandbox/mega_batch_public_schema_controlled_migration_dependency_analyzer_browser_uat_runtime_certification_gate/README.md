# Public Schema Controlled Migration — Dependency / Analyzer / Browser UAT Gate

**Batch:** `mega_batch_public_schema_controlled_migration_dependency_analyzer_browser_uat_runtime_certification_gate_2026_05_22`  
**Date:** 2026-05-22  
**Mode:** read-only certification gate; no DDL/DML; no destructive SQL.

## Files

1. `01_public_schema_dependency_surface_inventory_read_only.sql`  
   Inventories migrated public-table families, owner-shadow targets, DB views/functions that still reference legacy public tables, and expected compatibility surfaces.
2. `02_public_schema_runtime_certification_gate_read_only.sql`  
   Produces a certification decision. The decision must remain blocked unless dependency blockers are zero and Browser/Analyzer evidence is attached.
3. `03_public_schema_browser_uat_matrix_read_only.sql`  
   Emits the required manual browser/role/console matrix for the public runtime certification gate.

## Hard constraints

- No `DROP`, `DELETE`, `ARCHIVE`, `RENAME`, or exact public table-name replacement.
- No mutation to `waqf_assets`, `waqf`, or `awqaf_system`.
- `auth.users` is not migrated.
- `public` remains wrappers/RPC/views/aliases only.


## Route Console Closure + Phase 2 RBAC Planning Gate — 2026-05-23

Run order after Phase 1 retest:

1. `15_route_console_evidence_closure_read_only.sql`
2. `16_phase2_platform_access_rbac_planning_gate_read_only.sql`
3. `17_phase2_rbac_role_uat_matrix_read_only.sql`
4. `18_phase2_rbac_planning_sovereign_boundary_read_only.sql`

All four scripts are read-only. They do not authorize runtime reroute, exact replacement, destructive SQL, production approval, or any `waqf_assets/waqf/awqaf_system` mutation.

## 2026-05-23 — Phase 2 RBAC Adapter Remediation Implementation

Run order after applying the Phase 2 RBAC adapter remediation baseline:

1. `19_phase2_rbac_adapter_remediation_result_read_only.sql`
2. `20_phase2_rbac_role_rls_browser_uat_matrix_read_only.sql`
3. `21_phase2_rbac_dependency_recount_read_only.sql`
4. `22_phase2_rbac_implementation_sovereign_boundary_read_only.sql`

These scripts are read-only. They do not approve production, exact public table-name replacement, destructive SQL, or `waqf_assets/waqf/awqaf_system` mutation.

## 2026-05-23 — Development 9 Phase 3 Core/Admin/Auth + Owner-Write RPC Design Gate

Run order after applying the Development 9 pack:

1. `23_phase3_core_admin_auth_linkage_planning_gate_read_only.sql`
2. `24_phase3_core_admin_auth_static_dependency_evidence_read_only.sql`
3. `25_owner_write_rpc_design_contract_draft_not_run.sql`
4. `26_owner_write_rpc_readiness_and_rollback_gate_read_only.sql`
5. `27_role_rls_browser_console_evidence_intake_read_only.sql`
6. `28_production_gate_redecision_read_only.sql`

All six scripts are read-only/design-only. They do **not** create owner-write RPCs, do **not** authorize Flutter write reroute, do **not** migrate `auth.users`, do **not** approve production, and do **not** mutate `waqf_assets`, schema `waqf`, or `awqaf_system`.



## 2026-05-23 — Development 9A SQL24 Values Arity Hotfix + SQL23–28 Result Intake

The user supplied SQL output for Development 9 scripts `23`–`28`.

Accepted evidence:

- `23_phase3_core_admin_auth_linkage_planning_gate_read_only.sql` emitted the expected planning-only decision.
- `25_owner_write_rpc_design_contract_draft_not_run.sql` emitted the proposed RPC contract matrix and implementation rules.
- `26_owner_write_rpc_readiness_and_rollback_gate_read_only.sql` confirmed owner surfaces and wrappers are visible while proposed RPCs are not installed, as expected for design-only.
- `27_role_rls_browser_console_evidence_intake_read_only.sql` confirmed required evidence remains `not_supplied`.
- `28_production_gate_redecision_read_only.sql` confirmed production remains not approved.

Hotfix:

- `24_phase3_core_admin_auth_static_dependency_evidence_read_only.sql` previously failed with `ERROR 42601: VALUES lists must all be the same length` because `owner_write_blocker` rows had three values while the CTE expected four columns.
- Development 9A fixes SQL 24 by adding the explicit `observed_value = 'pending'` column to those rows.

Run recommendation after applying Development 9A:

1. Re-run SQL `24` only to validate the hotfix.
2. Optionally re-run SQL `26`, `27`, and `28` for a fresh consolidated gate output.
3. Do not proceed to owner-write RPC implementation until explicit review of RPC bodies, RLS/audit/search_path/rollback contract, and role/browser evidence are supplied.

---

## Development 9B SQL26 Core Schema-Safe Catalog Hotfix — 2026-05-23

User reported:

```text
ERROR 42P01: relation "core" does not exist
```

SQL 26 has been rewritten to avoid relation-style resolution of `core.admin_users` and `platform.*` owner surfaces. It now probes:

- `pg_namespace`
- `pg_class`
- `pg_proc`
- `pg_get_function_arguments`

This is still read-only and does not create owner-write RPCs.

Retry mandatory:

```text
26_owner_write_rpc_readiness_and_rollback_gate_read_only.sql
```

Optional after success:

```text
27_role_rls_browser_console_evidence_intake_read_only.sql
28_production_gate_redecision_read_only.sql
```


## 2026-05-23 — Development 9C SQL26 Retest Result Intake + Runtime Preflight Gate

The user supplied a successful re-run output for SQL `26_owner_write_rpc_readiness_and_rollback_gate_read_only.sql` after Development 9B.

Accepted evidence:

- `core.admin_users` is visible via schema-safe `pg_namespace/pg_class` probing.
- `platform.platform_permissions`, `platform.platform_systems`, `platform.user_system_permissions`, and `platform.user_system_roles` are visible via schema-safe catalog probing.
- Public compatibility wrappers are visible:
  - `public.v_core_admin_users_compat_v1`
  - `public.v_platform_permissions_compat_v1`
  - `public.v_platform_systems_compat_v1`
  - `public.v_platform_user_system_permissions_compat_v1`
  - `public.v_platform_user_system_roles_compat_v1`
- Proposed owner-write RPCs are still not installed, which is expected for the design-only state.
- Sovereign boundary remains clean: no `waqf_assets`, schema `waqf`, or `awqaf_system` DDL/DML.

Still pending:

- Role/RLS/Browser Console evidence remains `not_supplied`.
- Owner-write RPC implementation is not authorized yet.
- Core/Admin/Auth runtime remediation is not executed yet.
- Production remains not approved.

New read-only helper added:

- `29_phase3_runtime_remediation_owner_write_rpc_preflight_gate_read_only.sql`

This helper records the preflight decision only. It does not create RPCs, reroute runtime, or mutate data.


---

## Development 9D — Runtime Read Adapter Remediation + Owner-Write RPC Preflight Review

Added read-only scripts:

- `30_phase3_runtime_read_adapter_remediation_static_uat_read_only.sql`
- `31_owner_write_rpc_implementation_preflight_review_gate_read_only.sql`

Development 9D remediates Flutter read paths only:

- `lib/core/access/access_repository.dart`
- `lib/data/repositories/admin_users_repository.dart`
- `lib/data/repositories/auth_repository.dart`
- `lib/features/tasks_system/data/repositories/admin_users_repository.dart`
- `lib/features/tasks_system/data/repositories/auth_repository.dart`

Read surface now used for core/admin profile reads:

```text
public.v_core_admin_users_compat_v1
```

Owner-write RPC implementation remains blocked. No function creation, write reroute,
exact public table-name replacement, destructive SQL, `auth.users` migration, service_role
inside Flutter, or `waqf_assets` mutation is authorized by this batch.


---

## Development 9E — Owner-Write RPC Body Review + Implementation Gate Decision

Added read-only scripts:

- `32_owner_write_rpc_body_review_contract_read_only.sql`
- `33_owner_write_rpc_implementation_gate_decision_read_only.sql`

Development 9E accepts SQL 30/31 results and records that runtime read-adapter remediation is closed, while owner-write RPC implementation remains blocked.

No `CREATE FUNCTION`, `GRANT`, DDL, DML, Flutter write reroute, `auth.users` migration, destructive SQL, exact public table-name replacement, service_role in Flutter, or `waq_assets` mutation is authorized.


## Platform Development 10A

Added read-only SQL 42–45 to intake the execution token and keep implementation blocked until exact bodies and evidence are supplied. These scripts do not create functions, grants, runtime reroutes, DDL, or DML.

## Platform Development 10A Final SQL42–45 Result Intake — 2026-05-23

- Added `46_platform_development_10a_final_result_intake_10b_gate_read_only.sql`.
- This is a final result-intake gate only.
- It records that the authorization token is present but not sufficient alone.
- 10B remains blocked until exact SQL bodies and Negative UAT/Role-RLS/Browser Console evidence are supplied.
- No CREATE FUNCTION, no GRANT, no DDL/DML, no waqf_assets mutation.
