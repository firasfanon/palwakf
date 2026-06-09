# PalWakf Governing Contract Appendix — N2.23 Database Ownership Wave 0/1

## New binding rules

1. `core.org_units` is the sovereign source of truth for modern organizational units.
2. `public.org_units` may exist only as a compatibility view over `core.org_units`.
3. Existing public views must preserve their column order and data types unless a new versioned contract is issued.
4. `public.pwf_org_units_cache` and `public.org_units_cache` are deprecated and may not be used as Dashboard/RBAC/Dynamic Registry sources.
5. Public RBAC tables remain transitional until an explicit RBAC migration batch.
6. No legacy/staging/cache table may be moved or deleted before dependency, RLS, RPC, and Flutter usage evidence is recorded in the inventory decision register.
7. Supabase-managed schemas are indexed only and not modified by PalWakf cleanup batches.

## Production gate

Production remains blocked until N2.23 SQL UAT, Flutter analyzer, Browser UAT, and ownership-risk review pass.
