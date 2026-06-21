# Platform 15K — 2026-06-21
- Added runtime payload normalization, explicit composition publication, and guarded runtime readback reconciliation.
- Staging candidate only; production not approved.

# Changelog

## 2026-06-20 — Platform 14 Universal Super Admin Authority Contract

- Added canonical owner-backed predicate `platform_access.fn_is_active_super_admin_v1`.
- Added protected Flutter authority reader `public.rpc_platform_effective_authority_v1`.
- Updated central unit scope and dynamic system gates to derive universal authority from the owner identity source.
- Updated Flutter `AccessRepository` to hydrate `AccessProfile.isSuperuser` from the owner-backed RPC before compatibility wrappers.
- No business data, user scopes, RLS, ACL, exposed schemas, or public base tables changed.
- Status: `APPLY_PREPARED / BROWSER_UAT_PENDING / PRODUCTION_NOT_APPROVED`.


## 2026-06-20 — Platform 14 Universal Super Admin Flutter Effective Authority Adoption
- Corrected Flutter adoption to call the applied parameterless self-authority RPC and parse its actual owner-side DTO.
- Removed Super Admin dependence on compatibility view/system-role/unit-scope hydration for route, sidebar, and cross-system UI visibility.
- Added session-aware cache invalidation and canonical DTO tests.
- No SQL, RLS, ACL, GRANT/REVOKE, workflow, publication, or business-data changes.

## 2026-06-20 — SystemKey Namespace Compile Hotfix
- Fixed the `SystemKey` type mismatch in `SystemSurfacesManagementScreen` by importing the core enum required by `AccessProfile.canManageSystem`.
- No behavior or database authorization contract changed.


## 2026-06-21 — Core Org Units Schema Qualification Runtime Closure
- Corrected invalid `core.core.org_units` PostgREST relation construction.
- Hardened Super User activity and unit context rendering.

## 2026-06-21 — Final Consolidated Handoff + Updated Baseline

- Consolidated the Platform 14 authority/runtime continuity state into a new baseline.
- Recorded the authoritative separation between applied Staging Foundation Database Authority and pending final Flutter compile/build/browser certification.
- Added a direct continuation prompt, UAT matrix, evidence index, open-gate registry, lineage record, and selected trigger evidence.
- Kept Super Admin domain RPC waves, Media Center least-privilege containment, RLS/ACL changes, and production promotion explicitly out of scope.


## 2026-06-21 — Platform 15F Admin Shell Material Boundary Runtime Hotfix

- Added a shared desktop `Material` boundary in `PlatformAdminShell` so the refactored `WebSidebar` and `_AdminTopStrip` interactive Material controls have a valid ancestor.
- Root cause: Chrome runtime error `No Material widget found` after Platform 15E sidebar information architecture work.
- Added focused import-aware contract test, PowerShell static verifier, validation runner, UAT runbook, error record, and handoff.
- No route, RBAC, database, Supabase, RLS, grant, or Media Center change.
- Candidate only; Flutter and browser evidence pending.

## 2026-06-21 — Platform 15G Unit Media Center Sovereign Administration

Added a dedicated scoped unit-media workspace at `/admin/unit-media-center`, context resolution from verified universal authority or explicit unit assignments, locked child editorial scopes, and exact unit-id resolution for administrative content reads. No SQL/RLS/grant/media-center exposure change. Validation and UAT remain pending.

## 2026-06-21 — Platform 15H Unit Operational Activation

- Added `/admin/unit-operations` to compose master unit activation, unit-surface publication, visibility, archival, and final public eligibility.
- Added a confirmed operational activation/deactivation action that reuses the existing `pwf_admin_update_unit_with_profile` repository path with an `is_active` patch only.
- Added contract test, ASCII-only PowerShell verifier, complete validation runner, UAT runbook, error record, and handoff.
- No SQL, RLS, grant, exposed-schema, public-runtime, or Media Center security change.
- Candidate only; activation RPC Network evidence and persisted readback remain pending.

## Platform 15H1 — Unit Operational Activation PowerShell Verifier ASCII Hotfix (2026-06-21)
- Replaced the Platform 15H static verifier with an ASCII-only Windows PowerShell 5.1-safe implementation.
- Fixed colon-delimited interpolation in forbidden-token diagnostics.
- No Flutter, SQL, RLS, grant, route, or Media Center runtime changes.

## Platform 15H2 — Unit Operational Activation Verifier Contract Alignment Hotfix (2026-06-21)
- Corrected a false-negative static verifier assertion path; no runtime source, database, access control, or route changes.

## 2026-06-21 — Platform 15H3
- Fixed direct extension import boundary for `PwfUnitPageVisibilityModeX.labelAr` in the Unit Operational Activation page.
- Updated the Platform 15H static verifier to require the direct import.
- No data or access-control mutation.

## Platform 15H4 — Unit Operational Activation Shared Store False Positive Scope Hotfix (2026-06-21)
- Corrected false-positive static verifier scope; no product behavior changed.

## Platform 15I1 — Runtime Composition Health Catch-Map Compile Hotfix (2026-06-21)

- Fixed a Dart map-literal syntax defect in `HomepageRepository.fetchRuntimeCompositionHealthForUnits` catch-path. The fallback health object now preserves the unit id as the map key.
- Root cause: the catch-path emitted `HomepageRuntimeCompositionHealth(...)` without `id:` inside a `Map<String, HomepageRuntimeCompositionHealth>` literal, which blocked Chrome compilation before the public-home and unit-publication reconciliation runtime could load.
- Extended the focused reconciliation contract test and Platform 15I static verifier to assert the explicit fallback map key.
- No change to unit activation semantics, publication semantics, RPCs, database, Supabase, RLS, grants, Media Center, routes, or RBAC.
- Candidate only; Flutter test/analyze/build and browser Network/readback UAT remain required.

## Platform 15J — Core Org Unit Type Sovereign Ownership Migration (2026-06-21)

- Added a read-only dependency census, guarded owner-schema migration and read-only post-apply validation for moving `public.org_unit_type` to `core.org_unit_type` without enum duplication or data reserialization.
- Updated governed unit create/update RPC cast boundaries to use `core.org_unit_type` after the same-object schema move.
- Staging evidence and production approval remain pending.

## Platform 15J1
Replaced the overly narrow enum dependency gate with an exact approved-set gate based on staging evidence.

## Platform 15J2 — Core Org Unit Type Index Dependency Gate Alignment (2026-06-21)
- Updated the exact typed-dependency set to include `core.idx_org_units_unit_type` (`relkind=i`) discovered in staging catalog evidence.
- Gate remains fail-closed for any other extra or missing dependency.
- No migration applied and production remains unapproved.
