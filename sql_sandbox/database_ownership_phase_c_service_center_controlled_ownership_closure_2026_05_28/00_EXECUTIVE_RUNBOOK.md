# Database Ownership Phase C — Service Center Controlled Ownership Closure

## Executive runbook

This is a single large controlled package for Service Center ownership closure. It supersedes micro-patch execution for this track.

## Scope

- Owner schema: `platform_services`.
- Public/API compatibility surface: `public.v_services_catalog_compat_v1` and public service-center RPC wrappers.
- Legacy public service catalog/request tables are preserved until a later dependency-zero and archive decision.
- Media Center is already closed as Phase B and is not modified here.
- Auth/RBAC helper rewrites remain outside this phase.
- `waqf`, `waqf_assets`, `awqaf_system`, and GIS are out of scope.

## Files

1. `01_SERVICE_CENTER_MASTER_CENSUS_READ_ONLY.sql` — one full decision census.
2. `02_SERVICE_CENTER_ONE_SHOT_CONTROLLED_APPLY_GUARDED.sql` — guarded apply, only if the census proves gaps and the operator explicitly replaces the guard token after backup.
3. `03_SERVICE_CENTER_POST_APPLY_VALIDATION_READ_ONLY.sql` — validation for current state or post-apply state.
4. `04_SERVICE_CENTER_BROWSER_UAT_AND_RUNTIME_MATRIX_READ_ONLY.sql` — required browser/network UAT matrix.
5. `05_SERVICE_CENTER_FINAL_CLOSURE_GATE_READ_ONLY.sql` — final closure gate marker.

## Current execution rule

Run `01` first. If it proves the required owner schema/tables/RPCs/catalog wrapper are already present, do not run `02`; proceed to `03`, `04`, and browser evidence.

`02` is a guarded one-shot controlled apply. It is not exploratory and must not run unless:

- a fresh DB backup exists;
- `01` proves required gaps;
- the operator deliberately replaces the guard token and backup marker;
- the intended result is reviewed before execution.

## Hard boundaries

No `DROP TABLE`, no `DELETE`, no archive, no exact public table replacement, no `auth.users` migration, no Flutter elevated secret, no waqf/awqaf/GIS mutation.
