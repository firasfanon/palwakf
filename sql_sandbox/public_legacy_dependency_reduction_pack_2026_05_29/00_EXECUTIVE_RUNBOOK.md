# Public Legacy Dependency Reduction Pack — Executive Runbook — 2026-05-29

## Purpose
This pack starts dependency reduction after the deletion census proved that no `public` legacy media/service table is safe to delete.

## Scope
- Media legacy tables: `public.news_articles`, `public.announcements`, `public.activities`, `public.breaking_news`, `public.media_gallery_items`.
- Service legacy/catalog tables: `public.services`, `public.servicepoints`, `public.serviceproviders`, `public.servicetypes`.

## Decision

```text
Deletion blocked.
Preserve all present legacy public media/service tables.
Proceed with dependency reduction, not table deletion.
```

## Execution order

1. Run `01_DELETION_BLOCK_RESULT_INTAKE_READ_ONLY.sql` to register the current decision as a query result.
2. Run `02_PUBLIC_LEGACY_EXACT_BODY_EXPORT_READ_ONLY.sql` and save/export the output. This is the required exact-body evidence before rewriting any routine.
3. Run `03_SERVICE_CATALOG_MAPPING_GAP_REVIEW_READ_ONLY.sql` to inspect the public service catalog mismatch: `public.services = 9`, `platform_services.service_forms_registry = 6`.
4. Run `04_DEPENDENCY_REDUCTION_TARGET_MATRIX_READ_ONLY.sql` to classify the rewrite targets.
5. Do **not** execute `05_BODY_REWRITE_DRAFT_NOT_RUN.sql` as a migration. It is a draft gate and intentionally authorizes no rewrite.
6. Run `06_DELETION_GATE_STILL_BLOCKED_READ_ONLY.sql` to confirm no destructive action is authorized.

## Prohibitions

```text
No DROP.
No DELETE.
No TRUNCATE.
No archive/delete.
No exact public table replacement.
No Media/Service SQL02 rerun.
No Auth/RBAC helper rewrite.
No waqf/waqf_assets/awqaf_system/GIS mutation.
```

## Required evidence before the next executable rewrite pack

- Exact exported body for every routine listed by SQL 02.
- Reviewer-approved source mapping per routine.
- Post-rewrite dependency census target.
- Rollback body for each changed routine.
- Browser UAT after rewrite.
