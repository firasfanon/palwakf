# Database Ownership Phase B — Media Center Mega Closure Pack

## Purpose
This is the consolidated, non-fragmented Phase B package for Media Center ownership closure.
It replaces the previous step-by-step Phase B entry pack with a single large engineering package.

## Operating principle

```text
media_center becomes the owner/source-of-truth target for media content.
public remains a compatibility/API surface.
legacy public media tables are preserved.
No public table drop/delete/archive/exact replacement is authorized.
```

## What this pack contains

1. A single master census SQL for decision-grade read-only evidence.
2. A single guarded one-shot apply SQL for schema + legacy seed + public compatibility wrappers.
3. A single post-apply validation SQL.
4. A single browser/UAT matrix SQL.
5. A final next-gate SQL.

## Minimal run model

```text
1. Run 01 master census.
2. If the result proves required objects/columns are acceptable, run 02 only with explicit operator token.
3. Run 03 and 04 for validation/UAT evidence.
4. Run 05 for final gate.
```

This is intentionally **not** a chain of exploratory micro-patches.

## Do not run

```text
SQL29
SQL37
SQL38
SQL39
SQL40
SQL02/03/04 from Wave A
the old Phase B 05 DRAFT_NOT_RUN
```

## Hard boundaries

- No Auth/RBAC migration.
- No `auth.users` migration.
- No Flutter elevated secret.
- No mutation of `waqf`, `waqf_assets`, `awqaf_system`, or GIS.
- No `DROP`, `DELETE`, `TRUNCATE`, `ARCHIVE`, or exact public-table replacement.
- No `service_role` in Flutter.

## Operator note
The only executable mutation script here is `02_MEDIA_CENTER_ONE_SHOT_CONTROLLED_APPLY_GUARDED.sql`.
It fails closed unless the operator explicitly sets a transaction-local token after reviewing the master census and backup/restore point.
