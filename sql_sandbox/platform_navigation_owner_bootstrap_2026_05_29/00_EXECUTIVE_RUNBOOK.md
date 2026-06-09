# Platform Navigation Owner Bootstrap Runbook — 2026-05-29

## Allowed now

- Read the design documents.
- Run read-only census SQL only.
- Review guarded DDL/seed/wrapper drafts.

## Not allowed by this pack

- Do not run guarded DDL without explicit operator approval.
- Do not delete or archive `public.services` or `public.home_services`.
- Do not rewrite Flutter runtime.
- Do not rerun Media/Service SQL02.
- Do not change Auth/RBAC helpers.

## Recommended order

1. `01_CURRENT_PUBLIC_NAVIGATION_CENSUS_READ_ONLY.sql`
2. Review `02_PLATFORM_NAVIGATION_SCHEMA_BOOTSTRAP_GUARDED_NOT_RUN.sql`
3. Review `03_CONTROLLED_SEED_FROM_PUBLIC_SERVICES_HOME_SERVICES_GUARDED_NOT_RUN.sql`
4. Review `04_COMPATIBILITY_WRAPPERS_DRAFT_NOT_RUN.sql`
5. Do not run Stage 2+ scripts until an explicit apply decision is made.

## Current decision

`BOOTSTRAP_DESIGN_PREPARED / MIGRATION_NOT_EXECUTED / DELETE_BLOCKED`
