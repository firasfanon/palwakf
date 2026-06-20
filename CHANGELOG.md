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
