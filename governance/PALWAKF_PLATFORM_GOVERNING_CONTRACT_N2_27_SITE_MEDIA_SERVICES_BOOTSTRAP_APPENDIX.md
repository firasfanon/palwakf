# PalWakf Governing Contract Appendix — N2.27

## Rule: Domain-Owned Schemas

Operational tables should be owned by their bounded domain schema. The `public` schema must be reduced back toward:

```text
views / RPC wrappers / compatibility surfaces
```

## Site Content Rule

A new domain owner is adopted for public-site/page-management data:

```text
site_content
```

This domain owns page structure, homepage sections, header/footer settings, hero slides, site settings, and comparable public-site presentation configuration.

## Media Center Rule

The media center should not remain operationally owned by `public`. A future migration should create/adopt:

```text
media_center
```

The migration must include RLS policies, RPC wrappers, Flutter repository migration, editorial workflow migration, audit migration, and UAT.

## Services Rule

`platform_services` remains the operational owner of service-center workflows. Service catalog/points/providers/types currently in `public` remain transitional until a mapping plan determines whether they belong to `platform_services` or `facilities_module`.

## Public Schema Rule

No new operational source-of-truth table should be added to `public`. New production domains must have an owner schema and public wrappers.

## View Safety Rule

Existing public views must preserve column order and data types unless a new view contract is created. `CREATE OR REPLACE VIEW` must not silently change existing view contracts.

## Movement Gate

No table move/delete/rename is permitted before:

- dependency audit,
- foreign-key audit,
- RLS policy audit,
- RPC/function audit,
- Flutter usage audit,
- rollback plan,
- UAT matrix.

## Production Gate

Production remains blocked until database ownership cleanup progresses through approved execution waves.
